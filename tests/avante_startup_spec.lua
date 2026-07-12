local h = require("tests.helpers")

local original_codex_home = vim.env.CODEX_HOME
local original_notify = vim.notify
local original_print = print
local original_errmsg = vim.v.errmsg
local original_ai_module = package.loaded["config.ai"]
local root = vim.fn.tempname()
local fake_key = "startup-test-key"
local notifications = {}
local printed_output = {}

local function capture_notification(message)
  notifications[#notifications + 1] = tostring(message)
end

local function cleanup()
  vim.notify = original_notify
  _G.print = original_print
  vim.v.errmsg = original_errmsg
  vim.env.CODEX_HOME = original_codex_home
  package.loaded["config.ai"] = original_ai_module
  vim.fn.delete(root, "rf")
end

local ok, err = xpcall(function()
  vim.fn.mkdir(root, "p")
  vim.fn.writefile({ vim.json.encode({ OPENAI_API_KEY = fake_key }) }, vim.fs.joinpath(root, "auth.json"))
  vim.env.CODEX_HOME = root
  package.loaded["config.ai"] = nil

  vim.v.errmsg = ""
  vim.notify = capture_notification
  _G.print = function(...)
    local values = {}
    for index = 1, select("#", ...) do
      values[index] = tostring(select(index, ...))
    end
    printed_output[#printed_output + 1] = table.concat(values, "\t")
  end
  if not vim.g.did_very_lazy then
    vim.api.nvim_exec_autocmds("UIEnter", { modeline = false })
  end
  local loaded = vim.wait(5000, function()
    local plugin = require("lazy.core.config").plugins["avante.nvim"]
    return vim.g.did_very_lazy == true and plugin and plugin._ and plugin._.loaded ~= nil
  end, 20)
  h.truthy(loaded, "VeryLazy fires and Avante loads")

  vim.notify = capture_notification
  vim.wait(1000, function()
    return false
  end, 20)

  local output = table.concat({
    vim.v.errmsg,
    table.concat(notifications, "\n"),
    table.concat(printed_output, "\n"),
  }, "\n")
  local forbidden = {
    { text = "copilot_internal", label = "Copilot token endpoint" },
    { text = "cannot resume dead coroutine", label = "dead coroutine error" },
    { text = "curl error exit_code=7", label = "curl connection error" },
    { text = fake_key, label = "temporary credential" },
  }

  h.eq(package.loaded["copilot"], nil, "VeryLazy does not load Copilot")
  for _, pattern in ipairs(forbidden) do
    h.truthy(not output:find(pattern.text, 1, true), "startup output excludes " .. pattern.label)
  end
end, debug.traceback)

cleanup()

if not ok then
  error(err, 0)
end

io.stdout:write("avante_startup_spec: ok\n")
io.stdout:flush()
