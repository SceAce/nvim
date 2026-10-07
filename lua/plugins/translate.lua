-- 翻译：translate.nvim
--
-- 默认的 `google` 引擎走 script.google.com，本网络下会被拦截，返回 HTML 导致
-- 「Expected value but found invalid token」解析错误。
-- 这里改用 `translate_shell` 引擎（调用 translate-shell 的 `trans` 命令），
-- 并显式把代理传给 trans，避免直连被墙。
--
-- 依赖：brew install translate-shell
--   $ trans -b -no-ansi -no-autocorrect -x 127.0.0.1:7897 :zh "hello"  →  你好

--- 探测代理地址，返回 `host:port`；输入可以是 `http://host:port`
--- 优先级：TRANSLATE_PROXY > https_proxy > http_proxy > all_proxy > 默认 Clash 端口
--- 设为 `none` / 空字符串可禁用代理（直连）
---@return string|nil
local function detect_proxy()
  local raw = vim.env.TRANSLATE_PROXY
    or vim.env.https_proxy
    or vim.env.HTTPS_PROXY
    or vim.env.http_proxy
    or vim.env.HTTP_PROXY
    or vim.env.all_proxy
    or vim.env.ALL_PROXY
    or "http://127.0.0.1:7897" -- 默认本机 Clash 混合端口
  if raw == "" or raw:lower() == "none" then
    return nil
  end
  return (raw:match("^%a+://(.+)$") or raw):gsub("/$", "")
end

local proxy = detect_proxy()

return {
  {
    "uga-rosa/translate.nvim",
    config = function()
      require("translate").setup({
        default = {
          -- 可选：google / translate_shell / deepl_free / deepl_pro
          command = "translate_shell",
        },
        preset = {
          command = {
            -- trans 的 -x / -proxy 参数；没探测到代理时留空，走系统代理或直连
            translate_shell = {
              args = proxy and { "-x", proxy } or {},
            },
          },
        },
      })
      -- 想换 DeepL 等付费引擎时，在这里设置 key 并切换 default.command，例如：
      -- vim.g.deepl_api_auth_key = vim.env.DEEPL_API_KEY
      -- require("translate").setup({ default = { command = "deepl_free" } })
    end,
    keys = {
      -- 翻译当前行 -> 中文
      { "<leader>tz", "<Cmd>Translate zh<CR>", desc = "翻译：当前行→中文" },

      -- 翻译当前行 -> 英文
      { "<leader>te", "<Cmd>Translate en<CR>", desc = "翻译：当前行→英文" },

      -- 可视模式：翻译选中内容 -> 中文
      { "<leader>tz", ":'<,'>Translate zh<CR>", mode = "v", desc = "翻译：选中→中文" },

      -- 可视模式：翻译选中内容 -> 英文
      { "<leader>te", ":'<,'>Translate en<CR>", mode = "v", desc = "翻译：选中→英文" },

      -- 翻译光标下单词 -> 中文（viw 选词）
      { "<leader>tw", "viw:Translate zh<CR>", desc = "翻译：单词→中文" },
    },
  },
}
