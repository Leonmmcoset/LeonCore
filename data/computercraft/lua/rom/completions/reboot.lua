local shell = require("shell")
local completion = require("cc.shell.completion")

shell.setCompletionFunction("restart", completion.build(
  { completion.choice, { "now" } }
))
