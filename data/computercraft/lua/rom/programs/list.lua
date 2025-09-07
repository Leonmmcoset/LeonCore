-- list

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
term.at(1, 1).write("=== File Listing Utility ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

local args = {...}
local fs = require("fs")
local shell = require("shell")
local settings = require("settings")
local textutils = require("textutils")

if #args == 0 then args[1] = shell.dir() end

local show_hidden = settings.get("list.show_hidden")

local function list_dir(dir)
  if not fs.exists(dir) then
    error(dir .. ": that directory does not exist", 0)
  elseif not fs.isDir(dir) then
    error(dir .. ": not a directory", 0)
  end

  local raw_files = fs.list(dir)
  local files, dirs = {}, {}

  for i=1, #raw_files, 1 do
    local full = fs.combine(dir, raw_files[i])

    if raw_files[i]:sub(1,1) ~= "." or show_hidden then
      if fs.isDir(full) then
        dirs[#dirs+1] = raw_files[i]

      else
        files[#files+1] = raw_files[i]
      end
    end
  end

  textutils.pagedTabulate(colors.green, dirs, colors.white, files)
end

for i=1, #args, 1 do
  if #args > 1 then
    textutils.coloredPrint(colors.yellow, args[i]..":\n", colors.white)
  end
  list_dir(args[i])
end