-- Snacks explorer：默认隐藏 dotfiles 和被 git 忽略的文件，
-- 并提供一个快捷键一键切换「显示 / 隐藏」。
--
-- 状态来源：M.show_hidden
--   false（默认）→ hidden = false, ignored = false（隐藏）
--   true         → hidden = true,  ignored = true （显示）
--
-- 打开 explorer 时通过 explorer 的 config() 注入当前状态；
-- 在 explorer 内按 H、或在任意位置按 <leader>eH 均可即时切换。

local M = {}

--- 是否显示 dotfiles / git 忽略的文件
---@type boolean
M.show_hidden = false

--- 当前状态对应的 explorer 选项
---@return { hidden: boolean, ignored: boolean }
function M.opts()
  return { hidden = M.show_hidden, ignored = M.show_hidden }
end

local function notify()
  vim.notify(
    M.show_hidden and "显示 dotfiles / git 忽略的文件" or "隐藏 dotfiles / git 忽略的文件",
    vim.log.levels.INFO
  )
end

--- 切换单个 explorer picker 的显示状态，并同步全局状态
---@param picker snacks.Picker
function M.picker_toggle(picker)
  -- 只有两者都显示时才隐藏；否则一律显示
  local show = not (picker.opts.hidden and picker.opts.ignored)
  picker.opts.hidden = show
  picker.opts.ignored = show
  M.show_hidden = show
  picker.list:set_target()
  picker:find()
end

--- 已打开的 explorer picker（含其他 tab）
---@return snacks.Picker[]
local function open_pickers()
  local ok, Snacks = pcall(require, "snacks")
  if not ok then
    return {}
  end
  return Snacks.picker.get({ source = "explorer", tab = false })
end

--- 全局切换：有打开的 explorer 就即时刷新，否则只更新状态
function M.toggle()
  local pickers = open_pickers()
  if #pickers > 0 then
    for _, picker in ipairs(pickers) do
      M.picker_toggle(picker)
    end
  else
    M.show_hidden = not M.show_hidden
  end
  notify()
end

return M
