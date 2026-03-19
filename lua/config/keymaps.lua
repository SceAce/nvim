-- Keymaps are automatically loaded on the VeryLazy event
-- Only native Neovim keymaps here. Plugin keymaps belong in their plugin files.

local map = vim.keymap.set

-- Window Navigation
map("n", "<A-h>", "<C-w>h", { desc = "Go to Left Window", noremap = true })
map("n", "<A-l>", "<C-w>l", { desc = "Go to Right Window", noremap = true })
map("n", "<A-j>", "<C-w>j", { desc = "Go to Lower Window", noremap = true })
map("n", "<A-k>", "<C-w>k", { desc = "Go to Upper Window", noremap = true })

-- Buffer Navigation
map("n", "<A-[>", "<cmd>bprevious<CR>", { desc = "Prev Buffer", noremap = true })
map("n", "<A-]>", "<cmd>bnext<CR>", { desc = "Next Buffer", noremap = true })

-- Move Lines
map("n", "<A-down>", "<cmd>execute 'move .+' . v:count1<CR>==", { desc = "Move Down" })
map("n", "<A-up>", "<cmd>execute 'move .-' . (v:count1 + 1)<CR>==", { desc = "Move Up" })
map("i", "<A-down>", "<esc><cmd>execute 'move .+' . v:count1<CR>==gi", { desc = "Move Down" })
map("i", "<A-up>", "<esc><cmd>execute 'move .-' . (v:count1 + 1)<CR>==gi", { desc = "Move Up" })
map("v", "<A-down>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<CR>gv=gv", { desc = "Move Down" })
map("v", "<A-up>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<CR>gv=gv", { desc = "Move Up" })

-- Split Window
map("n", "<leader>-", "<C-w>s", { desc = "Split Window Below", noremap = true })
map("n", "<leader>|", "<C-w>v", { desc = "Split Window Right", noremap = true })
