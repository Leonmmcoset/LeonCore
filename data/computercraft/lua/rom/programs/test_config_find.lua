local shell = require("shell")
local term = require("term")
local colors = require("colors")

-- 保存当前颜色设置
local old_fg = term.getTextColor()
local old_bg = term.getBackgroundColor()

-- 测试函数
local function run_test(name, command)
  term.setTextColor(colors.cyan)
  print("\n=== Running test: " .. name .. " ===")
  term.setTextColor(colors.white)
  print("Command: " .. command)
  print("----------------------------------------")
  shell.run(command)
  print("----------------------------------------")
end

-- 主测试函数
local function main()
  -- 恢复颜色设置
  term.setTextColor(old_fg)
  term.setBackgroundColor(old_bg)
  term.at(1, 1).clearLine()
  
  -- 设置标题颜色
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.cyan)
  term.at(1, 1).write("=== Testing Config Find Command ===")
  term.setTextColor(old_fg)
  term.setBackgroundColor(old_bg)
  term.at(1, 2)
  
  -- 测试1: 基本find命令 - 搜索带"hidden"的设置
  run_test("Basic search for 'hidden'", "config find hidden")
  
  -- 测试2: 带--details选项的find命令
  run_test("Search with details", "config find hidden --details")
  
  -- 测试3: 大小写不敏感搜索
  run_test("Case-insensitive search", "config find HIDDEN -i")
  
  -- 测试4: 使用长选项--case-insensitive
  run_test("Case-insensitive search (long option)", "config find HIDDEN --case-insensitive")
  
  -- 测试5: 搜索描述中的关键词
  -- 注意：这取决于实际设置的描述内容，可能需要根据系统调整
  run_test("Search in descriptions", "config find directory")
  
  -- 测试6: 组合选项 - 带详细信息的大小写不敏感搜索
  run_test("Combined options", "config find HIDDEN -i --details")
  
  -- 测试7: 搜索不存在的模式
  run_test("Search for non-existent pattern", "config find nonexistentpattern123")
  
  -- 测试8: 查看帮助信息，确认find命令已正确添加
  run_test("Check help message", "config --help")
  
  -- 测试9: 测试find命令的错误用法
  run_test("Test invalid usage", "config find")
  
  -- 显示测试完成信息
  term.setTextColor(colors.green)
  print("\n=== All tests completed ===")
  term.setTextColor(old_fg)
end

-- 运行测试
main()