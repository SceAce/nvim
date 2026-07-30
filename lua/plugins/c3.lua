return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "c3" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd({ "BufReadPost", "FileType" }, {
        pattern = { "*.c3", "*.c3i", "c3", "c3i" },
        callback = function(event)
          if vim.b[event.buf].c3_lsp_starting then
            return
          end
          vim.b[event.buf].c3_lsp_starting = true

          vim.schedule(function()
            if #vim.lsp.get_clients({ bufnr = event.buf, name = "c3_lsp" }) > 0 then
              return
            end

            local config = vim.deepcopy(vim.lsp.config.c3_lsp)
            if not config then
              return
            end
            config.root_dir = vim.fs.root(event.buf, config.root_markers)
            if config.root_dir then
              vim.lsp.start(config, { bufnr = event.buf })
            else
              vim.b[event.buf].c3_lsp_starting = nil
            end
          end)
        end,
      })
    end,
    opts = {
      servers = {
        c3_lsp = {},
      },
    },
  },
}
