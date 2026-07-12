local M = {}

function M.plugin_opts(name)
  local config = require("lazy.core.config")
  local plugin = require("lazy.core.plugin")
  local spec = config.plugins[name]

  M.truthy(spec, ("plugin %q is configured"):format(name))
  return plugin.values(spec, "opts", false)
end

function M.eq(actual, expected, label)
  assert(
    vim.deep_equal(actual, expected),
    ("%s: expected %s, got %s"):format(label, vim.inspect(expected), vim.inspect(actual))
  )
end

function M.truthy(value, label)
  assert(value, ("%s: expected a truthy value, got %s"):format(label, vim.inspect(value)))
end

function M.contains(values, expected, label)
  assert(type(values) == "table", ("%s: expected a table, got %s"):format(label, vim.inspect(values)))
  assert(
    vim.tbl_contains(values, expected),
    ("%s: expected %s to contain %s"):format(label, vim.inspect(values), vim.inspect(expected))
  )
end

return M
