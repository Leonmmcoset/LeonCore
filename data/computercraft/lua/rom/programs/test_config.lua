-- test_config.lua: Test the config command

local term = require("term")
local colors = require("colors")
local shell = require("shell")

-- 保存当前颜色设置
local old_fg = term.getTextColor()
local old_bg = term.getBackgroundColor()

-- 设置名称栏颜色并显示
term.setTextColor(colors.white)
term.setBackgroundColor(colors.cyan)
term.at(1, 1).clearLine()
term.at(1, 1).write("=== Testing Config Command ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

-- 测试函数
local function run_test(test_name, command)
  term.setTextColor(colors.yellow)
  print("\n=== Test: " .. test_name .. " ===")
  term.setTextColor(colors.white)
  print("Command: " .. command)
  print("----------------------------------------")
  local ok, err = shell.run(command)
  if not ok and err then
    io.stderr:write("Test failed: " .. err .. "\n")
  else
    term.setTextColor(colors.green)
    print("Test completed successfully.")
    term.setTextColor(colors.white)
  end
  print("----------------------------------------")
  os.sleep(1)  -- 短暂暂停，让用户有时间查看结果
end

-- 主测试函数
local function main()
  -- 清除屏幕，但保留顶部标题
  local w, h = term.getSize()
  for y=2, h do
    term.at(1, y).clearLine()
  end
  term.at(1, 2)

  print("Starting config command tests...")
  os.sleep(1)

  -- 测试1: 显示帮助信息
  run_test("Show Help", "config help")

  -- 测试2: 列出所有设置
  run_test("List Settings", "config list")

  -- 测试3: 列出所有设置（带详细信息）
  run_test("List Settings with Details", "config list --details")

  -- 测试4: 获取特定设置的值
  run_test("Get Setting Value", "config get list.show_hidden")

  -- 测试5: 修改设置的值
  run_test("Set Setting Value", "config set list.show_hidden true")

  -- 测试6: 验证设置已更改
  run_test("Verify Setting Changed", "config get list.show_hidden")

  -- 测试7: 重置设置为默认值
  run_test("Reset to Default", "config default list.show_hidden")

  -- 测试8: 验证设置已重置
  run_test("Verify Reset", "config get list.show_hidden")

  -- 测试9: 保存设置（注意：这会实际修改设置文件）
  run_test("Save Settings", "config save")

  term.setTextColor(colors.green)
  print("\nAll tests completed!")
  term.setTextColor(colors.white)
  print("You can run 'config' command directly to manage system settings.")
end

main()