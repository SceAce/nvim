-- blink.cmp 补全插件配置（VSCode 风格）
return {
  {
    "saghen/blink.cmp",
    opts = {
      -- ================================================================
      -- 按键映射
      -- ================================================================
      keymap = {
        preset = "none", -- 不使用预设，完全自定义

        -- 手动触发补全菜单
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },

        -- 取消补全
        ["<C-e>"] = { "cancel", "fallback" },

        -- Tab：优先跳转 snippet 占位符，其次接受补全（无论是否手动选中），最后 fallback（缩进）
        -- 有补全候选时 Tab 接受，无候选时正常缩进
        ["<Tab>"] = { "snippet_forward", "select_and_accept", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },

        -- Enter：不接受补全，只做普通换行
        -- 如需 Enter 也能接受补全，改为 { "accept", "fallback" }
        ["<CR>"] = { "fallback" },

        -- 上下选择候选项
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
        ["<C-n>"] = { "select_next", "fallback_to_mappings" },

        -- 文档窗口滚动
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },

        -- 签名帮助手动触发/隐藏
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
      },

      -- ================================================================
      -- 补全行为
      -- ================================================================
      completion = {
        -- 补全菜单
        menu = {
          -- 自动显示补全菜单（VSCode 默认行为）
          auto_show = true,

          -- 补全项显示：图标 + 名称 + 类型标注（VSCode 风格）
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "kind" },
            },
          },
        },

        -- 文档窗口：自动显示补全项的文档说明
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200, -- 延迟 200ms 显示，避免快速输入时闪烁
        },

        -- Ghost text：在光标后以灰色显示第一个补全候选的预览
        -- 如需关闭：将 enabled 改为 false
        ghost_text = {
          enabled = true,
        },
      },

      -- ================================================================
      -- 签名帮助：输入函数参数时自动显示参数说明
      -- 如需关闭：将 enabled 改为 false
      -- ================================================================
      signature = {
        enabled = true,
      },

      -- ================================================================
      -- 补全来源
      -- ================================================================
      sources = {
        -- 默认启用的 sources
        -- lsp: 语言服务器补全（最重要）
        -- path: 文件路径补全（输入 ./ 或 / 时触发）
        -- snippets: 代码片段补全
        -- buffer: 当前 buffer 中的词语补全
        -- buffer source 会补全当前文件中出现过的所有词（包括关键字如 return/end）
        -- 如需 buffer 词语补全，将 "buffer" 加回列表
        default = { "lsp", "path", "snippets" },
      },

      -- ================================================================
      -- 外观
      -- ================================================================
      appearance = {
        -- 使用 Nerd Font 图标（mono 变体间距更整齐）
        -- 如果图标显示异常，改为 'normal'
        nerd_font_variant = "mono",
      },
    },
  },
}
