-- commands.lua: List all available commands
local shell = require("shell")
local fs = require("fs")

-- 帮助信息函数
local function printHelp()
  print("Usage: commands [options]")
  print("Options:")
  print("  --help, -h    Show this help message")
  print("  --verbose, -v Show command file paths")
  print([[
Lists all available commands in LeonOS.]])
end

-- 主函数
local function main(args)
  -- 处理命令行参数
  local showHelp = false
  local verbose = false

  for _, arg in ipairs(args) do
    if arg == "--help" or arg == "-h" then
      showHelp = true
    elseif arg == "--verbose" or arg == "-v" then
      verbose = true
    end
  end

  if showHelp then
    printHelp()
    return
  end

  -- 获取命令列表
  local programDir = "/rom/programs"
  local files = fs.list(programDir)
  local commands = {}

  for _, file in ipairs(files) do
    if file:sub(-4) == ".lua" then
      local cmdName = file:sub(1, -5)
      table.insert(commands, {name = cmdName, path = programDir .. "/" .. file})
    end
  end

  -- 排序命令列表
  table.sort(commands, function(a, b)
    return a.name < b.name
  end)

  -- 显示命令列表
  print("Available commands (" .. #commands .. "):")
  for _, cmd in ipairs(commands) do
    if verbose then
      print(string.format("  %-15s - %s", cmd.name, cmd.path))
    else
      print(string.format("  %-15s", cmd.name))
    end
  end
end

-- 运行主函数
local args = {...}
main(args)