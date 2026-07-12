# Avante Codex-Compatible Provider Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Avante's failing GitHub Copilot integration with the approved Codex-compatible Responses API provider while keeping the credential private and isolating AI failures from Neovim startup.

**Architecture:** A focused `config.ai` module reads and caches `OPENAI_API_KEY` from Codex's `auth.json` without exporting it. Avante inherits its OpenAI provider, supplies the approved endpoint, model, Responses API flag, proxy, and key callback, while a separate Lazy override disables Copilot completely.

**Tech Stack:** Neovim 0.12 Lua, LazyVim, lazy.nvim, Avante.nvim OpenAI provider, `vim.json`, `vim.system`, curl, Stylua.

---

## File Map

- Create `lua/config/ai.lua`: resolve Codex home, decode `auth.json`, validate and cache the API key, and report secret-free failures once.
- Create `tests/ai_config_spec.lua`: exercise credential success, cache behavior, environment isolation, and malformed or missing input using temporary files.
- Modify `lua/plugins/avante.lua`: select and configure the custom `codex` provider and remove the Copilot dependency.
- Modify `lua/plugins/copilot.lua`: replace active Copilot setup with an explicit disabled plugin override.
- Create `tests/avante_provider_spec.lua`: verify Lazy's merged provider configuration, resolved Avante inheritance, secret callback, dependency removal, and disabled Copilot state.
- Create `tests/avante_startup_spec.lua`: trigger `VeryLazy` with a fake credential and reject the original startup error signatures.
- Create `tests/avante_connectivity_check.lua`: make one authenticated, body-discarding `/models` request through port 7897 without exposing the key in process arguments or output.

### Task 1: Codex Credential Loader

**Files:**
- Create: `tests/ai_config_spec.lua`
- Create: `lua/config/ai.lua`

- [ ] **Step 1: Write the failing credential tests**

Create `tests/ai_config_spec.lua`:

```lua
local h = require("tests.helpers")

local original_codex_home = vim.env.CODEX_HOME
local original_openai_key = vim.env.OPENAI_API_KEY
local original_notify_once = vim.notify_once
local root = vim.fn.tempname()
local fake_key = "test-key-not-a-secret"
local notifications = {}

vim.fn.mkdir(root, "p")
vim.notify_once = function(message)
  notifications[#notifications + 1] = tostring(message)
end

local function load_from(home)
  vim.env.CODEX_HOME = home
  package.loaded["config.ai"] = nil
  return require("config.ai")
end

local function write_auth(home, value)
  vim.fn.mkdir(home, "p")
  vim.fn.writefile({ value }, vim.fs.joinpath(home, "auth.json"))
end

local valid_home = vim.fs.joinpath(root, "valid")
write_auth(valid_home, vim.json.encode({ OPENAI_API_KEY = fake_key }))
local valid = load_from(valid_home)
h.truthy(valid.get_openai_api_key() == fake_key, "valid auth returns the API key")
write_auth(valid_home, vim.json.encode({ OPENAI_API_KEY = "replacement-key" }))
h.truthy(valid.get_openai_api_key() == fake_key, "successful auth is cached in memory")
h.truthy(vim.env.OPENAI_API_KEY == original_openai_key, "credential loading leaves OPENAI_API_KEY unchanged")

local function expect_invalid(name, auth_json)
  local home = vim.fs.joinpath(root, name)
  vim.fn.mkdir(home, "p")
  if auth_json then
    write_auth(home, auth_json)
  end

  notifications = {}
  local ai = load_from(home)
  h.eq(ai.get_openai_api_key(), nil, name .. " returns nil")
  h.eq(ai.get_openai_api_key(), nil, name .. " caches the failure")
  h.eq(#notifications, 1, name .. " reports exactly one error")
  h.truthy(not notifications[1]:find(fake_key, 1, true), name .. " notification hides the credential")
end

expect_invalid("missing-file", nil)
expect_invalid("malformed-json", "{")
expect_invalid("missing-field", vim.json.encode({ token = "unrelated" }))
expect_invalid("invalid-field", vim.json.encode({ OPENAI_API_KEY = "   " }))

vim.notify_once = original_notify_once
vim.env.CODEX_HOME = original_codex_home
vim.env.OPENAI_API_KEY = original_openai_key
vim.fn.delete(root, "rf")

print("ai_config_spec: ok")
```

- [ ] **Step 2: Run the credential test and verify it fails**

Run:

```bash
XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
  nvim --headless -u ./init.lua -i NONE -l tests/ai_config_spec.lua
```

