# Neovim 快捷键参考

> `<leader>` 默认为空格键

---

## 代码 / LSP / 格式化

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>cc` | n | 切换当前 buffer 补全（blink.cmp） |
| `<leader>cL` | n | 切换所有 LSP 客户端开关 |
| `<leader>cP` | n | 格式化整个目录（conform.nvim） |

---

## 运行

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>rr` | n | 运行当前文件（C/C++/Rust/Python/Java） |
| `<leader>ro` | n | Overseer：运行项目任务 |
| `<leader>rt` | n | Overseer：任务列表 |
| `<leader>rl` | n | Overseer：重跑上次任务 |

> 编译错误/警告显示在 quickfix 窗口，`<CR>` 跳转到对应行，`:cclose` 关闭

---

## 终端

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>tt` | n | 切换终端显示/隐藏 |
| `<leader>th` | n | 水平终端 |
| `<leader>tv` | n | 垂直终端 |
| `<leader>tf` | n | 浮动终端 |

> 终端内按 `<C-\><C-n>` 进入普通模式，可滚动查看历史

---

## 补全（blink.cmp）

| 快捷键 | 说明 |
|--------|------|
| `<Tab>` | 接受补全 / 跳转 snippet 占位符 / 缩进 |
| `<S-Tab>` | 反向跳转 snippet 占位符 |
| `<CR>` | 普通换行（不接受补全） |
| `<C-Space>` | 手动触发补全菜单 |
| `<C-e>` | 取消补全 |
| `<C-n>` / `<Down>` | 选择下一个候选 |
| `<C-p>` / `<Up>` | 选择上一个候选 |
| `<C-b>` | 文档窗口向上滚动 |
| `<C-f>` | 文档窗口向下滚动 |
| `<C-k>` | 手动触发/隐藏签名帮助 |

---

## Markdown

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>mk` | n | 插入代码块 |
| `<leader>mL` | n | 插入链接 `[]()` |
| `<leader>mi` | n | 粘贴剪贴板图片 / 从文件选择图片 |
| `<leader>um` | n | 切换 Neovim 内 Markdown 渲染 |
| `<leader>cp` | n | LazyVim 浏览器预览 |
| `<leader>mp` | n | 私密窗口浏览器预览 |
| `<leader>ml` | n | 切换大纲侧边栏（aerial） |
| `<leader>mo` | n | 聚焦大纲侧边栏 |
| `<leader>ms` | n | 切换拼写检查 |
| `<leader>m=` | n | 拼写建议列表 |
| `<leader>m1` | n | 应用第一个拼写建议 |
| `<leader>ma` | n | 将单词加入词典 |
| `<leader>mw` | n | 标记单词为拼写错误 |

> 普通模式下，`$...$` 和 `$$...$$` 公式由 `utftex` 转为 Unicode 渲染；插入模式显示 LaTeX 源码。公式渲染需要 `libtexprintf`，可运行 `:checkhealth render-markdown` 检查依赖。

---

