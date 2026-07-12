local h = require("tests.helpers")

local original_codex_home = vim.env.CODEX_HOME
local original_openai_key = vim.env.OPENAI_API_KEY
local root = vim.fn.tempname()
local fake_key = "avante-provider-test-key"

local function dependency_names(dependencies)
  local names = {}
  for _, dependency in ipairs(dependencies or {}) do
    names[#names + 1] = type(dependency) == "table" and dependency.name or dependency
  end
  return names
end

local function cleanup()
  vim.env.CODEX_HOME = original_codex_home
  vim.env.OPENAI_API_KEY = original_openai_key
  package.loaded["config.ai"] = nil
  vim.fn.delete(root, "rf")
end

local ok, err = xpcall(function()
  vim.fn.mkdir(root, "p")
  vim.fn.writefile({ vim.json.encode({ OPENAI_API_KEY = fake_key }) }, vim.fs.joinpath(root, "auth.json"))
  vim.env.CODEX_HOME = root
  package.loaded["config.ai"] = nil

  local avante_opts = h.plugin_opts("avante.nvim")
  h.eq(avante_opts.provider, "codex", "Avante selected provider")

  local codex = avante_opts.providers.codex
  h.truthy(codex, "Codex provider options are configured")
  h.eq(codex.__inherited_from, "openai", "Codex provider inheritance")
  h.eq(codex.endpoint, "https://www.aivalux.com", "Codex endpoint")
  h.eq(codex.model, "gpt-5.6-sol", "Codex model")
  h.eq(codex.api_key_name, "OPENAI_API_KEY", "Codex API key name")
  h.eq(codex.use_response_api, true, "Codex Response API setting")
  h.eq(codex.proxy, "http://127.0.0.1:7897", "Codex proxy")
  h.eq(type(codex.parse_api_key), "function", "Codex API key callback")
  h.truthy(codex.parse_api_key() == fake_key, "Codex API key callback reads temporary auth")
  h.truthy(vim.env.OPENAI_API_KEY == original_openai_key, "provider callback leaves OPENAI_API_KEY unchanged")

  local source_avante = dofile("lua/plugins/avante.lua")
  h.eq(source_avante.event, "VeryLazy", "Avante event")
  h.eq(source_avante.version, false, "Avante version")
  h.eq(source_avante.build, "make", "Avante build")
  h.eq(dependency_names(source_avante.dependencies), {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  }, "Avante source dependencies")

  local lazy_config = require("lazy.core.config")
  local normalized_dependencies = dependency_names(lazy_config.plugins["avante.nvim"].dependencies)
  h.truthy(
    not vim.tbl_contains(normalized_dependencies, "copilot.lua"),
    "normalized Avante dependencies exclude Copilot"
  )

  local source_copilot = dofile("lua/plugins/copilot.lua")
  h.eq(source_copilot[1], "zbirenbaum/copilot.lua", "Copilot source plugin")
  h.eq(source_copilot.enabled, false, "Copilot is explicitly disabled")
  h.eq(lazy_config.plugins["copilot.lua"], nil, "disabled Copilot is absent from Lazy's active plugin table")

  h.eq(package.loaded["copilot"], nil, "Copilot module starts unloaded")
  require("lazy").load({ plugins = { "avante.nvim" } })

  local avante_config = require("avante.config")
  h.eq(avante_config.provider, "codex", "loaded Avante selected provider")
  local resolved_codex = require("avante.providers").codex
  h.eq(resolved_codex.__inherited_from, "openai", "resolved Codex provider inheritance")
  h.eq(resolved_codex.endpoint, "https://www.aivalux.com", "resolved Codex endpoint")
  h.eq(resolved_codex.model, "gpt-5.6-sol", "resolved Codex model")
  h.eq(resolved_codex.api_key_name, "OPENAI_API_KEY", "resolved Codex API key name")
  h.eq(resolved_codex.use_response_api, true, "resolved Codex Response API setting")
  h.eq(resolved_codex.proxy, "http://127.0.0.1:7897", "resolved Codex proxy")
  h.truthy(resolved_codex.parse_api_key() == fake_key, "resolved Codex callback reads temporary auth")
  h.eq(package.loaded["copilot"], nil, "loading Avante does not load Copilot")
end, debug.traceback)

cleanup()

if not ok then
  error(err)
end

print("avante_provider_spec: ok")
