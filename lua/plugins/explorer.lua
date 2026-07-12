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
