-- threads

-- 程序顶部名称栏
local term = require("term")
local colors = require("colors")

-- 保存当前颜色设置
local old_fg = term.getTextColor()
local old_bg = term.getBackgroundColor()

-- 设置名称栏颜色并显示
term.setTextColor(colors.white)
term.setBackgroundColor(colors.cyan)
term.at(1, 1).clearLine()
term.at(1, 1).write("=== Thread Manager ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

local thread = require("rc.thread")
local strings = require("cc.strings")
local textutils = require("textutils")

textutils.coloredPrint(colors.yellow, "id   tab  name", colors.white)

local info = thread.info()
for i=1, #info, 1 do
  local inf = info[i]
  textutils.pagedPrint(string.format("%s %s %s",
    strings.ensure_width(tostring(inf.id), 4),
    strings.ensure_width(tostring(inf.tab), 4), inf.name))
end
