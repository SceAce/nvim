# Neovim Explorer and Markdown Rendering Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Snacks Explorer show hidden and Git-ignored entries, render Markdown LaTeX formulas through `utftex`, and reconcile the shortcut reference with the active LazyVim configuration.

**Architecture:** Explorer and Markdown rendering receive separate Lazy plugin specs in `lua/plugins/explorer.lua` and `lua/plugins/markdown_render.lua`. Runtime regression scripts inspect Lazy's merged options rather than individual source tables, while the existing writing and general UI modules keep their current responsibilities.

**Tech Stack:** Neovim 0.12, LazyVim, lazy.nvim, Snacks Explorer/Picker, render-markdown.nvim, nvim-treesitter, utftex/libtexprintf, Lua, Markdown, Stylua.

---

## File Map

- Create `lua/plugins/explorer.lua`: own all Snacks Explorer display options.
- Modify `lua/plugins/ui.lua`: remove the Explorer-specific layout override.
- Create `lua/plugins/markdown_render.lua`: own Treesitter LaTeX and render-markdown formula options.
- Keep `lua/plugins/markdown_writer.lua` unchanged: retain authoring, Aerial, image, and browser-preview features.
- Create `tests/helpers.lua`: provide assertions and merged lazy.nvim option lookup.
- Create `tests/explorer_spec.lua`: verify final Explorer options.
- Create `tests/markdown_render_spec.lua`: verify formula prerequisites, options, and generated marks.
- Create `tests/keymap_inventory.lua`: print active global and Markdown-buffer mappings.
- Create `tests/keymap_doc_spec.lua`: guard corrected plugin names and critical mappings.
- Modify `keymap.md`: reconcile the complete curated shortcut reference.

### Task 1: Snacks Explorer Visibility

**Files:**
- Create: `tests/helpers.lua`
- Create: `tests/explorer_spec.lua`
- Create: `lua/plugins/explorer.lua`
- Modify: `lua/plugins/ui.lua:2-16`

- [ ] **Step 1: Add the shared runtime test helper**

Create `tests/helpers.lua`:

```lua
local M = {}

function M.plugin_opts(name)
  local config = require("lazy.core.config")
  local plugin = require("lazy.core.plugin")
  local spec = assert(config.plugins[name], "missing lazy plugin: " .. name)
  return plugin.values(spec, "opts", false)
end

function M.eq(actual, expected, label)
  if not vim.deep_equal(actual, expected) then
    error(string.format("%s: expected %s, got %s", label, vim.inspect(expected), vim.inspect(actual)))
  end
end

function M.truthy(value, label)
  if not value then
    error(label)
  end
end

function M.contains(values, expected, label)
  M.truthy(type(values) == "table" and vim.tbl_contains(values, expected), label)
end

return M
```

- [ ] **Step 2: Write the failing Explorer option test**

Create `tests/explorer_spec.lua`:

```lua
local h = dofile("tests/helpers.lua")
local snacks = h.plugin_opts("snacks.nvim")
local explorer = assert(snacks.picker and snacks.picker.sources and snacks.picker.sources.explorer)

h.eq(explorer.hidden, true, "Explorer shows dotfiles")
h.eq(explorer.ignored, true, "Explorer shows Git-ignored entries")
h.eq(explorer.git_status, true, "Explorer shows Git status")
h.eq(explorer.git_untracked, true, "Explorer shows untracked status")
h.eq(explorer.layout.layout.position, "left", "Explorer remains on the left")

print("explorer_spec: ok")
```

- [ ] **Step 3: Run the Explorer test and verify it fails**

```bash
XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
  nvim --headless -u ./init.lua -i NONE -l tests/explorer_spec.lua
```

Expected: non-zero exit with `Explorer shows dotfiles: expected true, got nil`.

- [ ] **Step 4: Create the focused Explorer plugin spec**

Create `lua/plugins/explorer.lua`:

