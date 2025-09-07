-- lua REPL

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
term.at(1, 1).write("=== Lua REPL ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

local copy = require("rc.copy").copy
local pretty = require("cc.pretty")
local textutils = require("textutils")

local env = copy(_ENV, package.loaded)

local run = true
function env.exit() run = false end

term.setTextColor(colors.yellow)

print("LeonOS Lua REPL.\nCall exit() to exit.")

local history = {}
while run do
  term.setTextColor(colors.white)
  io.write("$ lua >>> ")
  local data = term.read(nil, history, function(text)
    return textutils.complete(text, env)
  end)
  if #data > 0 then
    history[#history+1] = data
  end

  local ok, err = load("return " .. data, "=stdin", "t", env)
  if not ok then
    ok, err = load(data, "=stdin", "t", env)
  end

  if ok then
    local result = table.pack(pcall(ok))
    if not result[1] then
      io.stderr:write(result[2], "\n")
    elseif result.n > 1 then
      for i=2, result.n, 1 do
        pretty.pretty_print(result[i])
      end
    end
  else
    io.stderr:write(err, "\n")
  end
end