Expected: non-zero exit with `module 'config.ai' not found`.

- [ ] **Step 3: Implement the minimal credential module**

Create `lua/config/ai.lua`:

```lua
local M = {}

local loaded = false
local cached_key

local function notify_failure(message)
  pcall(vim.notify_once, message, vim.log.levels.ERROR, { title = "AI credentials" })
  return nil
end

local function codex_home()
  local configured = vim.env.CODEX_HOME
  if type(configured) == "string" and configured ~= "" then
    return vim.fs.normalize(configured)
  end
  return vim.fs.normalize(vim.fn.expand("~/.codex"))
end

function M.get_openai_api_key()
  if loaded then
    return cached_key
  end
  loaded = true

  local auth_path = vim.fs.joinpath(codex_home(), "auth.json")
  local read_ok, lines = pcall(vim.fn.readfile, auth_path)
  if not read_ok then
    return notify_failure("Unable to read Codex credentials at " .. auth_path)
  end

  local decode_ok, auth = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not decode_ok or type(auth) ~= "table" then
    return notify_failure("Codex credentials are not valid JSON: " .. auth_path)
  end

  local key = auth.OPENAI_API_KEY
  if type(key) ~= "string" or key:match("^%s*$") then
    return notify_failure("Codex credentials do not contain a valid OPENAI_API_KEY: " .. auth_path)
  end

  cached_key = key
  return cached_key
end

return M
```

- [ ] **Step 4: Run the credential test and formatting check**

Run:

```bash
stylua --check lua/config/ai.lua tests/ai_config_spec.lua
XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
  nvim --headless -u ./init.lua -i NONE -l tests/ai_config_spec.lua
```

Expected: Stylua exits zero and Neovim prints `ai_config_spec: ok`. No output contains `test-key-not-a-secret`.

- [ ] **Step 5: Commit the credential loader**

```bash
git add lua/config/ai.lua tests/ai_config_spec.lua
git commit -m "feat: load Avante credential from Codex auth"
```

### Task 2: Avante Provider And Copilot Disable Override

**Files:**
- Create: `tests/avante_provider_spec.lua`
- Modify: `lua/plugins/avante.lua:1-22`
- Modify: `lua/plugins/copilot.lua:1-11`

- [ ] **Step 1: Write the failing provider integration test**

Create `tests/avante_provider_spec.lua`:

```lua
local h = require("tests.helpers")

local original_codex_home = vim.env.CODEX_HOME
local root = vim.fn.tempname()
local fake_key = "provider-test-key"
vim.fn.mkdir(root, "p")
vim.fn.writefile({ vim.json.encode({ OPENAI_API_KEY = fake_key }) }, vim.fs.joinpath(root, "auth.json"))
vim.env.CODEX_HOME = root
package.loaded["config.ai"] = nil

local opts = h.plugin_opts("avante.nvim")
h.eq(opts.provider, "codex", "Avante selects the Codex-compatible provider")
local codex = opts.providers and opts.providers.codex
h.truthy(codex, "Codex provider options exist")
h.eq(codex.__inherited_from, "openai", "Codex provider inherits OpenAI")
h.eq(codex.endpoint, "https://www.aivalux.com", "Codex provider endpoint")
h.eq(codex.model, "gpt-5.6-sol", "Codex provider model")
h.eq(codex.use_response_api, true, "Codex provider uses the Responses API")
h.eq(codex.proxy, "http://127.0.0.1:7897", "Codex provider proxy")
h.eq(codex.api_key_name, "OPENAI_API_KEY", "Codex provider declares authentication")
h.truthy(type(codex.parse_api_key) == "function", "Codex provider has a key callback")
h.truthy(codex.parse_api_key() == fake_key, "Codex provider reads the temporary credential")

local lazy_config = require("lazy.core.config")
local avante_plugin = lazy_config.plugins["avante.nvim"]
h.eq(vim.tbl_contains(avante_plugin.dependencies or {}, "copilot.lua"), false, "Avante drops Copilot dependency")

local copilot_source = dofile("lua/plugins/copilot.lua")
h.eq(copilot_source.enabled, false, "local Copilot specification is disabled")
h.eq(lazy_config.plugins["copilot.lua"], nil, "disabled Copilot is absent from Lazy's active plugins")

require("lazy").load({ plugins = { "avante.nvim" } })
local provider = require("avante.providers").codex
h.eq(provider.__inherited_from, "openai", "resolved provider keeps OpenAI inheritance")
h.eq(provider.endpoint, "https://www.aivalux.com", "resolved provider endpoint")
h.eq(provider.model, "gpt-5.6-sol", "resolved provider model")
h.eq(provider.use_response_api, true, "resolved provider uses Responses API")
h.eq(provider.proxy, "http://127.0.0.1:7897", "resolved provider proxy")
h.truthy(provider.parse_api_key() == fake_key, "resolved provider uses the credential callback")
h.eq(package.loaded["copilot"], nil, "loading Avante does not load Copilot")

vim.env.CODEX_HOME = original_codex_home
vim.fn.delete(root, "rf")

print("avante_provider_spec: ok")
```

