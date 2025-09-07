-- launch different editors based on computer capabilities
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
term.at(1, 1).write("=== Editor ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)

local term = require("term")
local settings = require("settings")

local df = function(f, ...) return assert(loadfile(f))(...) end

if term.isColor() or settings.get("edit.force_highlight") then
  df("/leonos/editors/advanced.lua", ...)
else
  df("/leonos/editors/basic.lua", ...)
end
