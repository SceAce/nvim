-- 强制格式化统一为 4 空格缩进
--
-- 背景：conform 调用 stylua 时会传 `--search-parent-directories`，stylua 从
-- 被格式化文件所在目录向上查找 `stylua.toml` / `.editorconfig`。如果项目里
-- 存在 `.editorconfig`（indent_size = 2）或 stylua.toml，其优先级高于命令行
-- 参数，导致缩进被改成 2 空格。
--
-- 修复：用 `--config-path` 显式指向本仓库的 stylua.toml（4 空格），并去掉
-- `--search-parent-directories`，让项目级配置不再覆盖。
local stylua_config = vim.fn.stdpath("config") .. "/stylua.toml"

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        stylua = {
          args = {
            "--config-path",
            stylua_config,
            "--stdin-filepath",
            "$FILENAME",
            "-",
          },
          range_args = function(self, ctx)
            local util = require("conform.util")
            local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)
            return {
              "--config-path",
              stylua_config,
              "--stdin-filepath",
              "$FILENAME",
              "--range-start",
              tostring(start_offset),
              "--range-end",
              tostring(end_offset),
              "-",
            }
          end,
          cwd = function()
            return vim.fn.stdpath("config")
          end,
        },
      },
    },
  },
}
