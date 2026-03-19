-- AI 插件配置：avante.nvim + Claude

-- 从同目录下的 ai_key.txt 读取 API key
local function read_api_key()
  local key_file = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h") .. "/ai_key.txt"
  local f = io.open(key_file, "r")
  if not f then
    return nil
  end
  local key = f:read("*l")
  f:close()
  return key and key:match("^%s*(.-)%s*$") -- 去除首尾空白
end

-- 将 key 注入环境变量，避免 avante 弹出输入框
local _key = read_api_key()
if _key and _key ~= "" then
  vim.env.ANTHROPIC_API_KEY = _key
end

return {
  -- 禁用 copilot（不需要）
  { "zbirenbaum/copilot.lua", enabled = false },

  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      -- 使用 Claude 作为 AI 提供商
      provider = "claude",

      providers = {
        claude = {
          -- 模型选择：
          -- "claude-opus-4-6-20251001"   → 最强，适合复杂任务
          -- "claude-sonnet-4-6-20251001" → 均衡，推荐日常使用
          -- "claude-haiku-4-6-20251001"  → 最快最省，适合简单任务
          model = "claude-sonnet-4-6-20251001",

          -- 最大 token 数（响应长度上限）
          max_tokens = 8192,

          -- 本地代理地址
          -- 如使用官方 API，注释掉此行即可
          endpoint = "http://localhost:3010",

          -- 从文件读取 API key
          -- api_key = "sk-your-secret-token-1",
          api_key = read_api_key(),
        },
      },

      -- 行为设置
      behaviour = {
        -- 自动建议（输入时实时建议，类似 Copilot）
        -- 如需开启，改为 true（会增加 API 用量）
        auto_suggestions = false,

        -- 粘贴时自动优化代码
        auto_set_keymaps = true,

        -- 支持外部工具调用（如搜索、读文件）
        support_paste_from_clipboard = true,
      },

      -- 窗口布局
      windows = {
        -- 侧边栏位置："right" / "left"
        position = "right",

        -- 侧边栏宽度（百分比）
        width = 35,

        sidebar_header = {
          align = "center",
          rounded = true,
        },
      },
    },
    keys = {
      { "<leader>aa", "<cmd>AvanteAsk<cr>", desc = "AI: 提问" },
      { "<leader>at", "<cmd>AvanteToggle<cr>", desc = "AI: 切换面板" },
      { "<leader>ar", "<cmd>AvanteRefresh<cr>", desc = "AI: 刷新" },
      { "<leader>ae", "<cmd>AvanteEdit<cr>", mode = "v", desc = "AI: 编辑选中" },
    },
  },
}
