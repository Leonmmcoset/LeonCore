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
term.at(1, 1).write("=== Connected Peripherals ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

local peripheral = require("peripheral")

term.setTextColor(colors.yellow)
print("Connected Peripherals:")
term.setTextColor(colors.white)
local names = peripheral.getNames()

if #names == 0 then
  io.stderr:write("none\n")
else
  for i=1, #names, 1 do
    print(string.format("%s (%s)", names[i], peripheral.getType(names[i])))
  end
end
