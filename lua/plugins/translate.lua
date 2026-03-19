return {
  {
    "uga-rosa/translate.nvim",
    -- 默认就能用，不配也行；这里主要是放你未来要切换 deepl / trans 时的入口
    config = function()
      -- 例：如果你以后要用 DeepL，可以先把 key 放环境变量或这里（不建议明文写在 repo 里）
      -- vim.g.deepl_api_auth_key = "YOUR_DEEPL_KEY"
      -- require("translate").setup({ default = { command = "deepl_pro" } })
      -- 不需要任何设置也能用默认 Google Translate（curl）
    end,
    keys = {
      -- 翻译当前行 -> 中文
      { "<leader>tz", "<Cmd>Translate ZH<CR>", desc = "翻译：当前行→中文" },

      -- 翻译当前行 -> 英文
      { "<leader>te", "<Cmd>Translate EN<CR>", desc = "翻译：当前行→英文" },

      -- 可视模式：翻译选中内容 -> 中文
      { "<leader>tz", ":'<,'>Translate ZH<CR>", mode = "v", desc = "翻译：选中→中文" },

      -- 可视模式：翻译选中内容 -> 英文
      { "<leader>te", ":'<,'>Translate EN<CR>", mode = "v", desc = "翻译：选中→英文" },

      -- 翻译光标下单词 -> 中文（viw 选词）
      { "<leader>tw", "viw:Translate ZH<CR>", desc = "翻译：单词→中文" },
    },
  },
}
