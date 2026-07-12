local original_notify = vim.notify
local original_more = vim.o.more
local original_buffer = vim.api.nvim_get_current_buf()
local markdown

vim.notify = function() end
vim.o.more = false

local ok, result = xpcall(function()
  if not package.loaded["lazyvim.config.keymaps"] then
    vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
  end

  markdown = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(markdown)
  vim.api.nvim_buf_set_name(markdown, vim.fn.tempname() .. ".md")
  vim.bo[markdown].filetype = "markdown"

  local records = {}

  local function clean(value)
    local cleaned = value:gsub("\t", "\\t"):gsub("\r?\n", "\\n")
    return cleaned
  end

  local function collect(scope, mode, mappings)
    for _, mapping in ipairs(mappings) do
      if mapping.desc and mapping.desc ~= "" then
        records[#records + 1] = table.concat({ scope, mode, clean(mapping.lhs), clean(mapping.desc) }, "\t")
      end
    end
  end

  for _, mode in ipairs({ "n", "i", "x", "t" }) do
    collect("global", mode, vim.api.nvim_get_keymap(mode))
  end

  for _, mode in ipairs({ "n", "i", "x" }) do
    collect("markdown", mode, vim.api.nvim_buf_get_keymap(markdown, mode))
  end

  table.sort(records)
  return records
end, debug.traceback)

vim.notify = original_notify
vim.o.more = original_more

local cleanup_error
if vim.api.nvim_buf_is_valid(original_buffer) then
  local restored, err = pcall(vim.api.nvim_set_current_buf, original_buffer)
  cleanup_error = not restored and err or cleanup_error
end
if markdown and vim.api.nvim_buf_is_valid(markdown) then
  local deleted, err = pcall(vim.api.nvim_buf_delete, markdown, { force = true })
  cleanup_error = not deleted and err or cleanup_error
end

if not ok then
  error(result, 0)
end
if cleanup_error then
  error(cleanup_error, 0)
end

io.stdout:write(table.concat(result, "\n"), "\n")
