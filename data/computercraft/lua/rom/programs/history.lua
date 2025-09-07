-- history.lua: Command history viewer
local term = require("term")
local colors = require("colors")
local textutils = require("textutils")
local shell = require("shell")

-- Get the global history table from shell
local function getHistory()
  -- Search for the shell thread to access its history
  local thread = require("rc.thread")
  local shellThread = thread.vars().parentShell
  if shellThread and shellThread.env and shellThread.env.history then
    return shellThread.env.history
  end
  -- Fallback to empty history if not found
  return {}
end

-- Display help information
local function printHelp()
  print("Usage: history [options]")
  print("Options:")
  print("  --help, -h    Show this help message")
  print("  --clear, -c   Clear command history")
  print("  --search, -s <pattern>  Search history for pattern")
  print("  <number>      Execute command by history number")
  print([[
Displays command history in LeonOS.]])
end

-- Clear command history
local function clearHistory()
  local history = getHistory()
  for i = #history, 1, -1 do
    history[i] = nil
  end
  print("Command history cleared.")
end

-- Search history for pattern
local function searchHistory(pattern)
  local history = getHistory()
  local results = {}
  for i, cmd in ipairs(history) do
    if cmd:find(pattern) then
      table.insert(results, {i, cmd})
    end
  end
  return results
end

-- Main function
local function main(args)
  -- Process command line arguments
  if #args == 0 then
    -- Display all history
    local history = getHistory()
    if #history == 0 then
      print("No command history available.")
      return
    end
    print("Command history:")
    for i, cmd in ipairs(history) do
      term.setTextColor(colors.cyan)
      io.write(string.format("  %3d  ", i))
      term.setTextColor(colors.white)
      print(cmd)
    end
  elseif args[1] == "--help" or args[1] == "-h" then
    printHelp()
  elseif args[1] == "--clear" or args[1] == "-c" then
    clearHistory()
  elseif args[1] == "--search" or args[1] == "-s" then
    if #args < 2 then
      print("Error: Missing search pattern.")
      printHelp()
    else
      local results = searchHistory(args[2])
      if #results == 0 then
        print("No matching commands found.")
      else
        print("Search results:")
        for _, item in ipairs(results) do
          term.setTextColor(colors.cyan)
          io.write(string.format("  %3d  ", item[1]))
          term.setTextColor(colors.white)
          print(item[2])
        end
      end
    end
  else
    -- Try to execute command by number
    local num = tonumber(args[1])
    if num then
      local history = getHistory()
      if num >= 1 and num <= #history then
        print("Executing: " .. history[num])
        shell.run(history[num])
      else
        print("Error: Invalid history number.")
      end
    else
      print("Error: Unknown option or command number.")
      printHelp()
    end
  end
end

-- Run the main function
local args = {...}
main(args)