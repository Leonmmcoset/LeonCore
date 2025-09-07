-- tree command completion
local shell = require("shell")
local completion = require("cc.shell.completion")

shell.setCompletionFunction("tree", completion.build(
  {completion.dir, many = true}
))