```lua
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            git_status = true,
            git_untracked = true,
            layout = {
              layout = {
                position = "left",
              },
            },
          },
        },
      },
    },
  },
}
```

- [ ] **Step 5: Remove Explorer ownership from the general UI module**

Remove the `opts.picker = { ... }` block from the Snacks spec in `lua/plugins/ui.lua`. The function must begin directly with:

```lua
opts = function(_, opts)
  opts.dashboard.preset.header = [[
```

- [ ] **Step 6: Run the Explorer test and formatting checks**

```bash
stylua --check lua/plugins/explorer.lua lua/plugins/ui.lua tests/helpers.lua tests/explorer_spec.lua
XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
  nvim --headless -u ./init.lua -i NONE -l tests/explorer_spec.lua
```

Expected: Stylua exits zero and Neovim prints `explorer_spec: ok`.

- [ ] **Step 7: Commit the Explorer change**

```bash
git add lua/plugins/explorer.lua lua/plugins/ui.lua tests/helpers.lua tests/explorer_spec.lua
git commit -m "feat: configure Snacks explorer visibility"
```

### Task 2: In-editor Markdown Formula Rendering

**Files:**
- Create: `tests/markdown_render_spec.lua`
- Create: `lua/plugins/markdown_render.lua`

- [ ] **Step 1: Write the failing merged-option and formula-render test**

Create `tests/markdown_render_spec.lua`:

```lua
local h = dofile("tests/helpers.lua")

local markdown = h.plugin_opts("render-markdown.nvim")
h.eq(markdown.render_modes, { "n", "c", "t" }, "Insert mode keeps editable LaTeX source")
h.eq(markdown.latex and markdown.latex.enabled, true, "LaTeX rendering is enabled explicitly")
h.eq(markdown.latex and markdown.latex.converter, "utftex", "utftex is the selected converter")
h.eq(markdown.latex and markdown.latex.position, "above", "multiline formulas render above source")

local treesitter = h.plugin_opts("nvim-treesitter")
h.contains(treesitter.ensure_installed, "latex", "LaTeX Treesitter parser is reproducible")
h.eq(vim.fn.executable("utftex"), 1, "utftex is executable")

local converted = vim.system({ "utftex" }, { stdin = [[E = mc^2]], text = true }):wait()
h.eq(converted.code, 0, "utftex converts a formula")
h.truthy(converted.stdout and converted.stdout:find("²", 1, true), "utftex emits Unicode math")

require("lazy").load({ plugins = { "render-markdown.nvim" } })
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buf)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
  "# Formula fixture",
  "",
  "Inline: $E = mc^2$",
  "",
  "$$",
  [[\frac{1}{2} + \int_0^1 x^2\,dx]],
  "$$",
})

local eventignore = vim.o.eventignore
vim.o.eventignore = "all"
vim.bo[buf].filetype = "markdown"
vim.o.eventignore = eventignore

require("render-markdown").render({ buf = buf, win = 0 })
local ns = assert(vim.api.nvim_get_namespaces()["render-markdown.nvim"])
local rendered = vim.wait(2000, function()
  local marks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })
  for _, mark in ipairs(marks) do
    local details = mark[4]
    if details and (details.virt_lines or details.virt_text) and vim.inspect(details):find("RenderMarkdownMath") then
      return true
    end
  end
  return false
end, 20)
h.truthy(rendered, "render-markdown creates Unicode formula marks")

print("markdown_render_spec: ok")
```

- [ ] **Step 2: Run the Markdown test and verify it fails**

```bash
XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
  nvim --headless -u ./init.lua -i NONE -l tests/markdown_render_spec.lua
```

Expected: non-zero exit with `LaTeX rendering is enabled explicitly: expected true, got nil`.

- [ ] **Step 3: Create the focused Markdown rendering plugin spec**

