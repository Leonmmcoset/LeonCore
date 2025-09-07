-- update: download a new copy of LeonOS

local rc = require("rc")
local term = require("term")
local colors = require("colors")
local textutils = require("textutils")

if not package.loaded.http then
  io.stderr:write("The HTTP API is disabled and the updater cannot continue.  Please enable the HTTP API in the ComputerCraft configuration and try again.\n")
  return
end
term.at(1, 1).clear()

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
term.at(1, 1).write("=== LeonOS Updater ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)
-- 只清除顶栏以下的区域
for y=2, term.getSize() do
  term.at(1, y).clearLine()
end
term.at(1, 2)

textutils.coloredPrint(colors.yellow,
  "LeonOS Updater (Step 1)\n===========================")

print("Checking for update...")

local http = require("http")
local base = "https://gh.catmak.name/https://raw.githubusercontent.com/Leonmmcoset/LeonOS/refs/heads/main/"

local Bhandle, Berr = http.get(base .. "data/computercraft/lua/bios.lua")
if not Bhandle then
  error(Berr, 0)
end

local first = Bhandle.readLine()
Bhandle.close()

local oldVersion = rc.version():gsub("LeonOS ", "")
local newVersion = first:match("LeonOS v?(%d+.%d+.%d+)")

if newVersion and (oldVersion ~= newVersion) or (...) == "-f" then
  textutils.coloredPrint(colors.green, "Found", colors.white, ": ",
    colors.red, oldVersion, colors.yellow, " -> ", colors.lime,
    newVersion or oldVersion)

  io.write("Apply update? [y/n]: ")
  if io.read() ~= "y" then
    textutils.coloredPrint(colors.red, "Not applying update.")
    return
  end

  textutils.coloredPrint(colors.green, "Applying update.")
  local handle, err = http.get(base.."updater.lua", nil, true)
  if not handle then
    error("Failed downloading step 2: " .. err, 0)
  end

  local data = handle.readAll()
  handle.close()

  local out = io.open("/.start_rc.lua", "w")
  out:write(data)
  out:close()

  textutils.coloredWrite(colors.yellow, "Restarting...")
  rc.sleep(3)
  rc.reboot()
else
  textutils.coloredPrint(colors.red, "None found")
end
