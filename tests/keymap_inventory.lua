local original_notify = vim.notify
local original_more = vim.o.more
vim.notify = function() end
vim.o.more = false

if not package.loaded["lazyvim.config.keymaps"] then
  vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
end

local markdown = vim.api.nvim_create_buf(false, true)
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
vim.api.nvim_buf_delete(markdown, { force = true })
vim.notify = original_notify
vim.o.more = original_more

io.stdout:write(table.concat(records, "\n"), "\n")
