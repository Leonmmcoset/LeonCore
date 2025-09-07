local shell = require("shell")
local completion = require("cc.shell.completion")

shell.setCompletionFunction("enter", completion.build(completion.dir))
