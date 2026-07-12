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
  h.eq(avante_opts.provider, "codex_http", "Avante selected provider")

  local codex_http = avante_opts.providers.codex_http
  h.truthy(codex_http, "Codex HTTP provider options are configured")
  h.eq(codex_http.__inherited_from, "openai", "Codex HTTP provider inheritance")
  h.eq(codex_http.endpoint, "https://www.aivalux.com", "Codex HTTP endpoint")
  h.eq(codex_http.model, "gpt-5.6-sol", "Codex HTTP model")
  h.eq(codex_http.api_key_name, "OPENAI_API_KEY", "Codex HTTP API key name")
  h.eq(codex_http.use_response_api, true, "Codex HTTP Response API setting")
  h.eq(codex_http.proxy, "http://127.0.0.1:7897", "Codex HTTP proxy")
  h.eq(type(codex_http.parse_api_key), "function", "Codex HTTP API key callback")
  h.truthy(codex_http.parse_api_key() == fake_key, "Codex HTTP API key callback reads temporary auth")
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
  h.eq(avante_config.provider, "codex_http", "loaded Avante selected provider")
  h.eq(avante_config.acp_providers[avante_config.provider], nil, "selected provider does not route as ACP")
  local resolved_codex_http = require("avante.providers").codex_http
  h.eq(resolved_codex_http.__inherited_from, "openai", "resolved Codex HTTP provider inheritance")
  h.eq(resolved_codex_http.endpoint, "https://www.aivalux.com", "resolved Codex HTTP endpoint")
  h.eq(resolved_codex_http.model, "gpt-5.6-sol", "resolved Codex HTTP model")
  h.eq(resolved_codex_http.api_key_name, "OPENAI_API_KEY", "resolved Codex HTTP API key name")
  h.eq(resolved_codex_http.use_response_api, true, "resolved Codex HTTP Response API setting")
  h.eq(resolved_codex_http.proxy, "http://127.0.0.1:7897", "resolved Codex HTTP proxy")
  h.truthy(resolved_codex_http.parse_api_key() == fake_key, "resolved Codex HTTP callback reads temporary auth")
  h.eq(package.loaded["copilot"], nil, "loading Avante does not load Copilot")
end, debug.traceback)

cleanup()

if not ok then
  error(err)
end

print("avante_provider_spec: ok")