## 翻译 (translate.nvim)

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>tz` | n | 翻译当前行 → 中文 |
| `<leader>te` | n | 翻译当前行 → 英文 |
| `<leader>tz` | x | 翻译选中内容 → 中文 |
| `<leader>te` | x | 翻译选中内容 → 英文 |
| `<leader>tw` | n | 翻译光标下单词 → 中文 |

---

## LazyVim 默认快捷键

### 通用

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `j` / `<Down>` | n, x | 向下移动（兼容折叠行） |
| `k` / `<Up>` | n, x | 向上移动（兼容折叠行） |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | n | 跳到左/下/上/右窗口 |
| `<C-Up>` / `<C-Down>` | n | 增加/减少窗口高度 |
| `<C-Left>` / `<C-Right>` | n | 减少/增加窗口宽度 |
| `<A-j>` / `<A-k>` | n, i, x | 上下移动行 |
| `<S-h>` / `<S-l>` | n | 上/下一个 Buffer |
| `[b` / `]b` | n | 上/下一个 Buffer |
| `<leader>bb` | n | 切换到其他 Buffer |
| `<leader>bd` | n | 删除 Buffer |
| `<leader>bo` | n | 删除其他 Buffer |
| `<leader>bD` | n | 删除 Buffer 和窗口 |
| `<Esc>` | i, n, s | 退出并清除搜索高亮 |
| `<C-s>` | i, x, n, s | 保存文件 |
| `<leader>fn` | n | 新建文件 |
| `<leader>l` | n | 打开 Lazy |
| `<leader>L` | n | LazyVim 更新日志 |
| `<leader>qq` | n | 退出全部 |
| `<leader>xl` | n | Location List |
| `<leader>xq` | n | Quickfix List |
| `[q` / `]q` | n | 上/下一个 Trouble 或 Quickfix 项 |
| `<leader>-` | n | 向下分割窗口 |
| `<leader>\|` | n | 向右分割窗口 |
| `<leader>wd` | n | 删除窗口 |
| `<leader>wm` | n | 切换窗口缩放 |
| `<leader>ft` | n | 终端（根目录） |
| `<leader>fT` | n | 终端（cwd） |
| `<C-/>` | n, t | 终端（根目录） |
| `<leader><tab><tab>` | n | 新建标签页 |
| `<leader><tab>]` / `<leader><tab>[` | n | 下/上一个标签页 |
| `<leader><tab>d` | n | 关闭标签页 |
| `<leader><tab>o` | n | 关闭其他标签页 |
| `<leader><tab>f` | n | 第一个标签页 |
| `<leader><tab>l` | n | 最后一个标签页 |

### UI 切换

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>uf` / `<leader>uF` | n | 切换自动格式化（全局/Buffer） |
| `<leader>us` | n | 切换拼写检查 |
| `<leader>uw` | n | 切换自动换行 |
| `<leader>ul` / `<leader>uL` | n | 切换行号/相对行号 |
| `<leader>ud` | n | 切换诊断 |
| `<leader>uc` | n | 切换 Conceal 级别 |
| `<leader>ub` | n | 切换深色背景 |
| `<leader>uT` | n | 切换 Treesitter 高亮 |
| `<leader>ug` | n | 切换缩进引导线 |
| `<leader>uh` | n | 切换内联提示 |
| `<leader>uS` | n | 切换平滑滚动 |
| `<leader>uz` | n | 切换禅模式 |
| `<leader>uZ` | n | 切换缩放模式 |
| `<leader>uD` | n | 切换 Dimming |
| `<leader>ua` | n | 切换动画 |
| `<leader>ui` | n | 检查光标位置 |
| `<leader>uI` | n | 检查语法树 |

### LSP

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `gd` | n | 跳到定义 |
| `gD` | n | 跳到声明 |
| `gr` | n | 查看引用 |
| `gI` | n | 跳到实现 |
| `gy` | n | 跳到类型定义 |
| `K` | n | 悬停提示 |
| `gK` | n | 签名帮助 |
| `<C-k>` | i | 签名帮助 |
| `<leader>cl` | n | LSP 信息 |
| `<leader>ca` | n, x | 代码操作 |
| `<leader>cr` | n | 重命名 |
| `<leader>cR` | n | 重命名文件 |
| `<leader>cA` | n | 源操作 |
| `<leader>cf` | n, x | 格式化 |
| `<leader>cd` | n | 行诊断信息 |
| `<leader>cF` | n, x | 格式化注入语言 |
| `]d` / `[d` | n | 下/上一个诊断 |
| `]e` / `[e` | n | 下/上一个错误 |
| `]w` / `[w` | n | 下/上一个警告 |
| `]]` / `[[` | n | 下/上一个引用 |
| `<leader>ss` | n | LSP 符号 |
| `<leader>sS` | n | LSP 工作区符号 |
| `gai` / `gao` | n | 传入/传出调用 |

### Git

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>gb` | n | Git Blame 当前行 |
| `<leader>gf` | n | 当前文件 Git 历史 |
| `<leader>gl` | n | Git 日志 |
| `<leader>gL` | n | Git 日志（cwd） |
| `<leader>gB` | n, x | Git 浏览（打开） |
| `<leader>gY` | n, x | Git 浏览（复制链接） |
| `<leader>gg` | n | Lazygit（项目根目录） |
| `<leader>gG` | n | Lazygit（cwd） |
| `<leader>gd` | n | Git Diff（hunks） |
| `<leader>gD` | n | Git Diff（相对 origin） |
| `<leader>gs` | n | Git 状态 |
| `<leader>gS` | n | Git Stash |

### Snacks Picker / 搜索

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader><space>` | n | 查找文件（根目录） |
| `<leader>ff` | n | 查找文件（根目录） |
| `<leader>fF` | n | 查找文件（cwd） |
| `<leader>fg` | n | 查找 Git 跟踪文件 |
| `<leader>fr` | n | 最近文件 |
| `<leader>fR` | n | 最近文件（cwd） |
| `<leader>fb` | n | Buffer 列表 |
| `<leader>fB` | n | Buffer 列表（含隐藏和无文件 Buffer） |
| `<leader>fc` | n | 查找 Neovim 配置文件 |
| `<leader>fp` | n | 项目列表 |
| `<leader>sg` | n | Grep（根目录） |
| `<leader>sG` | n | Grep（cwd） |
| `<leader>sw` | n, x | 搜索光标下单词或选区（根目录） |
| `<leader>sW` | n, x | 搜索光标下单词或选区（cwd） |
| `<leader>sb` | n | 搜索当前 Buffer 行 |
| `<leader>sB` | n | Grep 已打开的 Buffers |
| `<leader>s"` | n | 搜索寄存器 |
| `<leader>s/` | n | 搜索历史 |
| `<leader>sc` | n | 搜索命令历史 |
| `<leader>sC` | n | 搜索命令 |
| `<leader>sd` | n | 搜索诊断 |
| `<leader>sD` | n | 搜索当前 Buffer 诊断 |
| `<leader>sh` | n | 搜索帮助页 |
| `<leader>sk` | n | 搜索快捷键 |
| `<leader>sm` | n | 搜索标记 |
| `<leader>sM` | n | 搜索 Man 页 |
| `<leader>sq` | n | 搜索 Quickfix |
| `<leader>sR` | n | 恢复上次 Picker |
| `<leader>su` | n | Undo 历史 |
| `<leader>/` | n | Grep（根目录） |
| `<leader>:` | n | 命令历史 |
| `<leader>,` | n | Buffer 列表 |

### 搜索与替换

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>sr` | n, x | 跨文件搜索与替换（grug-far.nvim） |

### bufferline.nvim

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>bj` | n | 选择 Buffer |
| `<leader>bl` | n | 删除左侧 Buffers |
| `<leader>br` | n | 删除右侧 Buffers |
| `<leader>bp` | n | 切换固定 |
| `<leader>bP` | n | 删除非固定 Buffers |
| `[B` / `]B` | n | 向前/后移动 Buffer |

### flash.nvim

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `s` | n, x, o | Flash 跳转 |
| `S` | n, x, o | Flash Treesitter 跳转 |
| `r` | o | Remote Flash |
| `R` | o, x | Treesitter 搜索 |
| `<C-s>` | c | 切换 Flash 搜索 |

### Snacks Explorer

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>e` | n | Explorer（根目录） |
| `<leader>fe` | n | Explorer（根目录） |
| `<leader>E` | n | Explorer（cwd） |
| `<leader>fE` | n | Explorer（cwd） |
| `<CR>` / `l` | Explorer | 打开文件或展开目录 |
| `h` | Explorer | 折叠目录 |
| `<BS>` | Explorer | 返回父目录 |
| `H` | Explorer | 切换点文件显示 |
| `I` | Explorer | 切换 Git 忽略项显示 |
| `[g` / `]g` | Explorer | 上一个/下一个 Git 变更 |
| `a` | Explorer | 新建文件或目录 |
| `r` | Explorer | 重命名 |
| `d` | Explorer | 删除 |
| `c` | Explorer | 复制 |
| `m` | Explorer | 移动 |
| `P` | Explorer | 切换预览 |
| `u` | Explorer | 刷新 |
