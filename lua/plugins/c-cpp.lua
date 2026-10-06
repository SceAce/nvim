-- C/C++ 增强（clangd 参数 + 查询键位）
-- 由审查报告 ~/Tmp/nvim-cpp-review.md 得出；键位全部实测空闲。

local man_functions = require("custom.man_functions")
man_functions.setup() -- 后台预热手册索引

return {
  -- ==========================================================================
  -- 1) clangd 参数：面向大项目
  -- ==========================================================================
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            -- 大项目：preamble 常驻内存（解析/补全更快，代价是内存）
            "--pch-storage=memory",
          },
        },
      },
    },
  },

  -- ==========================================================================
  -- 2) 查询键位（统一收进空闲的 <leader>cK 前缀，which-key 会显示成一组）
  -- ==========================================================================
  {
    "p00f/clangd_extensions.nvim",
    keys = {
      { "<leader>cK", group = "C/C++ 查询" },

      -- 手册模糊搜索：一个函数一个条目 + 说明（修掉 macOS 上内置 man picker 的问题）
      {
        "<leader>cKm",
        function()
          man_functions.pick()
        end,
        desc = "手册搜索：按函数名（带说明，如 str → str* 家族）",
      },

      { "<leader>cKs", "<cmd>ClangdSymbolInfo<cr>", desc = "符号详情（类型/定义/大小）" },
      { "<leader>cKt", "<cmd>ClangdTypeHierarchy<cr>", desc = "类型层次（继承/被继承）" },
      { "<leader>cKa", "<cmd>ClangdAST<cr>", desc = "当前函数 AST" },
      { "<leader>cKi", "<cmd>ClangdMemoryUsage<cr>", desc = "clangd 内存/索引占用" },
    },
  },

  -- ==========================================================================
  -- 3) C++ 标准库：cppman（已装）
  --    不用 keywordprg=cppman：cppman 的 pager 默认是 vim/nvim，会套娃；
  --    这里显式 -p less 放进终端分屏。-f 会在多匹配时给出选择菜单（联想）。
  -- ==========================================================================
  {
    "neovim/nvim-lspconfig",
    keys = {
      {
        "<leader>cKc",
        function()
          if vim.fn.executable("cppman") ~= 1 then
            vim.notify("cppman 未安装：brew install cppman", vim.log.levels.WARN)
            return
          end
          local cword = vim.fn.expand("<cWORD>")
          vim.ui.input({ prompt = "C++ 标准库（回车用光标下的词）: ", default = cword }, function(input)
            if not input or input == "" then
              return
            end
            vim.cmd("botright split | terminal cppman -p less -f " .. vim.fn.shellescape(input))
          end)
        end,
        desc = "cppman：搜索 C++ 标准库（-f 联想菜单）",
      },
    },
  },
}
