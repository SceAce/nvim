# Neovim 快捷键参考

> `<leader>` = 空格键（Space）；`<localLeader>` = `\`
> 模式说明：`n` 普通 / `i` 插入 / `v` 可视 / `x` 可视 + 选择 / `o` 操作符 / `t` 终端 / `c` 命令行
> 忘了按键？按 `<leader>` 会弹出 which-key 分组提示，按 `?` 或 `<leader>?` 查看当前缓冲区所有快捷键。

---

## ⭐ 常用（先掌握这些）

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader><space>` | n | 查找文件（根目录） |
| `<leader>ff` | n | 查找文件（根目录） |
| `<leader>fr` | n | 最近打开的文件 |
| `<leader>/` | n | 全局搜索（根目录） |
| `<leader>sg` | n | 全局搜索（根目录） |
| `<leader>sw` | n / x | 搜索光标下单词 / 选中内容 |
| `<leader>e` | n | 文件浏览器（根目录） |
| `<leader>eH` | n | 一键显示 / 隐藏 dotfiles 与 gitignore 文件 |
| `<leader>,` | n | 切换 Buffer |
| `<leader>bb` | n | 切换到其他 Buffer |
| `<leader>bd` | n | 删除当前 Buffer |
| `<S-h>` / `<S-l>` | n | 上一个 / 下一个 Buffer |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | n | 跳到 左 / 下 / 上 / 右 窗口 |
| `<C-s>` | n / i / v | 保存文件 |
| `<leader>qs` / `<leader>ql` | n | 恢复会话 / 恢复上次会话 |
| `gd` | n | 跳到定义 |
| `gr` | n | 查看引用 |
| `K` | n | 悬停文档 |
| `<leader>ca` | n / x | 代码操作（Code Action） |
| `<leader>cr` | n | 重命名符号 |
| `<leader>cf` | n / x | 格式化 |
| `[d` / `]d` | n | 上 / 下一个诊断 |
| `gcc` | n | 注释 / 取消注释当前行 |
| `s` | n / x / o | Flash 快速跳转 |
| `<leader>ac` / `<leader>aC` | n | Codex 新会话 / 恢复会话 |
| `<leader>aP` / `<leader>aR` | n | Pi 新会话 / 恢复会话 |
| `<leader>rr` | n | 运行当前文件 |
| `<leader>tt` | n | 切换终端显隐 |
| `<leader>uf` | n | 切换自动格式化 |
| `<leader>us` | n | 切换拼写检查 |
| `<C-/>` | n / t | 打开终端（根目录） |
| `<leader>l` | n | 打开 Lazy（插件管理器） |
| `<C-\\><C-n>` | t | 从终端回到普通模式 |

---

## 文件 / 查找 / 浏览器

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader><space>` | n | 查找文件（根目录） |
| `<leader>ff` | n | 查找文件（根目录） |
| `<leader>fF` | n | 查找文件（当前目录 cwd） |
| `<leader>fg` | n | 查找 Git 文件 |
| `<leader>fr` | n | 最近文件 |
| `<leader>fR` | n | 最近文件（cwd） |
| `<leader>fb` | n | Buffer 列表 |
| `<leader>fB` | n | Buffer 列表（含未加载） |
| `<leader>fc` | n | 查找配置文件 |
| `<leader>fp` | n | 项目列表 |
| `<leader>fn` | n | 新建文件 |
| `<leader>ft` | n | 终端（根目录） |
| `<leader>fT` | n | 终端（cwd） |
| `<leader>fe` | n | 文件浏览器（根目录） |
| `<leader>fE` | n | 文件浏览器（cwd） |
| `<leader>e` | n | 文件浏览器（根目录） |
| `<leader>E` | n | 文件浏览器（cwd） |
| `<leader>eH` | n | 切换隐藏文件（dotfiles / gitignore），浏览器内按 `H` 同效 |
| `<leader>:` | n | 命令历史 |
| `<leader>,` | n | 切换 Buffer |
| `` ` `` | n | 切换到上一个 Buffer |

> 文件浏览器默认隐藏 `.` 开头与 `.gitignore` 忽略的文件；`<leader>eH` 一键切换。

---

