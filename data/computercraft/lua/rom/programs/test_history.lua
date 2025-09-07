-- test_history.lua: Test the history command
local shell = require("shell")
local term = require("term")

print("=== Testing history Command ===")
print("This test will run the history command with different options")
print("to verify it correctly manages command history.")
print("
First, let's execute some commands to populate history...")

-- Execute some commands to populate history
shell.run("echo Hello, World!")
shell.run("list")
shell.run("help")

print("
Test 1: Basic history command")
os.sleep(1)
term.clear()
local success = shell.run("history")
if not success then
  print("Error: history command failed to run.")
else
  print("
Test 1 completed. Press any key to continue.")
os.pullEvent("key")
end

print("
Test 2: Search history")
os.sleep(1)
term.clear()
success = shell.run("history", "-s", "he")
if not success then
  print("Error: history search command failed to run.")
else
  print("
Test 2 completed. Press any key to continue.")
os.pullEvent("key")
end

print("
Test 3: Execute command from history")
os.sleep(1)
term.clear()
print("Executing command #1 from history (should be 'echo Hello, World!')")
success = shell.run("history", "1")
if not success then
  print("Error: history execution command failed to run.")
else
  print("
Test 3 completed. Press any key to continue.")
os.pullEvent("key")
end

print("
Test 4: history help")
os.sleep(1)
term.clear()
success = shell.run("history", "--help")
if not success then
  print("Error: history help command failed to run.")
else
  print("
Test 4 completed. Press any key to finish.")
os.pullEvent("key")
end

term.clear()
print("=== history Command Tests Completed ===")
print("All tests have been executed.")
print("You can now use the 'history' command to manage your command history.")