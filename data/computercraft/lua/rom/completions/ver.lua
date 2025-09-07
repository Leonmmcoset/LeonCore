local shell = require("shell")
local completion = require("cc.shell.completion")

shell.setCompletionFunction("ver", completion.build(
  -- ver命令不接受参数，所以这里没有额外的补全选项
))