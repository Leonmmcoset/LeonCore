-- find: File and directory search utility

local term = require("term")
local colors = require("colors")
local fs = require("fs")
local shell = require("shell")
local settings = require("settings")
local textutils = require("textutils")

-- 保存当前颜色设置
local old_fg = term.getTextColor()
local old_bg = term.getBackgroundColor()

-- 设置名称栏颜色并显示
term.setTextColor(colors.white)
term.setBackgroundColor(colors.cyan)
term.at(1, 1).clearLine()
term.at(1, 1).write("=== File and Directory Search ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

-- 显示帮助信息
local function show_help()
  print("Usage: find <path> [pattern] [options]")
  print("")
  print("Description:")
  print("  Recursively search for files and directories.")
  print("")
  print("Arguments:")
  print("  <path>          The directory to start searching from (default: current directory)")
  print("  [pattern]       Optional pattern to match files against (supports * and ? wildcards)")
  print("")
  print("Options:")
  print("  --type <type>   Search only for files (f) or directories (d)")
  print("  --name <name>   Search for files with this exact name")
  print("  --hidden        Include hidden files and directories")
  print("  --case-insensitive, -i  Perform case-insensitive search")
  print("  --help, -h      Show this help message")
  print("")
  print("Examples:")
  print("  find . *.lua                # Find all Lua files in current directory and subdirectories")
  print("  find /rom --type d          # Find all directories under /rom")
  print("  find /app --name config.lua # Find file named config.lua under /app")
  print("  find . --hidden             # Find all files including hidden ones")
end

-- 检查字符串是否匹配模式（支持*和?通配符）
local function matches_pattern(str, pattern, case_insensitive)
  if case_insensitive then
    str = str:lower()
    pattern = pattern:lower()
  end

  -- 转换通配符模式为Lua正则表达式
  pattern = pattern:gsub("%.", "%%.")
                  :gsub("%*%%%*", ".*")
                  :gsub("%*", "[^/]*")
                  :gsub("%?", ".")

  return str:match("^" .. pattern .. "$") ~= nil
end

-- 递归搜索文件和目录
local function search(path, options, results)
  path = shell.resolve(path)
  results = results or {}

  if not fs.exists(path) then
    io.stderr:write("Error: Path '" .. path .. "' does not exist.\n")
    return results
  end

  if not fs.isDir(path) then
    -- 如果传入的是文件而不是目录，直接检查是否匹配
    local name = fs.getName(path)
    local include = true

    if options.type == "d" then
      include = false
    elseif options.name and name ~= options.name then
      include = false
    elseif options.pattern and not matches_pattern(name, options.pattern, options.case_insensitive) then
      include = false
    elseif not options.hidden and name:sub(1, 1) == "." then
      include = false
    end

    if include then
      results[#results + 1] = path
    end
    return results
  end

  -- 遍历目录
  local files = fs.list(path)
  for _, name in ipairs(files) do
    local full_path = fs.combine(path, name)
    local is_dir = fs.isDir(full_path)
    local include = true

    -- 检查是否要包含此文件/目录
    if options.type == "f" and is_dir then
      include = false
    elseif options.type == "d" and not is_dir then
      include = false
    elseif options.name and name ~= options.name then
      include = false
    elseif options.pattern and not matches_pattern(name, options.pattern, options.case_insensitive) then
      include = false
    elseif not options.hidden and name:sub(1, 1) == "." then
      include = false
    end

    if include then
      results[#results + 1] = full_path
    end

    -- 递归搜索子目录
    if is_dir then
      search(full_path, options, results)
    end
  end

  return results
end

-- 主函数
local function main(args)
  -- 解析命令行参数
  local options = {
    type = nil,    -- f: 文件, d: 目录
    name = nil,    -- 精确文件名
    pattern = nil, -- 通配符模式
    hidden = settings.get("list.show_hidden"), -- 是否显示隐藏文件
    case_insensitive = false
  }

  local path = shell.dir()
  local i = 1

  while i <= #args do
    if args[i] == "--help" or args[i] == "-h" then
      show_help()
      return
    elseif args[i] == "--type" and i < #args then
      i = i + 1
      options.type = args[i]
      if options.type ~= "f" and options.type ~= "d" then
        io.stderr:write("Error: Invalid type. Use 'f' for files or 'd' for directories.\n")
        return
      end
    elseif args[i] == "--name" and i < #args then
      i = i + 1
      options.name = args[i]
    elseif args[i] == "--hidden" then
      options.hidden = true
    elseif args[i] == "--case-insensitive" or args[i] == "-i" then
      options.case_insensitive = true
    elseif args[i]:sub(1, 1) == "-" then
      io.stderr:write("Error: Unknown option '" .. args[i] .. "'\n")
      show_help()
      return
    elseif not options.pattern and path == shell.dir() then
      -- 第一个非选项参数是路径
      path = args[i]
    else
      -- 第二个非选项参数是模式
      options.pattern = args[i]
    end
    i = i + 1
  end

  -- 执行搜索
  local results = search(path, options)

  -- 输出结果
  if #results == 0 then
    print("No matching files or directories found.")
  else
    print("Found " .. #results .. " matching " .. (options.type == "f" and "files" or options.type == "d" and "directories" or "items") .. ":")
    for _, result in ipairs(results) do
      local is_dir = fs.isDir(result)
      if is_dir then
        term.setTextColor(colors.green)
      else
        term.setTextColor(colors.white)
      end
      print("  " .. result)
      term.setTextColor(old_fg)
    end
  end
end

-- 运行主函数
local args = {...}
main(args)