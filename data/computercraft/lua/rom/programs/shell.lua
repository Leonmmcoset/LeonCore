-- rc.shell

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
term.at(1, 1).write("=== LeonCore Shell ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

local rc = require("rc")
local fs = require("fs")
local shell = require("shell")
local thread = require("rc.thread")
local textutils = require("textutils")

if os.version then
  textutils.coloredPrint(colors.yellow, os.version(), colors.white)
else
  textutils.coloredPrint(colors.yellow, rc.version(), colors.white)
end

thread.vars().parentShell = thread.id()
shell.init(_ENV)

if not shell.__has_run_startup then
  shell.__has_run_startup = true
  if fs.exists("/startup.lua") then
    local ok, err = pcall(dofile, "/startup.lua")
    if not ok and err then
      io.stderr:write(err, "\n")
    end
  end

  if fs.exists("/startup") and fs.isDir("/startup") then
    local files = fs.list("/startup/")
    table.sort(files)

    for f=1, #files, 1 do
      local ok, err = pcall(dofile, "/startup/"..files[f])
      if not ok and err then
        io.stderr:write(err, "\n")
      end
    end
  end
end

local aliases = {
  background = "bg",
  clr = "clear",
  cp = "copy",
  dir = "list",
  foreground = "fg",
  mv = "move",
  rm = "delete",
  rs = "redstone",
  sh = "shell",
  ps = "threads",
  restart = "reboot",
  version = "ver",
  package = "pkg"
}

for k, v in pairs(aliases) do
  shell.setAlias(k, v)
end

local completions = "/LeonCore/completions"
for _, prog in ipairs(fs.list(completions)) do
  dofile(fs.combine(completions, prog))
end

local history = {}
-- local image = paintutils.parseImage([[
--  f  f

-- f    f
--  ffff
-- ]])
-- paintutils.drawImage(image, term.getCursorPos())
-- textutils.coloredPrint(colors.yellow, "Welcome using the beta version of LeonCore!", colors.white)
while true do
  term.setTextColor(colors.yellow)
  rc.write("$ "..shell.dir().." # ")
  term.setTextColor(colors.white)

  local text = term.read(nil, history, shell.complete)
  if #text > 0 then
    history[#history+1] = text
    
    -- 运行命令前先清除控制台内容，但保留顶部应用栏
    local w, h = term.getSize()
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    for y=2, h do
      term.at(1, y).clearLine()
    end
    term.at(1, 2)
    
    local ok, err = shell.run(text)
    if not ok and err then
      io.stderr:write("Application has a error when running and system has stop it. Error:\n", err, "\n")
    end
  end
end