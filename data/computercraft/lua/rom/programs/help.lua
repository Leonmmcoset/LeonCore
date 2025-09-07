-- help

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
term.at(1, 1).write("=== Help System ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

local help = require("help")
local textutils = require("textutils")

local args = {...}

if #args == 0 then
  args[1] = "help"
end

local function view(name)--path)
  textutils.coloredPagedPrint(table.unpack(help.loadTopic(name)))
  --local lines = {}
  --for l in io.lines(path) do lines[#lines+1] = l end
  --textutils.pagedPrint(table.concat(require("cc.strings").wrap(table.concat(lines,"\n"), require("term").getSize()), "\n"))
end

for i=1, #args, 1 do
  local path = help.lookup(args[i])
  if not path then
    error("No help topic for " .. args[i], 0)
  end
  view(args[i])--path)
end
