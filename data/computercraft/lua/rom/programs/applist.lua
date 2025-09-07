-- applist.lua - List applications in /app directory

local fs = require("fs")
local tu = require("textutils")

local function show_help()
  print("Usage: applist [options]")
  print("Lists all applications in the /app directory")
  print("")
  print("Options:")
  print("  --help, -h    Show this help message")
  print("  --verbose, -v Show more details about each application")
end

local function list_apps(verbose)
  local app_dir = "/app"
  
  -- 检查app目录是否存在
  if not fs.exists(app_dir) then
    print("No applications directory found at /app")
    return
  end
  
  -- 获取app目录中的文件列表
  local files = fs.list(app_dir)
  
  if #files == 0 then
    print("No applications installed in /app directory")
    return
  end
  
  print("Installed applications:")
  print("======================")
  
  for _, file in ipairs(files) do
    local file_path = fs.combine(app_dir, file)
    local is_dir = fs.isDir(file_path)
    
    if is_dir then
      -- 如果是目录，可能是一个应用程序文件夹
      print("[" .. file .. "]")
      if verbose then
        -- 在详细模式下，显示目录中的.lua文件
        local sub_files = fs.list(file_path)
        for _, sub_file in ipairs(sub_files) do
          if sub_file:sub(-4) == ".lua" then
            print("  - " .. sub_file)
          end
        end
      end
    elseif file:sub(-4) == ".lua" then
      -- 如果是.lua文件，直接显示
      print(file:sub(1, -5))  -- 移除.lua扩展名
    end
  end
end

local function main(args)
  local verbose = false
  
  -- 解析命令行参数
  for _, arg in ipairs(args) do
    if arg == "--help" or arg == "-h" then
      show_help()
      return
    elseif arg == "--verbose" or arg == "-v" then
      verbose = true
    end
  end
  
  list_apps(verbose)
end

-- 运行主函数
local args = {...}
main(args)