local helpers = require("tests.helpers")

local render_opts = helpers.plugin_opts("render-markdown.nvim")
helpers.eq(render_opts.render_modes, { "n", "c", "t" }, "Markdown render modes")
helpers.truthy(render_opts.latex, "Markdown LaTeX options are configured")
helpers.eq(render_opts.latex.enabled, true, "Markdown LaTeX rendering is enabled")
helpers.eq(render_opts.latex.converter, "utftex", "Markdown LaTeX converter")
helpers.eq(render_opts.latex.position, "above", "Markdown LaTeX position")

local treesitter_opts = helpers.plugin_opts("nvim-treesitter")
helpers.contains(treesitter_opts.ensure_installed, "latex", "Treesitter parsers")

helpers.eq(vim.fn.executable("utftex"), 1, "utftex is executable")
local utftex_output = vim.fn.system({ "utftex", "E = mc^2" })
helpers.eq(vim.v.shell_error, 0, "utftex converts a formula")
helpers.truthy(utftex_output ~= "", "utftex returns Unicode output")
helpers.truthy(utftex_output:find("²", 1, true), "utftex output contains a superscript")

require("lazy").load({ plugins = { "render-markdown.nvim" } })

local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buf)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
  "Inline math: $E = mc^2$",
  "",
  "$$",
  [[\frac{1}{2} + \int_0^1 x^2 \, dx]],
  "$$",
})

local eventignore = vim.o.eventignore
vim.o.eventignore = eventignore == "" and "FileType" or eventignore .. ",FileType"
vim.bo[buf].filetype = "markdown"
vim.o.eventignore = eventignore

local namespace = vim.api.nvim_get_namespaces()["render-markdown.nvim"]
helpers.truthy(namespace, "render-markdown namespace exists")

require("render-markdown").render({
  buf = buf,
  win = vim.api.nvim_get_current_win(),
})

local block_virtual_text
local rendered = vim.wait(2000, function()
  local marks = vim.api.nvim_buf_get_extmarks(buf, namespace, 0, -1, { details = true })
  for _, mark in ipairs(marks) do
    local details = mark[4]
    if details and details.virt_lines and #details.virt_lines > 0 then
      local chunks = {}
      for _, line in ipairs(details.virt_lines) do
        for _, chunk in ipairs(line) do
          chunks[#chunks + 1] = chunk[1]
        end
      end
      local text = table.concat(chunks, "\n")
      if text ~= "" and text:find("⌠", 1, true) then
        block_virtual_text = text
        return true
      end
    end
  end
  return false
end, 20)

helpers.truthy(rendered, "render-markdown creates virtual lines for block math")
helpers.truthy(block_virtual_text:find("⌠", 1, true), "block math virtual lines contain a converted integral")
vim.api.nvim_buf_delete(buf, { force = true })

print("markdown_render_spec: ok")
