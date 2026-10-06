# SceAce Neovim

基于 [LazyVim](https://github.com/LazyVim/LazyVim) 二次开发的一套个人 Neovim 配置，面向 **C/C++ / Rust / Python / Java / 前端 / Markdown 写作** 日常开发。

- `<leader>` = 空格键
- 主题：`catppuccin-macchiato`（透明背景）
- 常用快捷键：见 [`keymap.md`](./keymap.md)（含全部键位，常用在前）

---

## 环境要求

| 依赖 | 说明 |
|------|------|
| Neovim | `>= 0.11.2`（本机 0.12.5 验证） |
| git / curl | 拉取插件 |
| ripgrep (`rg`) | 搜索 |
| fd | 文件查找 |
| C 编译器 | [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) 编译解析器 |
| node / npm | 部分 LSP 与工具 |
| go | 部分工具（如 `gopls`） |

可选（启用对应功能时）：

- `codex` CLI、`pi` CLI：AI 助手（见下方「AI」）
- `clangd` / `clang-format` / `clang-tidy`：C/C++
- `cppman`、`man`：C/C++ 手册查询
- `stylua`：Lua 格式化
- `tmux` / `zellij`：AI CLI 会话持久化（可选）

---

## 目录结构

```
.
├── init.lua                    # 入口
├── lazyvim.json                # 启用的 LazyVim extras
├── lazy-lock.json              # 插件版本锁定
├── stylua.toml                 # Lua 格式化配置
├── keymap.md                   # 快捷键大全
└── lua/
    ├── config/
    │   ├── lazy.lua            # lazy.nvim 引导
    │   ├── options.lua         # vim 选项（缩进 4、winbar 等）
    │   ├── autocmds.lua        # 自动命令（Markdown 写作等）
    │   └── keymaps.lua         # 原生键位
    ├── plugins/                # 插件配置（按功能分文件）
    │   ├── ui.lua              # Snacks explorer + lualine + explorer 隐藏切换
    │   ├── editor.lua          # toggleterm、navic
    │   ├── coding.lua          # 补全/LSP 开关、目录格式化
    │   ├── blink.lua           # blink.cmp（VSCode 风格补全）
    │   ├── c-cpp.lua           # clangd 参数、clangd 查询、cppman、man 搜索
    │   ├── runner.lua          # 多语言运行器 + Overseer
    │   ├── markdown_writer.lua # Markdown 写作（大纲/预览/贴图）
    │   ├── translate.lua       # 翻译
    │   ├── c3.lua              # C3 语言支持
    │   ├── colorscheme.lua     # 配色
    │   ├── util.lua            # marks.nvim
    │   ├── mcp.lua             # mcphub（默认禁用）
    │   └── ai.lua              # sidekick.nvim（codex / pi）
    ├── custom/
    │   ├── winbar.lua          # 自绘 winbar
    │   ├── explorer.lua        # explorer 隐藏文件切换
    │   └── man_functions.lua   # macOS man 手册模糊搜索
    └── overseer/templates/
        └── tomcat.lua          # Tomcat 任务模板
```

---

## 功能特性

### 基础框架

- **LazyVim extras**（见 `lazyvim.json`）：Snacks picker/explorer、blink.cmp、mini.surround、yanky、harpoon2、illuminate、inc-rename、navic、treesitter-context、mini.hipatterns，以及 astro / clangd / cmake / docker / git / json / markdown / python / rust / svelte / tailwind / tex / toml / typescript / yaml 等语言支持。
- 缩进 **4 空格**，关闭相对行号，自定义 winbar（含 LSP breadcrumb）。

### 补全

- **blink.cmp**，VSCode 风格：
  - 自动弹出菜单 + Ghost text 预览
  - 候选项显示图标 / 名称 / 类型
  - 自动显示文档（200ms 延迟）与函数签名帮助
  - 补全来源：`lsp` / `path` / `snippets`
  - 键位：`<Tab>` 接受、`<C-e>` 取消、`<C-n>/<C-p>` 选择、`<C-Space>` 手动触发

### LSP / 格式化

- **Mason** 管理 LSP / DAP / Linter / Formatter。
- **conform.nvim** 格式化；`<leader>cP` 可批量格式化整个目录（跳过 `node_modules`、`build`、`.git` 等）。
- 开关：`<leader>cc` 切换补全，`<leader>cL` 切换所有 LSP 客户端。
- 启用 **C3** 语言（`c3_lsp` + treesitter）。

### C / C++ 增强

- clangd 面向大项目的参数：`--background-index --clang-tidy --header-insertion=iwyu --completion-style=detailed --pch-storage=memory`。
- **clangd_extensions** 查询键位（`<leader>cK` 前缀）：符号详情、类型层次、AST、内存占用。
- `cppman` 搜索 C++ 标准库（`<leader>cKc`）。
- 自研 **man 手册模糊搜索**（`<leader>cKm`）：把 macOS `whatis` 里挤在一行的函数名拆成独立条目，解决内置 man picker 体验差的问题。

### 文件 / 搜索

- **Snacks picker**（`<leader>f*` 文件、`<leader>s*` 搜索）。
- **Snacks explorer** 文件浏览器（`<leader>e`）：
  - 默认隐藏 `.` 开头与 `.gitignore` 忽略的文件
  - `<leader>eH` 或在浏览器内按 `H` 一键切换显示 / 隐藏

### 运行 / 终端

- `<leader>rr` 一键运行当前文件，支持 **C / C++ / Rust / Python / Java**；
  编译错误 / 警告进 quickfix（`<CR>` 跳转），程序输出在终端。
- **Overseer** 项目任务（`<leader>ro/rt/rl`），内置 Tomcat 模板。
- **toggleterm** 终端（`<leader>tt/th/tv/tf`）。

### Markdown 写作

- **aerial** 大纲侧边栏（`<leader>ml/mo`）。
- **markdown-preview.nvim** 预览，使用 **私密浏览器**（Chrome/Firefox 无痕）（`<leader>mp`）。
- **img-clip** 粘贴剪贴板图片，自动存到 `assets/`（时间戳命名）并插入相对路径（`<leader>mi`）。
- 代码块 `<leader>mk`、链接 `<leader>mL`、拼写检查与建议 `<leader>ms/m= /m1/ma/mw`。

### 翻译

- **translate.nvim**：`<leader>tz` 中、`<leader>te` 英、`<leader>tw` 单词（默认 Google，可换 DeepL）。

### AI（sidekick.nvim）

- 直接驱动本机 **codex** 与 **pi** CLI，**复用它们自己的会话历史**。
- `<leader>ac/aC` Codex 新会话 / 恢复；`<leader>aP/aR` Pi 新会话 / 恢复。
- 详见下方 [AI 配置](#ai-配置)。

### 其他

- **marks.nvim** 书签、**harpoon** 文件书签、**illuminate** 同名高亮、**treesitter-context** 粘性上下文。
- **mcp**（`mcphub.nvim`）默认禁用，需要时在 `lua/plugins/mcp.lua` 打开。

---

## 安装与使用

```bash
# 备份旧配置后
git clone <this-repo> ~/.config/nvim
nvim
```

首次启动会自动安装 `lazy.nvim` 与全部插件；`lazy-lock.json` 已锁定版本。

常用命令：

- `:Lazy` 打开插件管理
- `:LazyExtras` 管理 LazyVim extras
- `:LazyHealth` / `:checkhealth` 体检
- `:Mason` 管理 LSP / 工具

---

## AI 配置

AI 由 [`sidekick.nvim`](https://github.com/folke/sidekick.nvim) 提供，**不保存任何密钥到本仓库**。

### 两个 CLI

| 工具 | 配置来源 | 会话目录 | 快捷键 |
|------|----------|----------|--------|
| `codex`（GPT） | `~/.codex/config.toml` | `~/.codex/sessions` | `<leader>ac` / `<leader>aC` |
| `pi`（DeepSeek） | `~/.pi/agent/*.json` | `~/.pi/agent/sessions` | `<leader>aP` / `<leader>aR` |

- **新会话**：直接启动 CLI。
- **恢复会话**：启动即进入 CLI 自带的 session picker，可继续之前的对话。
- 因为 sidekick 运行的就是 CLI 本身，所以历史 / 上下文与你在终端里用 CLI 完全一致。

### 关于 `pi`

`pi` 在本机是 zsh 函数（包装 `~/My_github/pi/pi-test.sh`），并非常规可执行文件。
`lua/plugins/ai.lua` 已把 sidekick 的 `pi` 工具 `cmd` 指向该脚本；若路径变化，改这一处即可。

### 可选：会话持久化

sidekick 的「跨重启保持 / attach 会话」依赖 `tmux` 或 `zellij`。安装后在 `lua/plugins/ai.lua` 打开：

```lua
opts = {
  cli = {
    mux = { enabled = true, backend = "tmux" },
  },
}
```

---

## 快捷键

完整键位见 **[`keymap.md`](./keymap.md)**（常用在前，含 LazyVim 默认 + 本仓库自定义）。

几个最常用的：

| 快捷键 | 说明 |
|--------|------|
| `<leader><space>` | 查找文件 |
| `<leader>/` | 全局搜索 |
| `<leader>e` | 文件浏览器 |
| `<leader>eH` | 切换 dotfiles / gitignore 显示 |
| `gd` / `gr` / `K` | 定义 / 引用 / 悬停 |
| `<leader>ca` / `<leader>cr` / `<leader>cf` | 代码操作 / 重命名 / 格式化 |
| `<leader>ac` / `<leader>aP` | Codex / Pi 新会话 |
| `<leader>rr` | 运行当前文件 |
| `<leader>tt` | 终端 |

---

## 说明

- 所有自定义逻辑都在 `lua/plugins/` 与 `lua/custom/`，尽量不改 LazyVim 本体，方便后续更新。
- 密钥、代理地址等敏感信息请放在家目录配置或环境变量中，**不要提交到仓库**。

## 许可

[Apache License 2.0](./LICENSE)
