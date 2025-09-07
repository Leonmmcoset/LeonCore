-- LeonCore installer
local INSTALLER_VERSION = "1.0.1 Beta 2"
local DEFAULT_ROM_DIR = "/LeonCore"

print("Start loading LeonCore installer ("..INSTALLER_VERSION..")...")
print("[Installer] Loading module 1")
local function dl(f)
  local hand, err = http.get(f, nil, true)
  if not hand then
    error(err, 0)
  end

  local data = hand.readAll()
  hand.close()

  return data
end
print("[Installer] Loading done.")
print("[Installer] Loading module 2")
-- set up package.loaded for LeonCore libs
package.loaded.rc = {
  expect = require("cc.expect").expect,
  write = write, sleep = sleep
}
print("[Installer] Loading done.")
print("[Installer] Loading module 3")
package.loaded.term = term
package.loaded.colors = colors
_G.require = require
print("[Installer] Loading done.")
print("[Installer] Loading module 4")
function term.at(x, y)
  term.setCursorPos(x, y)
  return term
end
print("[Installer] Loading done.")
print("[Installer] Loading module 5")
local function ghload(f, c)
  return assert(load(dl("https://gh.catmak.name/https://raw.githubusercontent.com/"..f),
    "="..(c or f), "t", _G))()
end
print("[Installer] Loading done.")
print("[Installer] Loading module 6")
local json = ghload("rxi/json.lua/master/json.lua", "ghload(json)")
package.loaded["rc.json"] = json
print("[Installer] Loading done.")
print("[Installer] Loading module 7")
local function rcload(f)
  return ghload(
    "Leonmmcoset/LeonCore/refs/heads/main/data/computercraft/lua/rom/"..f, f)
end
print("[Installer] Loading done.")
print("[Installer] Loading module 8")
-- get LeonCore's textutils with its extra utilities
local tu = rcload("apis/textutils.lua")

local function progress(y, a, b)
  local progress = a/b

  local w = term.getSize()
  local bar = (" "):rep(math.ceil((w-2) * progress))
  term.at(1, y)
  tu.coloredPrint(colors.yellow, "[", {fg=colors.white, bg=colors.white}, bar,
    {fg=colors.white, bg=colors.black}, (" "):rep((w-2)-#bar),
    colors.yellow, "]")
end
term.write("[Installer] Loading done.\n")
-- 程序顶部名称栏
local term = require("term")
local colors = require("colors")
local rc = require("rc")
-- 保存当前颜色设置
local old_fg = term.getTextColor()
local old_bg = term.getBackgroundColor()

-- 设置名称栏颜色并显示
term.setTextColor(colors.white)
term.setBackgroundColor(colors.cyan)
term.at(1, 1).clearLine()
term.at(1, 1).write("=== LeonCore Installer ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)
-- 只清除顶栏以下的区域
for y=2, term.getSize() do
  term.at(1, y).clearLine()
end
term.at(1, 2)
tu.coloredPrint(colors.yellow,
  "LeonCore Installer (v"..INSTALLER_VERSION..")\n=======================")
tu.coloredPrint("You are going to install LeonCore "..INSTALLER_VERSION.." to your computer.")
tu.coloredPrint("This will ",colors.red,"OVERWRITE any existing files", colors.white, " in the computer.")
tu.coloredPrint("If you want to keep the existing files, please backup them first.")
tu.coloredPrint(colors.yellow, "Are you sure? (y/n)")
local confirm = read()
if confirm ~= "y" then
  print("Installation cancelled.")
  return
end

local ROM_DIR
-- tu.coloredPrint("Enter installation directory ", colors.yellow, "[",
--   colors.lightBlue, DEFAULT_ROM_DIR, colors.yellow, "]")
ROM_DIR = DEFAULT_ROM_DIR

ROM_DIR = "/"..shell.resolve(ROM_DIR)

settings.set("LeonCore.rom_dir", ROM_DIR)
settings.save()

tu.coloredPrint(colors.white, "Installing LeonCore "..INSTALLER_VERSION.."...", colors.white)

local function bullet(t)
  tu.coloredWrite(colors.red, "- ", colors.white, t)
end

-- Function for "xxx...OK"
local function ok()
  tu.coloredPrint(colors.green, "OK", colors.white)
end

bullet("Getting repository tree...")

local repodata = dl("https://gh.catmak.name/https://api.github.com/repos/Leonmmcoset/LeonCore/git/trees/main?recursive=1")

repodata = json.decode(repodata)

ok()

bullet("Filtering files...")
local look = "data/computercraft/lua/"
local to_dl = {}
for _, v in pairs(repodata.tree) do
  if v.path and v.path:sub(1,#look) == look then
    v.path = v.path:sub(#look+1)
    -- 特殊处理packages文件夹，将其放在根目录
    if v.path:sub(1, 9) == "packages/" then
      v.real_path = v.path
    else
      v.real_path = v.path:gsub("^/?rom", ROM_DIR)
    end
    to_dl[#to_dl+1] = v
  end
end
ok()

bullet("Creating directories...")
-- 确保缓存目录存在
local cache_dir = "/packages/cache"
if not fs.exists(cache_dir) then
  fs.makeDir(cache_dir)
end

-- 确保应用目录存在
local app_dir = "/app"
if not fs.exists(app_dir) then
  fs.makeDir(app_dir)
end
for i=#to_dl, 1, -1 do
  local v = to_dl[i]
  if v.type == "tree" then
    fs.makeDir(fs.combine(v.real_path))
    table.remove(to_dl, i)
  end
end
ok()

bullet("Downloading files...")
local okx, oky = term.getCursorPos()
io.write("\n")
local _, pby = term.getCursorPos()

local parallels = {}
local done = 0

for i=1, #to_dl, 1 do
  local v = to_dl[i]
  if v.type == "blob" then
    parallels[#parallels+1] = function()
      local data = dl("https://gh.catmak.name/https://raw.githubusercontent.com/Leonmmcoset/LeonCore/refs/heads/main/data/computercraft/lua/"..v.path)
      assert(io.open(v.real_path, "w")):write(data):close()
      done = done + 1
      progress(pby, done, #to_dl)
    end
  end
end

parallel.waitForAll(table.unpack(parallels))

term.at(1, pby).write((" "):rep((term.getSize())))
term.at(okx, oky)
ok()

assert(io.open(
 fs.exists("/startup.lua") and "/unbios-rc.lua" or "/startup.lua", "w"))
  :write(dl(
   "https://gh.catmak.name/https://raw.githubusercontent.com/Leonmmcoset/LeonCore/refs/heads/main/unbios.lua"
  )):close()

tu.coloredPrint(colors.yellow, "Your computer will restart in 3 seconds.")
local _, y = term.getCursorPos()

for i=1, 3, 1 do
  progress(y, i, 3)
  os.sleep(1)
end

os.reboot()
