-- helplist.lua: List all available help documents
local help = require("help")
local textutils = require("textutils")
local term = require("term")
local colors = require("colors")

-- Help information function
local function printHelp()
  print("Usage: helplist [options]")
  print("Options:")
  print("  --help, -h    Show this help message")
  print("  --sort, -s    Sort topics alphabetically")
  print("  --color, -c   Show colored output")
  print([[
Lists all available help topics in LeonOS.]])
end

-- Main function
local function main(args)
  -- Process command line arguments
  local showHelp = false
  local sortTopics = false
  local useColor = false

  for _, arg in ipairs(args) do
    if arg == "--help" or arg == "-h" then
      showHelp = true
    elseif arg == "--sort" or arg == "-s" then
      sortTopics = true
    elseif arg == "--color" or arg == "-c" then
      useColor = true
    end
  end

  if showHelp then
    printHelp()
    return
  end

  -- Get all help topics
  local topics = help.topics()

  -- Sort topics if requested
  if sortTopics then
    table.sort(topics)
  end

  -- Display the help topics
  print("Available help topics (" .. #topics .. "):")
  for _, topic in ipairs(topics) do
    if useColor then
      term.setTextColor(colors.cyan)
      print("  " .. topic)
      term.setTextColor(colors.white)
    else
      print("  " .. topic)
    end
  end
end

-- Run the main function
local args = {...}
main(args)