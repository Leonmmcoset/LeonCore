local shell = require("shell")
local completion = require("cc.shell.completion")

shell.setCompletionFunction("pkg", completion.build(

))
