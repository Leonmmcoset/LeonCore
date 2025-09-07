-- test_help_format.lua: Test the formatted pkg_download_en help document
local help = require("rom/programs/help")
local term = require("term")

print("=== Testing pkg_download_en Help Document Formatting ===")
print("This test will display the pkg_download_en help document")
print("to verify that code blocks are properly formatted with colors.")
print("\n3...")
os.sleep(1)
print("2...")
os.sleep(1)
print("1...")
os.sleep(1)

-- Clear screen and display help document
term.clear()
term.setCursorPos(1, 1)

local success, content = pcall(function()
  return help.loadTopic("pkg_download_en")
end)

if success and content then
  -- Process the content to simulate how help system would display it
  print("=== pkg_download_en Help Document ===")
  for line in content:gmatch("[^
]+") do
    -- Handle color commands
    if line:match("^>>color yellow") then
      term.setTextColor(0xFFFF00)
    elseif line:match("^>>color white") then
      term.setTextColor(0xFFFFFF)
    else
      print(line)
    end
  end
  term.setTextColor(0xFFFFFF) -- Reset to white
  print("\n=== End of Help Document ===")
else
  print("Error: Could not load pkg_download_en help document.")
end

print("\nTest finished. Press any key to return.")
os.pullEvent("key")