-- alias

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
term.at(1, 1).write("=== Shell Alias Manager ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

local args = {...}
local shell = require("shell")
local textutils = require("textutils")

if #args == 0 then
  textutils.coloredPrint(colors.yellow, "shell aliases", colors.white)

  local aliases = shell.aliases()

  local _aliases = {}
  for k, v in pairs(aliases) do
    table.insert(_aliases, {colors.cyan, k, colors.white, ":", v})
  end

  textutils.pagedTabulate(_aliases)

elseif #args == 1 then
  shell.clearAlias(args[1])

elseif #args == 2 then
  shell.setAlias(args[1], args[2])

else
  error("this program takes a maximum of two arguments", 0)
end
