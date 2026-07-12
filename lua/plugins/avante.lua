return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  opts = {
    provider = "codex_http",
    providers = {
      codex_http = {
        __inherited_from = "openai",
        endpoint = "https://www.aivalux.com",
        model = "gpt-5.6-sol",
        api_key_name = "OPENAI_API_KEY",
        use_response_api = true,
        proxy = "http://127.0.0.1:7897",
        parse_api_key = function()
          return require("config.ai").get_openai_api_key()
        end,
      },
    },
  },
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
}