Create `lua/plugins/markdown_render.lua`:

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "latex" },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      render_modes = { "n", "c", "t" },
      latex = {
        enabled = true,
        converter = "utftex",
        position = "above",
      },
    },
  },
}
```

Do not modify `lua/plugins/markdown_writer.lua`; browser preview and authoring keys remain independent.

- [ ] **Step 4: Run the Markdown test and formatting checks**

```bash
stylua --check lua/plugins/markdown_render.lua tests/markdown_render_spec.lua
XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
  nvim --headless -u ./init.lua -i NONE -l tests/markdown_render_spec.lua
```

Expected: Stylua exits zero and Neovim prints `markdown_render_spec: ok`.

- [ ] **Step 5: Confirm existing Markdown mappings remain declared**

```bash
rg -n '<leader>(um|mp|ml|mo)' lua/plugins/markdown_writer.lua \
  ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/lang/markdown.lua
```

Expected: declarations for `<leader>mp`, `<leader>ml`, `<leader>mo`, and LazyVim's `<leader>um` render toggle.

- [ ] **Step 6: Commit the Markdown rendering change**

```bash
git add lua/plugins/markdown_render.lua tests/markdown_render_spec.lua
git commit -m "feat: render Markdown formulas with utftex"
```

### Task 3: Runtime-calibrated Shortcut Reference

**Files:**
- Create: `tests/keymap_inventory.lua`
- Create: `tests/keymap_doc_spec.lua`
- Modify: `keymap.md:1-252`

- [ ] **Step 1: Add a repeatable runtime mapping inventory**

Create `tests/keymap_inventory.lua`:

```lua
local rows = {}

local function collect(scope, mode, maps)
  for _, map in ipairs(maps) do
    if map.desc and map.desc ~= "" then
      rows[#rows + 1] = table.concat({ scope, mode, map.lhs, map.desc }, "\t")
    end
  end
end

vim.wait(500, function()
  return vim.g.did_very_lazy == true
end, 20)
for _, mode in ipairs({ "n", "i", "x", "t" }) do
  collect("global", mode, vim.api.nvim_get_keymap(mode))
end

local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buf)
vim.bo[buf].filetype = "markdown"
vim.wait(1000)
for _, mode in ipairs({ "n", "i", "x" }) do
  collect("markdown", mode, vim.api.nvim_buf_get_keymap(buf, mode))
end

table.sort(rows)
print(table.concat(rows, "\n"))
```

- [ ] **Step 2: Capture the inventory for the audit**

```bash
XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
  nvim --headless -u ./init.lua -i NONE -l tests/keymap_inventory.lua \
  > /tmp/nvim-keymaps.tsv
rg -n 'Explorer|Git Status|Buffers|Markdown|Render Markdown|Picker|Telescope|Neo-tree' \
  /tmp/nvim-keymaps.tsv
```

Expected: Snacks mappings and Markdown buffer mappings are present; `<leader>ge` and `<leader>be` are absent.

- [ ] **Step 3: Add the failing documentation regression test**

Create `tests/keymap_doc_spec.lua`:

```lua
local h = dofile("tests/helpers.lua")
local content = table.concat(vim.fn.readfile("keymap.md"), "\n")

local required = {
  "### Snacks Picker / 搜索",
  "### Snacks Explorer",
  "| `<leader>um` | n | 切换 Neovim 内 Markdown 渲染 |",
  "| `<leader>gs` | n | Git 状态 |",
  "| `<leader>fb` | n | Buffer 列表 |",
  "| `H` | Explorer | 切换点文件显示 |",
  "| `I` | Explorer | 切换 Git 忽略项显示 |",
  "`libtexprintf`",
  "`utftex`",
}
for _, text in ipairs(required) do
  h.truthy(content:find(text, 1, true), "missing keymap documentation: " .. text)
end

