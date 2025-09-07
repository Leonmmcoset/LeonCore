-- CatOS web installer: wget run https://catos.cpolar.cn/install.lua
-- This CatOS installer is for LeonOS
-- Require
fs = require("fs")
http = require("http")
term = require("term")
colors = require("colors")
textutils = require("textutils")
-- Main
local SITE = "https://catos.cpolar.cn"
textutils.coloredPrint("You are going to install CatOS to your computer.")
textutils.coloredPrint("We suggest you backup the files before install the CatOS.")
textutils.coloredPrint(colors.yellow, "Are you sure? (y/n)")
local confirm = read()
if confirm ~= "y" then
  print("Installation cancelled.")
  return
end
local function http_get(url)
	local r = http.get(url)
	if not r then error("request failed: " .. url) end
	local s = r.readAll() or ""; r.close(); return s
end

local function write_file(path, content)
	local dir = fs.getDir(path)
	if dir ~= "" and not fs.exists(dir) then fs.makeDir(dir) end
	local h = fs.open(path, "w")
	if not h then error("cannot write: " .. path) end
	h.write(content or "")
	h.close()
end

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)
print("CatOS installer - fetching manifest...")
local manifest_json = http_get(SITE .. "/repo/catos-manifest.json")
local ok, manifest = pcall(textutils.unserializeJSON, manifest_json)
if not ok or type(manifest) ~= "table" then error("invalid manifest") end

local base = manifest.base or "/root"
local files = manifest.files or {}
local total = #files
local i = 0
for _, rel in ipairs(files) do
	i = i + 1
	-- black overlay with progress
	local w,h = term.getSize()
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	term.setCursorPos(1,1); term.clearLine()
	print(string.format("Installing CatOS [%d/%d] %s", i, total, rel))
	-- draw progress bar at line 3
	local pct = math.floor((i-1)/math.max(1,total) * (w-2))
	term.setCursorPos(1,3)
	term.clearLine()
	term.write("[")
	term.write(string.rep("#", pct))
	term.write(string.rep("-", (w-2)-pct))
	term.write("]")
	local content = http_get(SITE .. base .. "/" .. rel)
	write_file(rel, content)
end

term.setCursorPos(1,5)
print("CatOS installed. Type 'restart' to complete the installation.")
