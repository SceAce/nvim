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
