-- AI：sidekick.nvim（方案 B）
--
-- 直接驱动本机的 AI CLI，因此**复用 CLI 自己的会话历史**：
--   codex → codex resume / codex resume --last
--   pi    → pi --resume / pi --continue
-- 不再像 avante 那样各用一套独立的会话文件。
--
-- 未使用 GitHub Copilot，关闭 NES（Next Edit Suggestions）。

-- pi 不是 PATH 上的可执行文件，而是 zsh 函数包装的这个脚本（内部用 tsx 跑源码）
local pi_script = vim.fn.expand("~/My_github/pi/pi-test.sh")

---@param name string
local function toggle(name)
  return function()
    require("sidekick.cli").toggle({ name = name, focus = true })
  end
end

return {
  {
    "folke/sidekick.nvim",
    keys = {
      { "<leader>ac", toggle("codex"), desc = "Codex（GPT）新会话" },
      { "<leader>aC", toggle("codex_resume"), desc = "Codex（GPT）恢复会话" },
      { "<leader>aP", toggle("pi"), desc = "Pi（DeepSeek）新会话" },
      { "<leader>aR", toggle("pi_resume"), desc = "Pi（DeepSeek）恢复会话" },
    },
    opts = {
      -- 没有 Copilot 订阅，关闭下一步编辑建议
      nes = { enabled = false },
      cli = {
        -- 右侧分栏
        win = {
          layout = "right",
          split = { width = 90 },
        },
        tools = {
          -- pi 默认 cmd 是 { "pi" }，这里指向包装脚本
          pi = {
            cmd = { pi_script },
          },
          -- 恢复会话：启动即进入 CLI 自带的 session picker
          codex_resume = {
            cmd = { "codex", "resume" },
            url = "https://github.com/openai/codex",
          },
          pi_resume = {
            cmd = { pi_script, "--resume" },
            url = "https://github.com/badlogic/pi-mono",
          },
        },
      },
    },
  },
}