## 搜索（Snacks picker）

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>/` | n | 全局搜索（根目录） |
| `<leader>sg` | n | 全局搜索（根目录） |
| `<leader>sG` | n | 全局搜索（cwd） |
| `<leader>sw` | n / x | 搜索光标下单词 / 选中内容（根目录） |
| `<leader>sW` | n / x | 搜索光标下单词 / 选中内容（cwd） |
| `<leader>sb` | n | 搜索当前 Buffer 行 |
| `<leader>sB` | n | 搜索已打开的 Buffer |
| `<leader>sc` | n | 搜索命令历史 |
| `<leader>sC` | n | 搜索可用命令 |
| `<leader>sd` | n | 搜索诊断 |
| `<leader>sD` | n | 搜索当前 Buffer 诊断 |
| `<leader>sh` | n | 搜索帮助页 |
| `<leader>sk` | n | 搜索快捷键 |
| `<leader>sm` | n | 搜索标记 |
| `<leader>sM` | n | 搜索 Man 手册页 |
| `<leader>s"` | n | 搜索寄存器 |
| `<leader>s/` | n | 搜索历史 |
| `<leader>sa` | n | 搜索自动命令 |
| `<leader>sH` | n | 搜索高亮组 |
| `<leader>si` | n | 搜索图标 |
| `<leader>sj` | n | 搜索跳转列表 |
| `<leader>sl` | n | Location List |
| `<leader>sq` | n | Quickfix List |
| `<leader>sp` | n | 搜索插件 spec |
| `<leader>sr` | n / x | 搜索并替换（grug-far） |
| `<leader>sR` | n | 恢复上次搜索 |
| `<leader>st` / `<leader>sT` | n | 搜索 Todo / Todo·Fix·Fixme |
| `<leader>su` | n | Undotree（撤销树） |
| `<leader>sn h/l/d/a/t` | n | noice：历史 / 最后消息 / 关闭全部 / 全部 / picker |

---

