-- tree

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
term.at(1, 1).write("=== Directory Tree Utility ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

local args = {...}
local fs = require("fs")
local shell = require("shell")
local settings = require("settings")

if #args == 0 then args[1] = shell.dir() end

local show_hidden = settings.get("list.show_hidden")

-- 递归打印目录树
local function print_tree(dir, prefix, is_last)
  if not fs.exists(dir) then
    error(dir .. ": that directory does not exist", 0)
  elseif not fs.isDir(dir) then
    error(dir .. ": not a directory", 0)
  end

  local raw_files = fs.list(dir)
  local files, dirs = {}, {}

  -- 分离目录和文件
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

  -- 排序目录和文件
  table.sort(dirs)
  table.sort(files)

  -- 打印当前目录
  if prefix == "" then
    term.setTextColor(colors.yellow)
    print(dir)
    term.setTextColor(old_fg)
  end

  -- 打印目录
  for i=1, #dirs, 1 do
    local is_last_dir = (i == #dirs and #files == 0)
    local connector = is_last_dir and "└── " or "├── "
    local new_prefix = prefix .. (is_last_dir and "    " or "│   ")

    term.setTextColor(colors.green)
    print(prefix .. connector .. dirs[i])
    term.setTextColor(old_fg)

    -- 递归打印子目录
    print_tree(fs.combine(dir, dirs[i]), new_prefix, is_last_dir)
  end

  -- 打印文件
  for i=1, #files, 1 do
    local is_last_file = (i == #files)
    local connector = is_last_file and "└── " or "├── "

    term.setTextColor(colors.white)
    print(prefix .. connector .. files[i])
    term.setTextColor(old_fg)
  end
end

for i=1, #args, 1 do
  print_tree(args[i], "", true)
end