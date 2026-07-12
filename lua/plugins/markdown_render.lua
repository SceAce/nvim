return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "latex" } },
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
