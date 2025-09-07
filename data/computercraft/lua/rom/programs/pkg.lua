-- pkg: Lightweight package manager for LeonOS

-- 程序顶部名称栏
local term = require("term")
local colors = require("colors")
local fs = require("fs")
local shell = require("shell")
local textutils = require("textutils")
local http = require("http")

-- 保存当前颜色设置
local old_fg = term.getTextColor()
local old_bg = term.getBackgroundColor()

-- 设置名称栏颜色并显示
term.setTextColor(colors.white)
term.setBackgroundColor(colors.cyan)
term.at(1, 1).clearLine()
term.at(1, 1).write("=== LeonOS Package Manager ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

-- 包管理器配置
local pkg_config = {
  repo_url = "https://example.com/leonos/packages", -- 包仓库URL
  local_pkg_dir = "/packages",                     -- 本地包存储目录
  installed_db = "/packages/installed.json",       -- 已安装包数据库
  cache_dir = "/packages/cache"                     -- 缓存目录
}

-- 创建新包
local function create_package(pkg_name)
  print("Creating new package: " .. pkg_name)

  -- 确保包目录存在
  local pkg_version = "1.0.0"
  local pkg_dir = fs.combine(pkg_config.local_pkg_dir, pkg_name)
  local version_dir = fs.combine(pkg_dir, pkg_version)
  if not fs.exists(pkg_dir) then
    fs.makeDir(pkg_dir)
  end
  if not fs.exists(version_dir) then
    fs.makeDir(version_dir)
  end

  -- 创建package.json文件
  local package_json = {
    name = pkg_name,
    version = pkg_version,
    description = "A new package for LeonOS",
    author = "LeonOS User",
    license = "MIT",
    dependencies = {},
    files = {
      pkg_name .. ".lua"
    }
  }
  local json_file = io.open(fs.combine(version_dir, "package.json"), "w")
  if json_file then
    json_file:write(textutils.serializeJSON(package_json, false))
    json_file:close()
    print("Created package.json")
  else
    print("Error: Failed to create package.json")
    return false
  end

  -- 创建主代码文件
  local main_file_path = fs.combine(version_dir, pkg_name .. ".lua")
  local main_file = io.open(main_file_path, "w")
  if main_file then
    local main_file_content = [[-- ]] .. pkg_name .. [[ Package
local colors = require('colors')
local term = require('term')

function drawTopBar()
  local w, h = term.getSize()
  term.setBackgroundColor(colors.cyan)
  term.setTextColor(colors.white)
  term.setCursorPos(1, 1)
  term.clearLine()
  local title = "=== ]] .. pkg_name .. [[ v]] .. pkg_version .. [[ ==="
  local pos = math.floor((w - #title) / 2) + 1
  term.setCursorPos(pos, 1)
  term.write(title)
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.setCursorPos(1, 3)
end

drawTopBar()
print("\nThis is the ]] .. pkg_name .. [[ package for LeonOS.")
print("\nUsage:")
print("  pkg install ]] .. pkg_name .. [[  - Install this package")
print("  pkg remove ]] .. pkg_name .. [[   - Uninstall this package")
print("  pkg list                 - List installed packages")
]]
    main_file:write(main_file_content)
    main_file:close()
    print("Created " .. pkg_name .. ".lua")
  else
    print("Error: Failed to create " .. pkg_name .. ".lua")
    return false
  end

  print("Package created successfully at: " .. version_dir)
  print("You can now edit the package files and install it with 'pkg install ]] .. pkg_name .. [['")
  return true
end

-- 确保必要的目录存在
local function ensure_dirs()
  if not fs.exists(pkg_config.local_pkg_dir) then
    fs.makeDir(pkg_config.local_pkg_dir)
  end
  if not fs.exists(pkg_config.cache_dir) then
    fs.makeDir(pkg_config.cache_dir)
  end
end

-- 加载已安装的包数据库
local function load_installed_db()
  ensure_dirs()
  if fs.exists(pkg_config.installed_db) then
    local file = io.open(pkg_config.installed_db, "r")
    if file then
      local content = file:read("*a")
      file:close()
      local ok, data = pcall(textutils.unserializeJSON, content)
      if ok and data then
        return data
      end
    end
  end
  return { packages = {} }
end

-- 保存已安装的包数据库
local function save_installed_db(db)
  local file = io.open(pkg_config.installed_db, "w")
  if file then
    file:write(textutils.serializeJSON(db, false))
    file:close()
    return true
  end
  return false
end

-- 显示帮助信息
local function show_help()
  print("Usage: pkg <command> [options]")
  print("")
  print("Commands:")
  print("  install <package>    Install a package")
  print("  update <package>     Update a package (leave empty to update all)")
  print("  remove <package>     Remove a package")
  print("  list                 List all installed packages")
  print("  search <query>       Search for packages")
  print("  info <package>       Show package information")
  print("  init <package>       Create a new package")
  print("  help                 Show this help message")
  print("")
  print("Options:")
  print("  --local              Install from local file")
  print("  --force              Force install/update")
end

-- 安装包
local function install_package(pkg_name, options)
  print("Installing package: " .. pkg_name)
  ensure_dirs()
  local installed_db = load_installed_db() or { packages = {} }

  -- 检查是否已安装
  if installed_db.packages[pkg_name] and not options.force then
    print("Package already installed. Use --force to reinstall.")
    return false
  end

  -- 本地包安装逻辑
  local pkg_path = fs.combine(pkg_config.local_pkg_dir, pkg_name)
  if not fs.exists(pkg_path) then
    print("Package not found in local repository.")
    return false
  end

  -- 查找最新版本
  local versions = fs.list(pkg_path)
  if #versions == 0 then
    print("No versions found for package.")
    return false
  end
  table.sort(versions)
  local latest_version = versions[#versions]
  local version_path = fs.combine(pkg_path, latest_version)

  -- 读取包元数据
  local meta_path = fs.combine(version_path, "package.json")
  if not fs.exists(meta_path) then
    print("Package metadata not found.")
    return false
  end

  local file = io.open(meta_path, "r")
  local meta_content = file:read("*a")
  file:close()
  local ok, meta = pcall(textutils.unserializeJSON, meta_content)
  if not ok or not meta then
    print("Invalid package metadata.")
    return false
  end

  -- 安装文件
  print("Installing version: " .. latest_version)
  -- 确保app目录存在
  local app_dir = "/app"
  if not fs.exists(app_dir) then
    fs.makeDir(app_dir)
  end
  
  for _, file_path in ipairs(meta.files or {}) do
    local src = fs.combine(version_path, file_path)
    local dest = fs.combine(app_dir, file_path)
    
    -- 确保目标目录存在
    local dest_dir = fs.getDir(dest)
    if not fs.exists(dest_dir) then
      fs.makeDir(dest_dir)
    end
    
    -- 复制文件
    if fs.exists(src) then
      fs.copy(src, dest)
      print("Installed: " .. file_path)
    else
      print("Warning: File not found: " .. src)
    end
  end

  -- 记录安装信息
  installed_db.packages[pkg_name] = {
    version = latest_version,
    installed = os.time(),
    description = meta.description or "",
    author = meta.author or ""
  }

  if save_installed_db(installed_db) then
    print("Package installed successfully.")
    return true
  else
    print("Failed to update package database.")
    return false
  end
end

-- 更新包
local function update_package(pkg_name, options)
  print("Updating package: " .. (pkg_name or "all packages"))
  local installed_db = load_installed_db()

  if pkg_name then
    -- 更新单个包
    if not installed_db.packages[pkg_name] then
      print("Package not installed.")
      return false
    end
    
    -- 检查本地仓库是否有新版本
    local pkg_path = fs.combine(pkg_config.local_pkg_dir, pkg_name)
    if not fs.exists(pkg_path) then
      print("Package not found in local repository.")
      return false
    end
    
    local versions = fs.list(pkg_path)
    if #versions == 0 then
      print("No versions found for package.")
      return false
    end
    
    table.sort(versions)
    local latest_version = versions[#versions]
    local current_version = installed_db.packages[pkg_name].version
    
    if latest_version == current_version and not options.force then
      print("Package is already up to date.")
      return true
    end
    
    -- 移除旧版本
    if not remove_package(pkg_name) then
      print("Failed to remove old version.")
      return false
    end
    
    -- 安装新版本
    return install_package(pkg_name, { force = true })
  else
    -- 更新所有包
    local count = 0
    for name, _ in pairs(installed_db.packages) do
      print("Updating " .. name .. "...")
      if update_package(name, options) then
        count = count + 1
      end
    end
    print("Updated " .. count .. " packages.")
  end
  return true
end

-- 移除包
local function remove_package(pkg_name)
  print("Removing package: " .. pkg_name)
  local installed_db = load_installed_db()

  if not installed_db.packages[pkg_name] then
    print("Package not installed.")
    return false
  end

  -- 读取包元数据以了解要删除的文件
  local pkg_info = installed_db.packages[pkg_name]
  local pkg_path = fs.combine(pkg_config.local_pkg_dir, pkg_name)
  local version_path = fs.combine(pkg_path, pkg_info.version)
  local meta_path = fs.combine(version_path, "package.json")

  if fs.exists(meta_path) then
    local file = io.open(meta_path, "r")
    local meta_content = file:read("*a")
    file:close()
    local ok, meta = pcall(textutils.unserializeJSON, meta_content)
    if ok and meta then
      -- 删除包文件
      for _, file_path in ipairs(meta.files or {}) do
        local dest = fs.combine("/rom", file_path)
        if fs.exists(dest) then
          fs.delete(dest)
          print("Removed: " .. file_path)
        end
      end
    end
  end

  -- 从数据库中删除
  installed_db.packages[pkg_name] = nil

  if save_installed_db(installed_db) then
    print("Package removed successfully.")
    return true
  else
    print("Failed to update package database.")
    return false
  end
end

-- 列出已安装的包
local function list_packages()
  local installed_db = load_installed_db()
  if not installed_db.packages or not next(installed_db.packages) then
    print("No packages installed.")
    return
  end
  print("Installed packages:")
  print("====================")
  for name, info in pairs(installed_db.packages) do
    print(name .. " (v" .. info.version .. ")")
    print("  Description: " .. (info.description or "No description"))
    print("  Author: " .. (info.author or "Unknown"))
    print("  Installed: " .. os.date("%Y-%m-%d %H:%M:%S", info.installed))
    print("----------------")
  end
end

-- 搜索包
local function search_packages(query)
  print("Searching for packages matching: " .. query)
  -- 这里是搜索逻辑的占位符
  -- 实际实现需要查询包仓库

  -- 模拟搜索结果
  print("Found 2 packages:")
  print("  example-pkg - An example package")
  print("  demo-app - A demonstration application")
end

-- 显示包信息
local function show_package_info(pkg_name)
  print("Information for package: " .. pkg_name)
  -- 这里是获取包信息逻辑的占位符

  -- 模拟包信息
  print("  Name: " .. pkg_name)
  print("  Version: 1.0.0")
  print("  Description: A sample package for LeonOS")
  print("  Author: LeonOS Team")
  print("  Dependencies: none")
end

-- 主函数
local function main(args)
  if #args == 0 then
    show_help()
    return
  end

  local command = args[1]
  local options = {
    force = false,
    local_file = false
  }

  -- 解析选项
  local pkg_args = {}
  for i=2, #args do
    if args[i] == "--force" then
      options.force = true
    elseif args[i] == "--local" then
      options.local_file = true
    else
      table.insert(pkg_args, args[i])
    end
  end

  -- 处理命令
  if command == "install" then
    if #pkg_args < 1 then
      print("Error: Missing package name.")
      show_help()
    else
      install_package(pkg_args[1], options)
    end
  elseif command == "update" then
    update_package(pkg_args[1], options)
  elseif command == "remove" or command == "uninstall" then
    if #pkg_args < 1 then
      print("Error: Missing package name.")
      show_help()
    else
      remove_package(pkg_args[1])
    end
  elseif command == "list" then
    list_packages()
  elseif command == "search" then
    if #pkg_args < 1 then
      print("Error: Missing search query.")
      show_help()
    else
      search_packages(pkg_args[1])
    end
  elseif command == "info" then
    if #pkg_args < 1 then
      print("Error: Missing package name.")
      show_help()
    else
      show_package_info(pkg_args[1])
    end
  elseif command == "init" then
    if #pkg_args < 1 then
      print("Error: Missing package name.")
      show_help()
    else
      create_package(pkg_args[1])
    end
  elseif command == "help" then
    show_help()
  else
    print("Error: Unknown command '" .. command .. "'")
    show_help()
  end
end

-- 运行主函数
local args = {...}
-- 过滤掉可能的空参数
local filtered_args = {}
for _, arg in ipairs(args) do
  if arg and arg ~= "" then
    table.insert(filtered_args, arg)
  end
end
main(filtered_args)