local forbidden = {
  "### Telescope / 搜索",
  "### Neo-tree",
  "| `<leader>ge` |",
  "| `<leader>be` |",
  "| `<leader>sr` |",
  "| `<leader>so` |",
}
for _, text in ipairs(forbidden) do
  h.truthy(not content:find(text, 1, true), "stale keymap documentation: " .. text)
end

for _, lhs in ipairs({ "<leader>E", "<leader>gs", "<leader>fb" }) do
  local mapping = vim.fn.maparg(lhs, "n", false, true)
  h.truthy(type(mapping) == "table" and not vim.tbl_isempty(mapping), "runtime mapping is missing: " .. lhs)
end

print("keymap_doc_spec: ok")
```

- [ ] **Step 4: Run the documentation test and verify it fails**

```bash
XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
  nvim --headless -u ./init.lua -i NONE -l tests/keymap_doc_spec.lua
```

Expected: non-zero exit reporting the first missing Snacks or Markdown documentation entry.

- [ ] **Step 5: Reconcile the Markdown section**

Keep all current authoring and spell rows. Add:

```markdown
| `<leader>um` | n | 切换 Neovim 内 Markdown 渲染 |
| `<leader>cp` | n | 切换 Markdown 浏览器预览（LazyVim） |
```

Change `<leader>mp` to `切换 Markdown 浏览器预览（私密窗口）`, then add:

```markdown
> 普通模式下，`$...$` 与 `$$...$$` 通过 `utftex` 渲染为 Unicode；插入模式显示 LaTeX 源码。需要系统安装 `libtexprintf`，可用 `:checkhealth render-markdown` 检查。
```

- [ ] **Step 6: Reconcile Git and Snacks Picker sections**

Add these active rows to `### Git`:

```markdown
| `<leader>gg` | n | Lazygit（项目根目录） |
| `<leader>gG` | n | Lazygit（当前工作目录） |
| `<leader>gd` | n | Git Diff hunks |
| `<leader>gD` | n | Git Diff（相对 origin） |
| `<leader>gs` | n | Git 状态 |
| `<leader>gS` | n | Git Stash |
```

Rename `### Telescope / 搜索` to `### Snacks Picker / 搜索`, remove stale `<leader>sr` and `<leader>so`, and use this table:

```markdown
| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader><space>` | n | 查找文件（项目根目录） |
| `<leader>ff` / `<leader>fF` | n | 查找文件（项目根目录 / cwd） |
| `<leader>fg` | n | 查找 Git 文件 |
| `<leader>fr` / `<leader>fR` | n | 最近文件（全局 / cwd） |
| `<leader>fb` | n | Buffer 列表 |
| `<leader>fB` | n | 全部 Buffer |
| `<leader>fc` | n | 查找 Neovim 配置文件 |
| `<leader>fp` | n | 项目列表 |
| `<leader>sg` / `<leader>sG` | n | 全局搜索（项目根目录 / cwd） |
| `<leader>sw` / `<leader>sW` | n, x | 搜索单词或选区（项目根目录 / cwd） |
| `<leader>sb` | n | 搜索当前 Buffer 行 |
| `<leader>sB` | n | 搜索已打开 Buffers |
| `<leader>s\"` | n | 搜索寄存器 |
| `<leader>s/` | n | 搜索历史 |
| `<leader>sc` / `<leader>sC` | n | 命令历史 / 命令列表 |
| `<leader>sd` / `<leader>sD` | n | 全部诊断 / 当前 Buffer 诊断 |
| `<leader>sh` | n | 搜索帮助页 |
| `<leader>sk` | n | 搜索快捷键 |
| `<leader>sm` | n | 搜索标记 |
| `<leader>sM` | n | 搜索 Man 页 |
| `<leader>sq` | n | 搜索 Quickfix |
| `<leader>sR` | n | 恢复上次 Picker |
| `<leader>su` | n | Undo 历史 |
| `<leader>/` | n | 全局搜索（项目根目录） |
| `<leader>:` | n | 命令历史 |
| `<leader>,` | n | Buffer 列表 |
```

- [ ] **Step 7: Replace the Neo-tree section with Snacks Explorer controls**

Rename `### Neo-tree` to `### Snacks Explorer` and use:

