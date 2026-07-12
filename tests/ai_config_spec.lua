local h = require("tests.helpers")

local original_codex_home = vim.env.CODEX_HOME
local original_openai_key = vim.env.OPENAI_API_KEY
local original_notify_once = vim.notify_once
local original_print = print
local root = vim.fn.tempname()
local fake_key = "test-key-not-a-secret"
local recovery_key = "test-recovery-key-not-a-secret"
local notifications = {}
local printed_output = {}

local function cleanup()
  vim.notify_once = original_notify_once
  _G.print = original_print
  vim.env.CODEX_HOME = original_codex_home
  vim.env.OPENAI_API_KEY = original_openai_key
  package.loaded["config.ai"] = nil
  vim.fn.delete(root, "rf")
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

local ok, err = xpcall(function()
  vim.fn.mkdir(root, "p")
  _G.print = function(...)
    local values = {}
    for index = 1, select("#", ...) do
      values[index] = tostring(select(index, ...))
    end
    printed_output[#printed_output + 1] = table.concat(values, "\t")
  end
  vim.notify_once = function(message)
    notifications[#notifications + 1] = tostring(message)
  end

  local valid_home = vim.fs.joinpath(root, "valid")
  write_auth(valid_home, vim.json.encode({ OPENAI_API_KEY = fake_key }))
  local valid = load_from(valid_home)
  h.truthy(valid.get_openai_api_key() == fake_key, "valid auth returns the API key")

  write_auth(valid_home, vim.json.encode({ OPENAI_API_KEY = "replacement-key" }))
  h.truthy(valid.get_openai_api_key() == fake_key, "successful auth is cached in memory")
  h.truthy(vim.env.OPENAI_API_KEY == original_openai_key, "successful loading leaves OPENAI_API_KEY unchanged")

  local function expect_invalid(name, auth_json)
    local home = vim.fs.joinpath(root, name)
    vim.fn.mkdir(home, "p")
    if auth_json then
      write_auth(home, auth_json)
    end

    notifications = {}
    local ai = load_from(home)
    h.eq(ai.get_openai_api_key(), nil, name .. " returns nil")
    write_auth(home, vim.json.encode({ OPENAI_API_KEY = recovery_key }))
    h.truthy(ai.get_openai_api_key() == nil, name .. " caches the failure")
    h.eq(#notifications, 1, name .. " reports exactly one error")
    h.truthy(not notifications[1]:find(fake_key, 1, true), name .. " notification hides the credential")
  end

  expect_invalid("missing-file", nil)
  expect_invalid("malformed-json", '{"OPENAI_API_KEY":"' .. fake_key)
  expect_invalid("missing-field", vim.json.encode({ token = fake_key }))
  expect_invalid("invalid-type", vim.json.encode({ OPENAI_API_KEY = 42 }))
  expect_invalid("whitespace-field", vim.json.encode({ OPENAI_API_KEY = "   " }))

  local throwing_home = vim.fs.joinpath(root, "throwing-notifier")
  vim.fn.mkdir(throwing_home, "p")
  local throwing_notifications = 0
  vim.notify_once = function()
    throwing_notifications = throwing_notifications + 1
    error("notification failed")
  end
  local throwing_ai = load_from(throwing_home)
  local call_ok, result = pcall(throwing_ai.get_openai_api_key)
  h.truthy(call_ok, "notification failure does not escape the credential loader")
  h.eq(result, nil, "notification failure still returns nil")
  write_auth(throwing_home, vim.json.encode({ OPENAI_API_KEY = recovery_key }))
  h.truthy(throwing_ai.get_openai_api_key() == nil, "notification failure is cached")
  h.eq(throwing_notifications, 1, "notification failure is attempted once")

  h.truthy(vim.env.OPENAI_API_KEY == original_openai_key, "failed loading leaves OPENAI_API_KEY unchanged")
  local output = table.concat(printed_output, "\n")
  h.truthy(not output:find(fake_key, 1, true), "ordinary output hides the test credential")
  h.truthy(not output:find(recovery_key, 1, true), "ordinary output hides the recovery credential")
end, debug.traceback)

cleanup()

if not ok then
  error(err)
end

print("ai_config_spec: ok")
