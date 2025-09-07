-- test_helplist.lua: Test the helplist command
local shell = require("shell")
local term = require("term")

print("=== Testing helplist Command ===")
print("This test will run the helplist command with different options")
print("to verify it correctly lists all available help topics.")
print("
Test 1: Basic helplist command")
os.sleep(1)
term.clear()
local success = shell.run("helplist")
if not success then
  print("Error: helplist command failed to run.")
else
  print("
Test 1 completed. Press any key to continue.")
os.pullEvent("key")
end

print("
Test 2: helplist with sorting")
os.sleep(1)
term.clear()
success = shell.run("helplist", "--sort")
if not success then
  print("Error: helplist --sort command failed to run.")
else
  print("
Test 2 completed. Press any key to continue.")
os.pullEvent("key")
end

print("
Test 3: helplist with color")
os.sleep(1)
term.clear()
success = shell.run("helplist", "--color")
if not success then
  print("Error: helplist --color command failed to run.")
else
  print("
Test 3 completed. Press any key to continue.")
os.pullEvent("key")
end

print("
Test 4: helplist help")
os.sleep(1)
term.clear()
success = shell.run("helplist", "--help")
if not success then
  print("Error: helplist --help command failed to run.")
else
  print("
Test 4 completed. Press any key to finish.")
os.pullEvent("key")
end

term.clear()
print("=== helplist Command Tests Completed ===")
print("All tests have been executed.")
print("You can now use the 'helplist' command to list all available help topics.")