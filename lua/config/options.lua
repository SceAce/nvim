vim.opt.winbar = "%{%v:lua.require'custom.winbar'.eval()%}"

-- 全局统一 4 空格缩进。
-- 禁用内置 editorconfig 支持，否则项目里的 `.editorconfig`（indent_size = 2）
-- 会覆盖下面的设置，导致回车/Tab 是 4 空格、保存后又变回 2 空格。
-- 真正需要跟随某项目规范时，可临时执行 `:lua vim.g.editorconfig = true` 或
-- 在该 buffer 手动 `:setlocal shiftwidth=2`。
vim.g.editorconfig = false

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.relativenumber = false
