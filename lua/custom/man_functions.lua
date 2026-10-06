-- 手册模糊搜索：一个函数一个条目（带说明）
--
-- 解决的问题：snacks.nvim 内置的 man picker（LazyVim 的 <leader>sM）在 macOS 上
-- 体验很差 —— 它跑 `man -k .` 并用正则 `^(%S+)%s*%((%S-)%)%s+-%s+(.+)$` 解析，
-- 要求「一行一个名字」；而 macOS 的 whatis 会把同族函数塞进一行：
--     index(3), rindex(3), stpcpy(3), strcasecmp(3), strcat(3), ... - string specific functions
-- 这种行要么匹配失败被丢弃，要么只显示成一个「组名」，于是出现
-- 「列出整个库的函数、且没有说明」的现象。
--
-- 本模块的做法：把 whatis 每一行按逗号拆开，让每个函数名成为独立条目，并沿用该行的
-- 说明文字；预览与打开都走 nvim 自带的 :Man（已实测每个名字都能单独解析，
-- 例如 man -w index → index.3、man -w strlen → strlen.3）。
--
-- 索引构建约 1.3 秒，因此走异步：VeryLazy 后台预热，按 <leader>cKm 时若还没建好
-- 会提示并在完成后自动打开，绝不阻塞界面。

local M = {}

---@type snacks.picker.finder.Item[]|nil
local cache = nil
local building = false
---@type fun(items: snacks.picker.finder.Item[])[]
local waiters = {}

--- 解析 whatis 全量输出
---@param text string
---@return snacks.picker.finder.Item[]
local function parse(text)
  local items, seen = {}, {}
  for line in vim.gsplit(text, "\n", { plain = true }) do
    -- 行格式：<名字列表> - <说明>；只切第一个 " - "
    local names, desc = line:match("^(.-)%s+%-%s+(.+)$")
    if names and desc then
      -- 名字列表形如 "index(3), rindex(3), stpcpy(3)"
      for name, section in names:gmatch("([%w_%.%+%-]+)%(([%w]+)%)") do
        local key = name .. "(" .. section .. ")"
        if not seen[key] then
          seen[key] = true
          items[#items + 1] = {
            page = name,
            section = section,
            desc = desc,
            text = ("%s (%s) %s"):format(name, section, desc),
          }
        end
      end
    end
  end
  return items
end

--- 缓存是否已就绪
---@return boolean
function M.ready()
  return cache ~= nil
end

--- 确保索引可用（异步；已就绪则立即回调）
---@param cb fun(items: snacks.picker.finder.Item[])
function M.ensure(cb)
  if cache then
    cb(cache)
    return
  end
  waiters[#waiters + 1] = cb
  if building then
    return
  end
  building = true
  vim.system({ "man", "-k", "." }, { text = true }, function(obj)
    vim.schedule(function()
      cache = parse(obj.stdout or "")
      building = false
      local pending = waiters
      waiters = {}
      for _, f in ipairs(pending) do
        f(cache)
      end
    end)
  end)
end

--- 同步构建（仅供测试/兜底使用）
---@return snacks.picker.finder.Item[]
function M.build_sync()
  if not cache then
    cache = parse(vim.fn.system({ "man", "-k", "." }))
  end
  return cache
end

--- 打开选择器：一个函数一个条目，右侧预览 man 页
function M.pick()
  local function open(items)
    Snacks.picker.pick({
      title = ("手册 · 按函数名（%d 条）"):format(#items),
      items = items,
      format = "man", -- 需要 item.page / item.section / item.desc
      preview = "man", -- 右侧预览直接渲染 man 页
      confirm = function(picker, item)
        picker:close()
        if not item then
          return
        end
        vim.schedule(function()
          -- 优先精确到 section；失败则退回按名字搜索（跨 section）
          if not pcall(vim.cmd, ("Man %s %s"):format(item.section, item.page)) then
            if not pcall(vim.cmd, "Man " .. item.page) then
              vim.notify("找不到手册页: " .. tostring(item.page), vim.log.levels.WARN)
            end
          end
        end)
      end,
    })
  end

  if cache then
    open(cache)
  else
    vim.notify("正在建立手册索引（约 1 秒），完成后自动打开…", vim.log.levels.INFO)
    M.ensure(open)
  end
end

--- 后台预热：VeryLazy 之后开始建索引，之后按键即瞬时
function M.setup()
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function()
      M.ensure(function() end)
    end,
  })
end

return M
