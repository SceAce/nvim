local key = require("config.ai").get_openai_api_key()
assert(key, "Codex credential is unavailable")

local result = vim
  .system({
    "curl",
    "--disable",
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
    "--noproxy",
    "",
    "--header",
    "@-",
    "https://www.aivalux.com/models",
  }, {
    stdin = "Authorization: Bearer " .. key .. "\n",
    text = true,
  })
  :wait()

assert(result.code == 0, ("model-list curl exited with code %d"):format(result.code))
local status = tonumber(vim.trim(result.stdout or ""))
assert(status and status >= 200 and status < 300, ("model-list request returned HTTP %s"):format(status or "unknown"))

print(("avante_connectivity_check: ok (HTTP %d)"):format(status))