```markdown
| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>e` / `<leader>fe` | n | 文件浏览器（项目根目录） |
| `<leader>E` / `<leader>fE` | n | 文件浏览器（当前工作目录） |
| `<CR>` / `l` | Explorer | 打开文件或展开目录 |
| `h` | Explorer | 收起目录 |
| `<BS>` | Explorer | 返回上级目录 |
| `H` | Explorer | 切换点文件显示 |
| `I` | Explorer | 切换 Git 忽略项显示 |
| `[g` / `]g` | Explorer | 上一个 / 下一个 Git 变更 |
| `a` | Explorer | 新建文件或目录 |
| `r` | Explorer | 重命名 |
| `d` | Explorer | 删除 |
| `c` / `m` | Explorer | 复制 / 移动 |
| `P` | Explorer | 切换预览 |
| `u` | Explorer | 刷新文件树 |
```

Delete stale `<leader>ge` and `<leader>be`. Keep Bufferline and Flash rows only after confirming them in `/tmp/nvim-keymaps.tsv`.

- [ ] **Step 8: Audit every remaining existing row**

Search every remaining documented left-hand side in `/tmp/nvim-keymaps.tsv`. Correct mode or description drift and delete a row only when absent from both runtime output and the relevant LSP mapping source. Preserve LSP-on-attach rows using `lazyvim/plugins/lsp/keymaps.lua` and `lazyvim/plugins/extras/editor/snacks_picker.lua` as their source of truth.

- [ ] **Step 9: Run documentation and formatting checks**

```bash
stylua --check tests/keymap_inventory.lua tests/keymap_doc_spec.lua
XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
  nvim --headless -u ./init.lua -i NONE -l tests/keymap_doc_spec.lua
rg -n 'Telescope|Neo-tree|<leader>ge|<leader>be' keymap.md
```

Expected: Stylua exits zero, Neovim prints `keymap_doc_spec: ok`, and `rg` returns no matches.

- [ ] **Step 10: Commit the shortcut reference**

```bash
git add keymap.md tests/keymap_inventory.lua tests/keymap_doc_spec.lua
git commit -m "docs: reconcile Neovim shortcut reference"
```

### Task 4: Full Integration Verification

**Files:**
- Verify: `lua/plugins/explorer.lua`
- Verify: `lua/plugins/markdown_render.lua`
- Verify: `lua/plugins/ui.lua`
- Verify: `keymap.md`
- Verify: `tests/*.lua`

- [ ] **Step 1: Run all focused runtime tests**

```bash
for spec in tests/explorer_spec.lua tests/markdown_render_spec.lua tests/keymap_doc_spec.lua; do
  XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
    nvim --headless -u ./init.lua -i NONE -l "$spec" || exit 1
done
```

Expected: all three scripts print their `: ok` line and exit zero.

- [ ] **Step 2: Run a clean headless startup check**

```bash
XDG_STATE_HOME=/tmp/nvim-test-state XDG_CACHE_HOME=/tmp/nvim-test-cache \
  nvim --headless -u ./init.lua -i NONE "+lua print('startup: ok')" +qa
```

Expected: `startup: ok` with no Lua stack trace.

- [ ] **Step 3: Run formatting and whitespace checks**

```bash
stylua --check lua/plugins/explorer.lua lua/plugins/markdown_render.lua lua/plugins/ui.lua tests/*.lua
git diff --check HEAD
```

Expected: both commands exit zero with no output.

- [ ] **Step 4: Inspect final scope and commits**

```bash
git status --short
git log --oneline --decorate -5
```

Expected: no staged changes; unrelated pre-existing untracked files may remain. The log contains separate Explorer, Markdown rendering, and shortcut-reference commits after the design/plan documentation commits.