- [ ] **Step 2: Run the provider test and verify it fails**

Run:

```bash
XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
  nvim --headless -u ./init.lua -i NONE -l tests/avante_provider_spec.lua
```

Expected: non-zero exit with `Avante selects the Codex-compatible provider: expected "codex", got "copilot"`.

- [ ] **Step 3: Configure the Codex-compatible Avante provider**

Replace `lua/plugins/avante.lua` with:

```lua
return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  opts = {
    provider = "codex",
    providers = {
      codex = {
        __inherited_from = "openai",
        endpoint = "https://www.aivalux.com",
        model = "gpt-5.6-sol",
        api_key_name = "OPENAI_API_KEY",
        use_response_api = true,
        proxy = "http://127.0.0.1:7897",
        parse_api_key = function()
          return require("config.ai").get_openai_api_key()
        end,
      },
    },
  },
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
}
```

- [ ] **Step 4: Replace active Copilot setup with a disable override**

Replace `lua/plugins/copilot.lua` with:

```lua
return {
  "zbirenbaum/copilot.lua",
  enabled = false,
}
```

- [ ] **Step 5: Run the provider test and formatting checks**

Run:

```bash
stylua --check lua/plugins/avante.lua lua/plugins/copilot.lua tests/avante_provider_spec.lua
XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
  nvim --headless -u ./init.lua -i NONE -l tests/avante_provider_spec.lua
```

Expected: Stylua exits zero and Neovim prints `avante_provider_spec: ok`. The output contains neither fake key nor a GitHub Copilot token URL.

- [ ] **Step 6: Commit the provider migration**

```bash
git add lua/plugins/avante.lua lua/plugins/copilot.lua tests/avante_provider_spec.lua
git commit -m "fix: migrate Avante from Copilot to Codex backend"
```

### Task 3: Startup Regression And Connectivity Checks

**Files:**
- Create: `tests/avante_startup_spec.lua`
- Create: `tests/avante_connectivity_check.lua`

- [ ] **Step 1: Write the startup regression test**

Create `tests/avante_startup_spec.lua`:

```lua
local h = require("tests.helpers")

local original_codex_home = vim.env.CODEX_HOME
local original_notify = vim.notify
local root = vim.fn.tempname()
local fake_key = "startup-test-key"
local notifications = {}

vim.fn.mkdir(root, "p")
vim.fn.writefile({ vim.json.encode({ OPENAI_API_KEY = fake_key }) }, vim.fs.joinpath(root, "auth.json"))
vim.env.CODEX_HOME = root
package.loaded["config.ai"] = nil
vim.v.errmsg = ""
vim.notify = function(message)
  notifications[#notifications + 1] = tostring(message)
end

vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })
local loaded = vim.wait(5000, function()
  local plugin = require("lazy.core.config").plugins["avante.nvim"]
  return plugin and plugin._ and plugin._.loaded ~= nil
end, 20)

vim.notify = original_notify
local output = vim.v.errmsg .. "\n" .. table.concat(notifications, "\n")
local forbidden = {
  "copilot_internal",
  "cannot resume dead coroutine",
  "curl error exit_code=7",
  fake_key,
}

h.truthy(loaded, "Avante loads during VeryLazy")
h.eq(package.loaded["copilot"], nil, "VeryLazy does not load Copilot")
for _, text in ipairs(forbidden) do
  h.truthy(not output:find(text, 1, true), "startup output excludes " .. text)
end

vim.env.CODEX_HOME = original_codex_home
vim.fn.delete(root, "rf")

print("avante_startup_spec: ok")
```

- [ ] **Step 2: Run the startup regression test**

Run:

```bash
XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
  nvim --headless -u ./init.lua -i NONE -l tests/avante_startup_spec.lua \
  >/tmp/nvim-avante-startup.log 2>&1
rg -n 'avante_startup_spec: ok' /tmp/nvim-avante-startup.log
if rg -n 'copilot_internal|cannot resume dead coroutine|curl error exit_code=7|startup-test-key' \
  /tmp/nvim-avante-startup.log; then exit 1; fi
```

