-- 'set' program

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
term.at(1, 1).write("=== Settings Manager ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

local settings = require("settings")
local textutils = require("textutils")

local args = {...}

local function coerce(val)
  if val == "nil" then
    return nil
  elseif val == "false" then
    return false
  elseif val == "true" then
    return true
  else
    return tonumber(val) or val
  end
end

local col = {
  string = colors.red,
  table = colors.green,
  number = colors.magenta,
  boolean = colors.lightGray
}

if #args == 0 then
  for _, setting in ipairs(settings.getNames()) do
    local value = settings.get(setting)
    textutils.coloredPrint(colors.cyan, setting, colors.white, " is ",
      col[type(value)], string.format("%q", value))
  end
elseif #args == 1 then
  local setting = args[1]
  local value = settings.get(setting)
  textutils.coloredPrint(colors.cyan, setting, colors.white, " is ",
    col[type(value)], string.format("%q", value))
  local def = settings.getDetails(setting)
  if def then
    print(def.description)
  end
else
  local setting, value = args[1], args[2]
  settings.set(setting, coerce(value))
  settings.save()
end
