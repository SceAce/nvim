-- ~/.config/nvim/lua/plugins/markdown_writer.lua
-- Markdown writing: code fences, outline sidebar, image paste/link, preview in private browser, spell helpers

-- mkdp_browserfunc wrapper: Vimscript calls into Lua
package.preload["markdown_writer_browser"] = function()
  local M = {}

  local function exists(cmd)
    return vim.fn.executable(cmd) == 1
  end

  function M.open(url)
    if exists("google-chrome-stable") then
      vim.fn.jobstart({ "google-chrome-stable", "--incognito", url }, { detach = true })
      return
    end
    if exists("firefox") then
      vim.fn.jobstart({ "firefox", "--private-window", url }, { detach = true })
      return
    end
    if exists("xdg-open") then
      vim.fn.jobstart({ "xdg-open", url }, { detach = true })
      return
    end
    vim.notify("No browser found.", vim.log.levels.ERROR)
  end

  return M
end

return {

  -- Outline sidebar
  {
    "stevearc/aerial.nvim",
    ft = { "markdown", "markdown.mdx" },
    opts = {
      backends = { "treesitter", "markdown" },
      layout = { min_width = 28, default_direction = "right" },
      show_guides = true,
      filter_kind = false,
    },
    keys = {
      { "<leader>ml", "<cmd>AerialToggle right<cr>", desc = "Markdown: 切换大纲" },
      { "<leader>mo", "<cmd>AerialOpen right<cr><cmd>AerialFocus<cr>", desc = "Markdown: 聚焦大纲" },
    },
  },

  -- Markdown preview (private browser)
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown", "markdown.mdx" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_open_to_the_world = 0

      -- expects a Vimscript function name
      vim.g.mkdp_browserfunc = "OpenMarkdownPreviewPrivate"

      vim.cmd([[
function! OpenMarkdownPreviewPrivate(url) abort
  call luaeval("require('markdown_writer_browser').open(_A)", a:url)
endfunction
      ]])
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown: 预览" },
    },
  },

  -- Paste image from clipboard -> save -> insert markdown link
  {
    "HakonHarnes/img-clip.nvim",
    ft = { "markdown", "markdown.mdx" },
    opts = {
      dir_path = "assets",
      file_name = "%Y-%m-%d_%H-%M-%S",
      prompt_for_file_name = false,
      use_absolute_path = false,
      relative_to_current_file = true,
      insert_mode_after_paste = false,
    },
  },
}
