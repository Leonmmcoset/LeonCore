-- app.lua - Application launcher for LeonOS
local fs = require("fs")
local shell = require("shell")

local function show_help()
  print("Usage: app <program_name> [arguments]")
  print("Runs an application from the /app directory")
  print("")
  print("Options:")
  print("  --help, -h    Show this help message")
end

local function main(args)
  if #args == 0 or args[1] == "--help" or args[1] == "-h" then
    show_help()
    return
  end

  local program_name = args[1]
  local program_args = {}
  
  -- 提取程序参数
  for i=2, #args do
    table.insert(program_args, args[i])
  end
  
  -- 构建程序路径
  local program_path = fs.combine("/app", program_name)
  
  -- 检查程序是否存在
  if not fs.exists(program_path) then
    -- 尝试添加.lua扩展名
    program_path = program_path .. ".lua"
    if not fs.exists(program_path) then
      print("Error: Application '" .. args[1] .. "' not found in /app directory")
      return
    end
  end
  
  -- 运行程序
  print("Running application: " .. program_name)
  local success, error_msg = pcall(function()
    shell.run(program_path, table.unpack(program_args))
  end)
  
  if not success then
    print("Error running application: " .. error_msg)
  end
end

-- 运行主函数
local args = {...}
main(args)