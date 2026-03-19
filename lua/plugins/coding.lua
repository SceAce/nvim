-- LSP / completion / formatting utilities

local cmp_enabled = true
local lsp_enabled = true

vim.keymap.set("n", "<leader>cc", function()
  if vim.b.completion == false then
    vim.b.completion = true
    vim.notify("Completion enabled", vim.log.levels.INFO)
  else
    vim.b.completion = false
    vim.notify("Completion disabled", vim.log.levels.INFO)
  end
end, { desc = "切换补全" })

vim.keymap.set("n", "<leader>cL", function()
  lsp_enabled = not lsp_enabled
  if lsp_enabled then
    pcall(vim.api.nvim_create_augroup, "nvim.lsp.enable", { clear = false })
    vim.cmd("LspStart")
    vim.cmd("doautocmd FileType")
    vim.notify("LSP started")
  else
    for _, client in ipairs(vim.lsp.get_clients()) do
      vim.lsp.stop_client(client.id, true)
    end
    vim.notify("LSP stopped")
  end
end, { desc = "切换 LSP" })

vim.keymap.set("n", "<leader>cP", function()
  local ok, conform = pcall(require, "conform")
  if not ok then
    vim.notify("conform.nvim not loaded.", vim.log.levels.WARN)
    return
  end

  local excluded_patterns = {
    "node_modules/", ".git/", "target/", "vendor/", "dist/",
    "build/", "tests/", "cmake/", "doc/", "install/",
    "install-dbg/", "input/", "out/",
  }

  vim.ui.input({ prompt = "Format directory: ", default = ".", completion = "dir" }, function(input)
    if not input or input == "" then return end

    local root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
    local is_git = (vim.v.shell_error == 0)

    local files = {}
    if is_git then
      local git_files = vim.fn.systemlist("git ls-files --full-name " .. input)
      for _, f in ipairs(git_files) do
        table.insert(files, root .. "/" .. f)
      end
    else
      local target_dir = vim.fn.fnamemodify(input, ":p"):gsub("/$", "")
      files = vim.fn.split(vim.fn.system("find " .. target_dir .. " -type f"), "\n")
    end

    local filtered = {}
    for _, file in ipairs(files) do
      local excluded = false
      for _, pattern in ipairs(excluded_patterns) do
        if file:find(pattern, 1, true) then
          excluded = true
          break
        end
      end
      if not excluded then table.insert(filtered, file) end
    end
    files = filtered

    if #files == 0 then
      vim.notify("No file found: " .. input, vim.log.levels.WARN)
      return
    end

    vim.notify("Formatting " .. #files .. " files...", vim.log.levels.INFO)
    local count = 0
    for _, full_path in ipairs(files) do
      if vim.fn.filereadable(full_path) == 1 then
        local bufnr = vim.fn.bufnr(full_path)
        local loaded = (bufnr ~= -1)
        if not loaded then
          bufnr = vim.fn.bufadd(full_path)
          vim.fn.bufload(bufnr)
        end
        vim.api.nvim_buf_call(bufnr, function()
          if vim.bo.filetype == "" then vim.cmd("filetype detect") end
          local ok_fmt = pcall(conform.format, { bufnr = bufnr, async = false, lsp_fallback = true })
          if ok_fmt then count = count + 1 end
        end)
        if not loaded then
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end
      end
    end
    vim.notify("Formatted " .. count .. " files.", vim.log.levels.INFO)
  end)
end, { desc = "格式化目录" })

return {}
