local helpers = require("tests.helpers")

local lines = vim.fn.readfile("keymap.md")
local document = table.concat(lines, "\n")

local function contains(text, label)
  helpers.truthy(document:find(text, 1, true), label)
end

local function excludes(text, label)
  helpers.truthy(not document:find(text, 1, true), label)
end

contains("### Snacks Picker / 搜索", "Snacks Picker heading")
contains("### 搜索与替换", "search and replace heading")
contains("### Snacks Explorer", "Snacks Explorer heading")

contains("| `<leader>um` | n | 切换 Neovim 内 Markdown 渲染 |", "Markdown render toggle row")
contains("| `<leader>gs` | n | Git 状态 |", "Git status row")
contains("| `<leader>fb` | n | Buffer 列表 |", "buffer picker row")
contains("| `<leader>sr` | n, x | 跨文件搜索与替换（grug-far.nvim） |", "search and replace row")
contains("| `H` | Explorer | 切换点文件显示 |", "Explorer hidden-files row")
contains("| `I` | Explorer | 切换 Git 忽略项显示 |", "Explorer ignored-files row")
contains("libtexprintf", "libtexprintf prerequisite")
contains("utftex", "utftex converter")

excludes("### Telescope / 搜索", "stale Telescope heading")
excludes("### Neo-tree", "stale Neo-tree heading")
excludes("| `<leader>ge` |", "stale Git explorer row")
excludes("| `<leader>be` |", "stale buffer explorer row")
excludes("| `<leader>so` |", "stale options picker row")

for _, lhs in ipairs({ "<leader>E", "<leader>gs", "<leader>fb" }) do
  helpers.truthy(vim.fn.maparg(lhs, "n") ~= "", ("runtime mapping %s exists"):format(lhs))
end

print("keymap_doc_spec: ok")
