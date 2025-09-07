-- calc command completion
local shell = require("shell")
local completion = require("cc.shell.completion")

shell.setCompletionFunction("calc", function(shell, args)
  -- Calculator doesn't need parameters, return empty list
  return {}
end)