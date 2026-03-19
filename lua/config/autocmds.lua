-- delete trailing space
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  callback = function(ev)
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- markdown: keymaps and spell
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    local opts = { buffer = true, silent = true }

    -- fenced code block
    local function fence_codeblock()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      vim.api.nvim_buf_set_lines(0, row, row, false, { "```", "", "```", "" })
      vim.api.nvim_win_set_cursor(0, { row + 1, 3 })
      vim.cmd("startinsert")
    end
    vim.keymap.set(
      "n",
      "<leader>mk",
      fence_codeblock,
      vim.tbl_extend("force", opts, { desc = "Markdown: 插入代码块" })
    )

    -- insert link
    vim.keymap.set(
      "n",
      "<leader>mL",
      "i[]()<Esc>hi",
      vim.tbl_extend("force", opts, { desc = "Markdown: 插入链接" })
    )

    -- smart insert image
    local function clipboard_has_image()
      if vim.fn.executable("wl-paste") ~= 1 then
        return false
      end
      local out = vim.fn.systemlist({ "wl-paste", "-l" })
      for _, line in ipairs(out) do
        if line:match("^image/") then
          return true
        end
      end
      return false
    end

    local function insert_image_from_picker()
      local ok, telescope = pcall(require, "telescope.builtin")
      if not ok then
        vim.notify("telescope.nvim not available.", vim.log.levels.WARN)
        return
      end
      local cwd = vim.fn.expand("%:p:h")
      telescope.find_files({
        prompt_title = "Insert image path",
        cwd = cwd,
        hidden = true,
        attach_mappings = function(prompt_bufnr, map)
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")
          local function insert_sel()
            local entry = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if not entry or not entry.path then
              return
            end
            local rel = vim.fn.fnamemodify(entry.path, ":.")
            vim.api.nvim_put({ string.format("![](%s)", rel) }, "c", true, true)
          end
          map("i", "<CR>", insert_sel)
          map("n", "<CR>", insert_sel)
          return true
        end,
      })
    end

    vim.keymap.set("n", "<leader>mi", function()
      if clipboard_has_image() then
        vim.cmd("PasteImage")
      else
        insert_image_from_picker()
      end
    end, vim.tbl_extend("force", opts, { desc = "Markdown: 粘贴/选择图片" }))

    -- spell
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "en_us", "cjk" }
    vim.opt_local.spellfile = vim.fn.stdpath("data") .. "/spell/en.utf-8.add"

    vim.keymap.set("n", "<leader>ms", function()
      vim.wo.spell = not vim.wo.spell
      vim.notify("spell = " .. tostring(vim.wo.spell))
    end, vim.tbl_extend("force", opts, { desc = "Markdown: 切换拼写检查" }))
    vim.keymap.set("n", "<leader>m=", "z=", vim.tbl_extend("force", opts, { desc = "Markdown: 拼写建议" }))
    vim.keymap.set("n", "<leader>m1", "1z=", vim.tbl_extend("force", opts, { desc = "Markdown: 应用首个建议" }))
    vim.keymap.set("n", "<leader>ma", "zg", vim.tbl_extend("force", opts, { desc = "Markdown: 加入词典" }))
    vim.keymap.set("n", "<leader>mw", "zw", vim.tbl_extend("force", opts, { desc = "Markdown: 标记错误单词" }))
  end,
})