Expected: the first `rg` finds `avante_startup_spec: ok`; the forbidden-pattern check prints nothing and exits zero.

- [ ] **Step 3: Add the body-discarding connectivity check**

Create `tests/avante_connectivity_check.lua`:

```lua
local key = require("config.ai").get_openai_api_key()
assert(key, "Codex credential is unavailable")

local result = vim.system({
  "curl",
  "--silent",
  "--show-error",
  "--output",
  "/dev/null",
  "--write-out",
  "%{http_code}",
  "--connect-timeout",
  "10",
  "--max-time",
  "30",
  "--proxy",
  "http://127.0.0.1:7897",
  "--header",
  "@-",
  "https://www.aivalux.com/models",
}, {
  stdin = "Authorization: Bearer " .. key .. "\n",
  text = true,
}):wait()

assert(result.code == 0, ("model-list curl exited with code %d"):format(result.code))
local status = tonumber(vim.trim(result.stdout or ""))
assert(status and status >= 200 and status < 300, ("model-list request returned HTTP %s"):format(status or "unknown"))

print(("avante_connectivity_check: ok (HTTP %d)"):format(status))
```

The authorization header is supplied on curl's standard input with `--header @-`; it is absent from the process argument list. Curl discards the body and prints only the HTTP status.

- [ ] **Step 4: Run the authenticated connectivity check through port 7897**

Run:

```bash
nvim --headless -u ./init.lua -i NONE -l tests/avante_connectivity_check.lua
```

Expected: `avante_connectivity_check: ok (HTTP 200)` or another HTTP 2xx status. The output contains no authorization header, key, response body, or generated content.

- [ ] **Step 5: Format and commit the regression checks**

Run:

```bash
stylua --check tests/avante_startup_spec.lua tests/avante_connectivity_check.lua
git add tests/avante_startup_spec.lua tests/avante_connectivity_check.lua
git commit -m "test: guard Avante startup and connectivity"
```

Expected: Stylua exits zero and the commit contains only the two new test scripts.

### Task 4: Full Verification

**Files:**
- Verify: `lua/config/ai.lua`
- Verify: `lua/plugins/avante.lua`
- Verify: `lua/plugins/copilot.lua`
- Verify: `tests/*.lua`

- [ ] **Step 1: Run every offline headless regression test**

Run:

```bash
for spec in \
  tests/ai_config_spec.lua \
  tests/avante_provider_spec.lua \
  tests/avante_startup_spec.lua \
  tests/explorer_spec.lua \
  tests/markdown_render_spec.lua \
  tests/keymap_doc_spec.lua; do
  XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
    nvim --headless -u ./init.lua -i NONE -l "$spec" || exit 1
done
```

Expected: every script prints its `: ok` marker and the loop exits zero. No output contains a credential or Copilot token URL.

- [ ] **Step 2: Run all formatting checks**

Run:

```bash
stylua --check \
  lua/config/ai.lua \
  lua/plugins/avante.lua \
  lua/plugins/copilot.lua \
  tests/ai_config_spec.lua \
  tests/avante_provider_spec.lua \
  tests/avante_startup_spec.lua \
  tests/avante_connectivity_check.lua
```

Expected: Stylua exits zero with no changed files.

- [ ] **Step 3: Re-run the authenticated read-only check and protect the real auth file**

Run:

```bash
auth_metadata_before=$(stat -c '%a:%s:%Y' "$HOME/.codex/auth.json")
auth_hash_before=$(sha256sum "$HOME/.codex/auth.json" | cut -d' ' -f1)
nvim --headless -u ./init.lua -i NONE -l tests/avante_connectivity_check.lua
auth_metadata_after=$(stat -c '%a:%s:%Y' "$HOME/.codex/auth.json")
auth_hash_after=$(sha256sum "$HOME/.codex/auth.json" | cut -d' ' -f1)
test "$auth_metadata_before" = "$auth_metadata_after"
test "$auth_hash_before" = "$auth_hash_after"
```

Expected: connectivity reports HTTP 2xx and both comparisons exit zero. The command does not print the key, file contents, authorization header, or response body.

- [ ] **Step 4: Inspect the final diff and commit history**

Run:

```bash
git status --short --branch
git diff --check HEAD~3..HEAD
git log -4 --oneline --decorate
```

Expected: the branch contains the credential, provider migration, and regression-check commits after the design/plan documentation; no unrelated file is staged or modified by this work.