## Buffer

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<S-h>` / `<S-l>` | n | 上一个 / 下一个 Buffer |
| `[b` / `]b` | n | 上一个 / 下一个 Buffer |
| `[B` / `]B` | n | 向前 / 向后移动当前 Buffer 位置 |
| `<leader>bb` | n | 切换到其他 Buffer |
| `<leader>bd` | n | 删除当前 Buffer |
| `<leader>bD` | n | 删除 Buffer 及其窗口 |
| `<leader>bo` | n | 删除其他 Buffer |
| `<leader>bj` | n | 从列表选择 Buffer |
| `<leader>bl` | n | 删除左侧 Buffer |
| `<leader>br` | n | 删除右侧 Buffer |
| `<leader>bp` | n | 固定 / 取消固定 Buffer |
| `<leader>bP` | n | 删除所有非固定 Buffer |

---

## 窗口 / 标签页

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | n | 跳到 左 / 下 / 上 / 右 窗口 |
| `<C-Up>` / `<C-Down>` | n | 增加 / 减少窗口高度 |
| `<C-Left>` / `<C-Right>` | n | 减少 / 增加窗口宽度 |
| `<leader>-` | n | 向下分割窗口 |
| `<leader>\|` | n | 向右分割窗口 |
| `<leader>wd` | n | 删除窗口 |
| `<leader>wm` | n | 切换窗口缩放（Zoom） |
| `<C-w>d` | n | 显示光标下诊断 |
| `<C-w>` / `<C-w><space>` | n | 窗口 Hydra 模式（持续操作窗口） |
| `<leader><Tab><Tab>` | n | 新建标签页 |
| `<leader><Tab>]` / `<leader><Tab>[` | n | 下一个 / 上一个标签页 |
| `<leader><Tab>d` | n | 关闭标签页 |
| `<leader><Tab>o` | n | 关闭其他标签页 |
| `<leader><Tab>f` | n | 跳到第一个标签页 |
| `<leader><Tab>l` | n | 跳到最后一个标签页 |

---

## 代码 / LSP / 格式化

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `gd` | n | 跳到定义 |
| `gD` | n | 跳到声明 |
| `gr` | n | 查看引用 |
| `gI` | n | 跳到实现 |
| `gy` | n | 跳到类型定义 |
| `gO` | n | 文档符号 |
| `K` | n | 悬停文档 |
| `gK` | n | 签名帮助 |
| `<C-k>` | i | 签名帮助 |
| `gra` | n / v / x | 代码操作 |
| `grn` | n | 重命名符号 |
| `grr` | n | 查看引用 |
| `gri` | n | 查看实现 |
| `grt` | n | 类型定义 |
| `grx` | n | 运行 CodeLens |
| `gai` / `gao` | n | 查看 调用方 / 被调用方 |
| `<leader>ca` | n / x | 代码操作 |
| `<leader>cr` | n | 重命名符号 |
| `<leader>cR` | n | 重命名文件 |
| `<leader>cA` | n | 源操作（Source Action） |
| `<leader>cl` | n | LSP 信息 |
| `<leader>cf` | n / x | 格式化 |
| `<leader>cF` | n / x | 格式化注入语言（如 HTML 内嵌 JS） |
| `<leader>cd` | n | 显示当前行诊断 |
| `<leader>ss` | n | 当前文件 LSP 符号 |
| `<leader>sS` | n | 工作区 LSP 符号 |
| `]]` / `[[` | n | 下一个 / 上一个引用 |
| `]d` / `[d` | n | 下一个 / 上一个诊断 |
| `]e` / `[e` | n | 下一个 / 上一个错误 |
| `]w` / `[w` | n | 下一个 / 上一个警告 |
| `<leader>cc` | n | 切换当前 Buffer 补全（blink.cmp）〔自定义〕 |
| `<leader>cL` | n | 切换所有 LSP 客户端开关〔自定义〕 |
| `<leader>cP` | n | 格式化整个目录（conform.nvim）〔自定义〕 |
| `<leader>cm` | n | 打开 Mason（LSP / 工具安装器） |
| `<leader>cs` | n | 当前文件符号（Trouble） |
| `<leader>cS` | n | 引用 / 定义等（Trouble） |
| `<leader>cv` | n | 选择 VirtualEnv（Python） |

---

## C / C++ 查询〔自定义〕

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>cKm` | n | 手册搜索：按函数名（带说明，如 `str` → `str*` 家族） |
| `<leader>cKs` | n | 符号详情（类型 / 定义 / 大小） |
| `<leader>cKt` | n | 类型层次（继承 / 被继承） |
| `<leader>cKa` | n | 当前函数 AST |
| `<leader>cKi` | n | clangd 内存 / 索引占用 |
| `<leader>cKc` | n | cppman：搜索 C++ 标准库（`-f` 联想菜单） |

> clangd 已开启 `--background-index --clang-tidy --pch-storage=memory` 等大项目参数。

---

## 运行 / 终端

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>rr` | n | 运行当前文件（C/C++/Rust/Python/Java） |
| `<leader>ro` | n | Overseer：运行项目任务 |
| `<leader>rt` | n | Overseer：任务列表 |
| `<leader>rl` | n | Overseer：重跑上次任务 |
| `<leader>tt` | n | 切换终端显隐 |
| `<leader>th` | n | 水平终端 |
| `<leader>tv` | n | 垂直终端 |
| `<leader>tf` | n | 浮动终端 |
| `<leader>ft` / `<C-/>` | n / t | 终端（根目录） |
| `<leader>fT` | n | 终端（cwd） |

> 编译错误 / 警告显示在 quickfix 窗口，`<CR>` 跳转，`:cclose` 关闭；终端内按 `<C-\><C-n>` 进入普通模式。

---

## Git

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>gs` | n | Git 状态（暂存 / 提交 / 推送） |
| `<leader>gb` | n | 当前行 Blame |
| `<leader>gf` | n | 当前文件 Git 历史 |
| `<leader>gl` | n | Git 日志 |
| `<leader>gL` | n | Git 日志（cwd） |
| `<leader>gd` | n | Git Diff（hunks） |
| `<leader>gD` | n | Git Diff（相对 origin） |
| `<leader>gS` | n | Git Stash |
| `<leader>gB` | n / x | Git Browse（用浏览器打开） |
| `<leader>gY` | n / x | Git Browse（复制链接） |
| `<leader>gi` / `<leader>gI` | n | GitHub Issues（open / all） |
| `<leader>gp` / `<leader>gP` | n | GitHub Pull Requests（open / all） |

---

## 诊断 / 符号 / Trouble

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>xx` | n | 全部诊断（Trouble） |
| `<leader>xX` | n | 当前 Buffer 诊断（Trouble） |
| `<leader>xL` | n | Location List（Trouble） |
| `<leader>xQ` | n | Quickfix List（Trouble） |
| `<leader>xt` / `<leader>xT` | n | Todo（Trouble）/ Todo·Fix·Fixme |
| `[q` / `]q` | n | 上一个 / 下一个 Quickfix |
| `<leader>xl` / `<leader>xq` | n | Location List / Quickfix List |
| `[l` / `]l` | n | 上一个 / 下一个 Location |
| `[D` / `]D` | n | 当前 Buffer 第一条 / 最后一条诊断 |

---

## AI（sidekick.nvim）

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>ac` | n | Codex（GPT）新会话 |
| `<leader>aC` | n | Codex（GPT）恢复会话（session picker） |
| `<leader>aP` | n | Pi（DeepSeek）新会话 |
| `<leader>aR` | n | Pi（DeepSeek）恢复会话（session picker） |
| `<leader>aa` | n | 切换当前 CLI 窗口显隐 |
| `<leader>as` | n | 选择 / 接入 CLI 工具 |
| `<leader>ad` | n | 脱离当前 CLI 会话 |
| `<leader>at` | n / x | 把当前光标处 / 选中内容发给 CLI |
| `<leader>af` | n | 把当前文件发给 CLI |
| `<leader>av` | x | 把选中内容发给 CLI |
| `<leader>ap` | n / x | 选择预设 prompt |
| `<c-.>` | n / t / i / x | 聚焦 CLI 窗口 |

> sidekick 直接运行本机 `codex` / `pi` CLI，会话就是 CLI 自己的历史：
> `codex` → `~/.codex/sessions`；`pi` → `~/.pi/agent/sessions`。
> “恢复会话”会进入 CLI 自带的 session picker，可继续之前的对话。
> 在 Snacks picker 中按 `<a-a>` 可以把选中的文件 / 搜索结果发给当前 CLI 会话。

---

## Markdown〔自定义〕

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>mp` | n | 切换预览（私密浏览器：Chrome/Firefox 无痕） |
| `<leader>ml` | n | 切换大纲侧边栏（aerial） |
| `<leader>mo` | n | 聚焦大纲侧边栏 |
| `<leader>mk` | n | 插入代码块（输入语言名） |
| `<leader>mL` | n | 插入链接 `[]()` |
| `<leader>mi` | n | 粘贴剪贴板图片 / 从文件选择图片 |
| `<leader>ms` | n | 切换拼写检查 |
| `<leader>m=` | n | 显示拼写建议列表 |
| `<leader>m1` | n | 应用第一个拼写建议 |
| `<leader>ma` | n | 把当前单词加入词典 |
| `<leader>mw` | n | 把当前单词标记为拼写错误 |

> 图片默认保存到 `assets/`，文件名带时间戳，插入相对路径。

---

## 翻译（translate.nvim）〔自定义〕

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>tz` | n | 当前行 → 中文 |
| `<leader>te` | n | 当前行 → 英文 |
| `<leader>tz` | v / x | 选中内容 → 中文 |
| `<leader>te` | v / x | 选中内容 → 英文 |
| `<leader>tw` | n | 光标下单词 → 中文 |

---

## 补全（blink.cmp）

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<C-Space>` | i | 手动触发补全菜单 |
| `<Tab>` | i | 跳到 snippet 占位符 → 接受补全 → 缩进（fallback） |
| `<S-Tab>` | i | 反向跳转 snippet 占位符 |
| `<CR>` | i | 普通换行（不接受补全） |
| `<C-e>` | i | 取消补全 |
| `<C-n>` / `<Down>` | i | 选择下一个候选 |
| `<C-p>` / `<Up>` | i | 选择上一个候选 |
| `<C-b>` / `<C-f>` | i | 文档窗口上滚 / 下滚 |
| `<C-k>` | i | 手动触发 / 隐藏签名帮助 |

---

## UI 切换（`<leader>u`）

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>uf` / `<leader>uF` | n | 切换自动格式化（全局 / 当前 Buffer） |
| `<leader>us` | n | 切换拼写检查 |
| `<leader>uw` | n | 切换自动换行 |
| `<leader>ul` / `<leader>uL` | n | 切换行号 / 相对行号 |
| `<leader>ud` | n | 切换诊断 |
| `<leader>uc` | n | 切换 Conceal 级别 |
| `<leader>ub` | n | 切换深色 / 浅色背景 |
| `<leader>uT` | n | 切换 Treesitter 高亮 |
| `<leader>ug` | n | 切换缩进引导线 |
| `<leader>uh` | n | 切换内联提示（Inlay Hints） |
| `<leader>uS` | n | 切换平滑滚动 |
| `<leader>uz` | n | 切换禅模式（Zen） |
| `<leader>uZ` | n | 切换缩放模式（Zoom） |
| `<leader>uD` | n | 切换 Dimming |
| `<leader>ua` | n | 切换动画 |
| `<leader>uA` | n | 切换顶部标签栏（Tabline） |
| `<leader>uG` | n | 切换 Git 标记（gitsigns） |
| `<leader>um` | n | 切换 Render Markdown |
| `<leader>up` | n | 切换 Mini Pairs（自动括号） |
| `<leader>ut` | n | 切换 Treesitter Context |
| `<leader>ux` | n | 切换 Illuminate（同名高亮） |
| `<leader>uN` | n | 切换 Sidekick NES（已禁用，占位） |
| `<leader>uC` | n | 选择配色方案 |
| `<leader>ui` | n | 检查光标位置（Inspect Pos） |
| `<leader>uI` | n | 检查语法树（Inspect Tree） |
| `<leader>ur` | n | 重绘 / 清除搜索高亮 / 刷新 diff |
| `<leader>un` | n | 关闭全部通知 |

---

## 会话 / 工具

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>qs` | n | 恢复当前目录的会话 |
| `<leader>ql` | n | 恢复上次会话 |
| `<leader>qS` | n | 选择要恢复的会话 |
| `<leader>qd` | n | 退出时不保存当前会话 |
| `<leader>qq` | n | 退出全部 |
| `<leader>l` | n | 打开 Lazy（插件管理器） |
| `<leader>L` | n | LazyVim 更新日志 |
| `n` | n | 通知历史 |
| `?` / `<leader>?` | n | 当前 Buffer 的快捷键（which-key） |
| `<leader>dps` | n | Profiler Scratch Buffer |
| `<leader>dpp` | n | 切换 Profiler |
| `<leader>dph` | n | 切换 Profiler 高亮 |
| `<leader>.` | n | 切换 Scratch Buffer |
| `S` | n | 选择 Scratch Buffer |

---

## Harpoon（文件书签）

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>h` | n | 打开 Harpoon 快捷菜单 |
| `<leader>H` | n | 把当前文件加入 Harpoon |
| `<leader>1` … `<leader>9` | n | 跳转到第 1–9 个 Harpoon 文件 |

---

## Marks（书签 / 标记）

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `m` | n | 设置标记 |
| `m,` | n | 设置下一个可用标记 |
| `m0` … `m9` | n | 设置 book mark 0–9 |
| `m:` | n | 预览标记 |
| `m;` | n | 切换标记 |
| `m[` / `m]` | n | 上一个 / 下一个标记 |
| `m{` / `m}` | n | 上一个 / 下一个 book mark |
| `dm` | n | 删除标记 |
| `dm-` | n | 删除当前行标记 |
| `dm0` … `dm9` | n | 删除 book mark 0–9 |
| `dm=` | n | 删除所有 book mark |

---

## 编辑 / 注释 / 文本对象

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `gcc` | n | 注释 / 取消注释当前行 |
| `gc` | n / v / x | 注释 / 取消注释（可视区） |
| `gcO` / `gco` | n | 在上方 / 下方插入注释行 |
| `g[` / `g]` | n / o / v / x | 跳到 上一个 / 下一个 “around” |
| `S` | n / o / x | Flash Treesitter 选择 |
| `<C-Space>` | n / o / v / x | Treesitter 增量选择 |
| `[n` / `]n` | v / x | 选择 上一个 / 下一个节点 |
| `[N` / `]N` | v / x | 选择 上一个 / 下一个同级节点 |
| `i` / `a` | o / v / x | 内层 / 外层文本对象（mini.ai） |
| `in` / `an` | o / v / x | 下一个 内层 / 外层文本对象 |
| `il` / `al` | o / v / x | 最后 内层 / 外层文本对象 |

### mini.surround（环绕操作）

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `gsa` | n / v / x | 添加环绕 |
| `gsd` | n | 删除环绕 |
| `gsr` | n | 替换环绕 |
| `gsf` / `gsF` | n / o / v / x | 查找 右侧 / 左侧环绕 |
| `gsh` | n | 高亮环绕 |
| `gsn` | n | 更新 `MiniSurround.config.n_lines` |
| `gsdl` / `gsdn` | n | 删除 上一个 / 下一个环绕 |
| `gsrl` / `gsrn` | n | 替换 上一个 / 下一个环绕 |
| `gsfl` / `gsfn` | n / o / v / x | 查找 上一个 / 下一个右侧环绕 |
| `gsFl` / `gsFn` | n / o / v / x | 查找 上一个 / 下一个左侧环绕 |
| `gshl` / `gshn` | n | 高亮 上一个 / 下一个环绕 |

### 粘贴 / 缩进（yanky 等）

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `p` / `P` | n / x | 粘贴（打开 Yank 历史选择） |
| `[y` / `]y` | n | 向前 / 向后切换 Yank 历史 |
| `>p` / `>P` | n | 粘贴并向右缩进（后 / 前） |
| `<p` / `<P` | n | 粘贴并向左缩进（后 / 前） |
| `=p` / `=P` | n | 粘贴并自动缩进（后 / 前） |
| `]p` / `[p` | n | 在当前行下方 / 上方粘贴并缩进 |
| `gp` / `gP` | n / x | 粘贴后把光标停在末尾 |

---

## Flash（快速跳转）

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `s` | n / x / o | Flash 跳转 |
| `S` | n / x / o | Flash Treesitter 跳转 |
| `r` | o | Remote Flash |
| `R` | o / x | Treesitter 搜索 |
| `<c-s>` | c | 切换 Flash 搜索 |

---

## 其他常用

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `j` / `<Down>` | n / x | 向下移动（兼容折叠行） |
| `k` / `<Up>` | n / x | 向上移动（兼容折叠行） |
| `<A-j>` / `<A-k>` | n / i / v | 向下 / 向上移动当前行 |
| `<Esc>` | i / n / s | 退出并清除搜索高亮 |
| `<C-b>` / `<C-f>` | i / n / s | 向上 / 向下翻页 |
| `gx` | n / v / x | 用系统程序打开光标下的路径 / URL |
| `N` / `n` | n / v / x | 上一个 / 下一个搜索结果 |
| `[` / `]` | n | 在光标上方 / 下方添加空行 |
| `[y` / `]y` | n | 向前 / 向后切换 Yank 历史 |
| `<C-w>d` | n | 显示光标下诊断 |
| `<leader>K` | n | 对光标下单词运行 `keywordprg` |

---

## Alt（M-）键位

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<M-h>` `<M-j>` `<M-k>` `<M-l>` | n | 跳到 左 / 下 / 上 / 右 窗口 |
| `<M-[>` / `<M-]>` | n | 上一个 / 下一个 Buffer |
| `<M-n>` / `<M-p>` | n | 跳到 下一个 / 上一个引用 |
| `<M-j>` / `<M-k>` | n / i / v / x | 向下 / 向上移动当前行 |
| `<M-Down>` / `<M-Up>` | n / i / v / x | 向下 / 向上移动当前行（箭头键） |
| `<C-w>d` / `<C-w><C-d>` | n | 显示光标下诊断 |

> LaTeX（vimtex）相关键位在 `<localLeader>`（`\`）前缀下，例如 `\l`。

---

## 跳转 / 列表导航

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `[a` / `]a` | n | 参数列表 上一个 / 下一个文件 |
| `[A` / `]A` | n | 参数列表 第一个 / 最后一个 |
| `[L` / `]L` | n | Location List 第一个 / 最后一个 |
| `[Q` / `]Q` | n | Quickfix 第一个 / 最后一个 |
| `[T` / `]T` | n | 标签列表 第一个 / 最后一个 |
| `[<C-L>` / `]<C-L>` | n | Location List 上一个 / 下一个文件 |
| `[<C-Q>` / `]<C-Q>` | n | Quickfix 上一个 / 下一个文件 |
| `[<C-T>` / `]<C-T>` | n | 标签列表 上一个 / 下一个 |
| `[t` / `]t` | n | 上一个 / 下一个 Todo 注释 |
| `[` / `]` | n | 在光标上方 / 下方添加空行 |

---

## 命令行（cmdline）

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<C-n>` / `<C-p>` | c | blink.cmp：下一个 / 上一个候选项 |
| `<C-y>` | c | blink.cmp：选择并接受 |
| `<C-e>` | c | blink.cmp：取消 |
| `<C-Space>` | c | blink.cmp：显示补全 |
| `<Tab>` | c | blink.cmp：显示并选择下一个 |
| `<S-Tab>` | c | blink.cmp：选择上一个 |
| `<c-s>` | c | 切换 Flash 搜索 |
| `<S-CR>` / `<S-Enter>` | c | 重定向命令行到窗口 |
