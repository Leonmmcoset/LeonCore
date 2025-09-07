-- appdelete.lua - Delete applications from /app directory

local fs = require("fs")
local tu = require("textutils")
local shell = require("shell")

local function show_help()
  print("Usage: appdelete <application_name> [options]")
  print("Deletes an application from the /app directory")
  print("")
  print("Options:")
  print("  --help, -h    Show this help message")
  print("  --force, -f   Force deletion without confirmation")
end

local function delete_app(app_name, force)
  local app_dir = "/app"
  
  -- 检查app目录是否存在
  if not fs.exists(app_dir) then
    print("Error: Applications directory not found at /app")
    return false
  end
  
  -- 构建应用程序路径
  local app_path = fs.combine(app_dir, app_name)
  
  -- 检查应用程序是否存在
  if not fs.exists(app_path) then
    -- 尝试添加.lua扩展名
    local lua_app_path = app_path .. ".lua"
    if fs.exists(lua_app_path) then
      app_path = lua_app_path
    else
      print("Error: Application '" .. app_name .. "' not found in /app directory")
      return false
    end
  end
  
  -- 确认删除
  if not force then
    print("Are you sure you want to delete '" .. app_name .. "'? (y/n)")
    local confirm = io.read()
    if confirm ~= "y" and confirm ~= "yes" then
      print("Deletion cancelled.")
      return false
    end
  end
  
  -- 删除应用程序
  local is_dir = fs.isDir(app_path)
  local success, error_msg
  
  if is_dir then
    success, error_msg = pcall(function()
      -- 删除目录及其内容
      for _, file in ipairs(fs.list(app_path)) do
        local file_path = fs.combine(app_path, file)
        if fs.isDir(file_path) then
          -- 递归删除子目录
          fs.delete(file_path)
        else
          -- 删除文件
          fs.delete(file_path)
        end
      end
      -- 删除空目录
      fs.delete(app_path)
    end)
  else
    -- 删除单个文件
    success, error_msg = pcall(fs.delete, app_path)
  end
  
  if success then
    print("Application '" .. app_name .. "' deleted successfully.")
    return true
  else
    print("Error deleting application: " .. error_msg)
    return false
  end
end

local function main(args)
  if #args == 0 then
    show_help()
    return
  end
  
  local app_name = nil
  local force = false
  
  -- 解析命令行参数
  for _, arg in ipairs(args) do
    if arg == "--help" or arg == "-h" then
      show_help()
      return
    elseif arg == "--force" or arg == "-f" then
      force = true
    elseif not app_name then
      app_name = arg
    else
      -- 多余的参数
      print("Error: Too many arguments")
      show_help()
      return
    end
  end
  
  if not app_name then
    print("Error: Missing application name")
    show_help()
    return
  end
  
  delete_app(app_name, force)
end

-- 运行主函数
local args = {...}
main(args)