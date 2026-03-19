-- 代码运行插件配置
-- 编译信息输出到 quickfix，程序输出在终端

-- 各语言的编译命令（输出到 quickfix）和运行命令
local lang_config = {
  c = {
    -- %f=文件名 %l=行号 %c=列号 %m=信息（gcc/g++ 错误格式）
    compile = function(dir, name, stem)
      return {
        cmd = string.format("LC_ALL=C gcc %q -o %q", name, stem),
        cwd = dir,
        efm = "%f:%l:%c: %t%*[^:]: %m,%f:%l: %t%*[^:]: %m",
        bin = dir .. "/" .. stem,
      }
    end,
  },
  cpp = {
    compile = function(dir, name, stem)
      return {
        cmd = string.format("LC_ALL=C g++ %q -o %q", name, stem),
        cwd = dir,
        efm = "%f:%l:%c: %t%*[^:]: %m,%f:%l: %t%*[^:]: %m",
        bin = dir .. "/" .. stem,
      }
    end,
  },
  rust = {
    compile = function(dir, name, stem)
      return {
        cmd = string.format("LC_ALL=C rustc %q -o %q", name, stem),
        cwd = dir,
        efm = "%f:%l:%c: %t%*[^:]: %m",
        bin = dir .. "/" .. stem,
      }
    end,
  },
  python = {
    -- Python 不需要编译，直接运行
    compile = function(dir, name, stem)
      return {
        cmd = nil,
        bin = nil,
        run_cmd = string.format("python3 %q", dir .. "/" .. name),
      }
    end,
  },
  java = {
    compile = function(dir, name, stem)
      return {
        cmd = string.format("LC_ALL=C javac %q", name),
        cwd = dir,
        efm = "%f:%l: %t%*[^:]: %m",
        bin = nil,
        run_cmd = string.format("cd %q && java %q", dir, stem),
      }
    end,
  },
}

local function run_in_term(cmd)
  local ok, tm = pcall(require, "toggleterm.terminal")
  if not ok or not tm.Terminal then
    vim.notify("toggleterm not loaded", vim.log.levels.WARN)
    return
  end
  local term = tm.Terminal:new({
    cmd = "bash -c '" .. cmd .. "; echo; read -p \"按任意键退出...\" -n1; exit'",
    direction = "horizontal",
    size = 15,
    close_on_exit = true,
    on_open = function(t)
      vim.cmd("startinsert")
    end,
  })
  term:open()
end

local function run_file()
  local ft = vim.bo.filetype
  local cfg = lang_config[ft]
  if not cfg then
    vim.notify("不支持的文件类型: " .. ft, vim.log.levels.WARN)
    return
  end

  local dir  = vim.fn.expand("%:p:h")
  local name = vim.fn.expand("%:t")
  local stem = vim.fn.expand("%:t:r")
  local info = cfg.compile(dir, name, stem)

  -- Python 等无需编译的语言直接运行
  if info.cmd == nil then
    run_in_term(info.run_cmd)
    return
  end

  -- 编译：用 vim.fn.systemlist 执行，结果填入 quickfix
  local full_cmd = string.format("cd %q && %s 2>&1", info.cwd, info.cmd)
  local output = vim.fn.systemlist(full_cmd)
  local exit_code = vim.v.shell_error

  -- 解析编译输出到 quickfix
  vim.fn.setqflist({}, " ", {
    title = "编译: " .. name,
    lines = output,
    efm = info.efm,
  })

  if #output > 0 then
    -- 有编译信息（警告或错误）时打开 quickfix
    vim.cmd("copen")
  end

  if exit_code ~= 0 then
    -- 编译失败，停止
    vim.notify("编译失败，请查看 quickfix 窗口", vim.log.levels.ERROR)
    return
  end

  -- 编译成功，运行程序
  local run_cmd = info.run_cmd or info.bin
  run_in_term(run_cmd)
end

-- 注册快捷键
vim.keymap.set("n", "<leader>rr", run_file, { desc = "运行当前文件" })

return {
  -- ================================================================
  -- overseer.nvim：项目级任务运行器
  -- 自动识别 Cargo.toml / Makefile / CMakeLists.txt 等
  -- ================================================================
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerOpen" },
    opts = {
      task_list = {
        -- 任务列表显示位置："bottom" / "right"
        direction = "bottom",
        min_height = 10,
      },
      -- 自定义模板目录（lua/overseer/templates/ 下的文件）
      templates = { "builtin", "tomcat" },
    },
    keys = {
      { "<leader>ro", "<cmd>OverseerRun<CR>",         desc = "运行项目任务" },
      { "<leader>rt", "<cmd>OverseerToggle<CR>",      desc = "任务列表" },
      { "<leader>rl", "<cmd>OverseerRestartLast<CR>", desc = "重跑上次任务" },
    },
  },
}
