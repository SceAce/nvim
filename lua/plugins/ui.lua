local explorer = require("custom.explorer")

return {
  {
    "snacks.nvim",
    keys = {
      -- 一键显示 / 隐藏 dotfiles 与 git 忽略的文件
      {
        "<leader>eH",
        function()
          explorer.toggle()
        end,
        desc = "切换隐藏文件（dotfiles / gitignore）",
      },
    },
    opts = function(_, opts)
      opts.picker = {
        actions = {
          -- explorer 内一键切换显示（绑定到列表窗口的 H）
          toggle_hidden_ignored = function(picker)
            explorer.picker_toggle(picker)
            vim.notify(
              explorer.show_hidden and "显示 dotfiles / git 忽略的文件"
                or "隐藏 dotfiles / git 忽略的文件",
              vim.log.levels.INFO
            )
          end,
        },
        sources = {
          explorer = {
            layout = {
              layout = {
                position = "left",
              },
            },
            win = {
              list = {
                keys = {
                  ["H"] = "toggle_hidden_ignored",
                },
              },
            },
            -- 打开时注入当前显示状态（默认隐藏 dotfiles / git 忽略文件）
            config = function(o)
              local state = explorer.opts()
              o.hidden = state.hidden
              o.ignored = state.ignored
              return require("snacks.picker.source.explorer").setup(o)
            end,
          },
        },
      }
      opts.dashboard.preset.header = [[
    =================     ===============     ===============   ========  ========
    \\ . . . . . . .\\   //. . . . . . .\\   //. . . . . . .\\  \\. . .\\// . . //
    ||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\/ . . .||
    || . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . ||
    ||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .||
    || . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\ . . . . ||
    ||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\_ . .|. .||
    || . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\ `-_/| . ||
    ||_-' ||  .|/    || ||    \|.  || `-_|| ||_-' ||  .|/    || ||   | \  / |-_.||
    ||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \  / |  `||
    ||    `'         || ||         `'    || ||    `'         || ||   | \  / |   ||
    ||            .===' `===.         .==='.`===.         .===' /==. |  \/  |   ||
    ||         .=='   \_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \/  |   ||
    ||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \/  |   ||
    ||   .=='    _-'          '-__\._-'         '-_./__-'         `' |. /|  |   ||
    ||.=='    _-'                                                     `' |  /==.||
    =='    _-'                       [ @Source ]                          \/   `==
    \   _-'                                                                `-_   /
    `''                                                                      ``'
]]
      -- stylua: ignore
      ---@type snacks.dashboard.Item[]
      opts.dashboard.preset.keys = {
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = " ", key = "s", desc = "Restore Session", section = "session" },
        { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      }
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.component_separators = { left = "", right = "" }
      opts.options.section_separators = { left = " ", right = "" }
      opts.sections.lualine_a = {
        { "mode" },
        { "selectioncount" },
      }
      opts.sections.lualine_c = { { "diagnostics" } }
      opts.sections.lualine_y = {
        { "progress", separator = " ", padding = { left = 1, right = 0 } },
        { "location", padding = { left = 0, right = 1 } },
      }
    end,
  },
}
