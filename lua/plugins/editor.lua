return {
  {
    "SmiteshP/nvim-navic",
    opts = function(_, opts)
      opts.highlight = true
    end,
  },

  -- ================================================================
  -- toggleterm.nvim：终端管理
  -- code_runner 使用此插件显示运行结果
  -- 默认停在最新输出，向上滚动可查看编译警告/错误信息
  -- ================================================================
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {
      -- 终端窗口大小（行数）
      -- 如需更大/更小，修改此值
      size = 15,

      -- 终端显示位置：
      -- "horizontal" → 底部（推荐，默认）
      -- "vertical"   → 右侧
      -- "float"      → 浮动窗口
      direction = "horizontal",

      -- 浮动窗口边框样式（direction = "float" 时生效）
      -- "curved" / "double" / "shadow" / "single"
      float_opts = {
        border = "curved",
      },

      -- 打开终端时自动进入 insert 模式
      start_in_insert = true,

      -- 关闭终端进程后自动关闭窗口
      -- code_runner 使用独立的临时终端，此处设为 false
      -- 临时终端由 code_runner 的 close_on_exit 控制
      close_on_exit = false,

      -- 终端窗口的高亮组
      highlights = {
        NormalFloat = { link = "Normal" },
      },

      -- winbar 显示终端名称，与编辑区明显区分
      winbar = {
        enabled = true,
        name_formatter = function(term)
          return "  Runner #" .. term.id
        end,
      },
    },
    keys = {
      -- 切换终端显示/隐藏
      { "<leader>tt", "<cmd>ToggleTerm<CR>",              desc = "切换终端" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "水平终端" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>",   desc = "垂直终端" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<CR>",      desc = "浮动终端" },
    },
  },
}
