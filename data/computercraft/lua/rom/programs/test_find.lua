-- test_find.lua: Test the find command

local term = require("term")
local colors = require("colors")
local shell = require("shell")
local fs = require("fs")

-- 保存当前颜色设置
local old_fg = term.getTextColor()
local old_bg = term.getBackgroundColor()

-- 设置名称栏颜色并显示
term.setTextColor(colors.white)
term.setBackgroundColor(colors.cyan)
term.at(1, 1).clearLine()
term.at(1, 1).write("=== Testing Find Command ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

-- 创建测试目录结构
local function create_test_files()
  print("Creating test files and directories...")

  -- 创建测试根目录
  local test_root = "/test_find"
  if fs.exists(test_root) then
    fs.delete(test_root)
  end
  fs.makeDir(test_root)

  -- 创建测试文件和目录
  fs.makeDir(fs.combine(test_root, "dir1"))
  fs.makeDir(fs.combine(test_root, "dir2"))
  fs.makeDir(fs.combine(test_root, ".hidden_dir"))

  -- 创建文件
  local function create_file(path, content)
    local file = io.open(path, "w")
    if file then
      file:write(content)
      file:close()
      return true
    end
    return false
  end

  create_file(fs.combine(test_root, "file1.txt"), "Test file 1")
  create_file(fs.combine(test_root, "file2.lua"), "-- Test Lua file")
  create_file(fs.combine(test_root, ".hidden_file"), "Hidden file content")
  create_file(fs.combine(test_root, "dir1", "subfile1.txt"), "Subdirectory file 1")
  create_file(fs.combine(test_root, "dir1", "subfile2.lua"), "-- Subdirectory Lua file")
  create_file(fs.combine(test_root, "dir2", "subfile3.txt"), "Subdirectory file 3")
  create_file(fs.combine(test_root, ".hidden_dir", "hidden_content.txt"), "Content in hidden directory")

  print("Test files created successfully.")
  return test_root
end

-- 测试函数
local function run_test(test_name, command, expected_count)
  term.setTextColor(colors.yellow)
  print("\n=== Test: " .. test_name .. " ===")
  term.setTextColor(colors.white)
  print("Command: " .. command)
  print("----------------------------------------")

  -- 捕获命令输出
  local old_output = io.output()
  local output = {}
  io.output{write = function(s) output[#output+1] = s end}

  local ok, err = shell.run(command)

  -- 恢复输出
  io.output(old_output)

  -- 计算匹配的结果数量
  local result_count = 0
  for line in table.concat(output, ""):gmatch("[^
]+") do
    if line:match("^  /test_find/") then
      result_count = result_count + 1
    end
  end

  -- 检查结果
  if not ok and err then
    io.stderr:write("Test failed: " .. err .. "\n")
  else
    if expected_count and result_count ~= expected_count then
      io.stderr:write("Test failed: Expected " .. expected_count .. " results, got " .. result_count .. "\n")
    else
      term.setTextColor(colors.green)
      print("Test completed successfully. Found " .. result_count .. " results.")
      term.setTextColor(colors.white)
    end
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

  -- 创建测试文件
  local test_root = create_test_files()
  os.sleep(1)

  print("Starting find command tests...")
  os.sleep(1)

  -- 测试1: 显示帮助信息
  run_test("Show Help", "find --help")

  -- 测试2: 搜索所有文件和目录
  run_test("Search All Items", "find " .. test_root, 8)

  -- 测试3: 搜索Lua文件
  run_test("Search Lua Files", "find " .. test_root .. " *.lua", 2)

  -- 测试4: 搜索目录
  run_test("Search Directories", "find " .. test_root .. " --type d", 3)

  -- 测试5: 搜索特定名称的文件
  run_test("Search by Exact Name", "find " .. test_root .. " --name file1.txt", 1)

  -- 测试6: 搜索隐藏文件和目录
  run_test("Search Hidden Items", "find " .. test_root .. " --hidden", 10)

  -- 测试7: 不区分大小写搜索
  run_test("Case Insensitive Search", "find " .. test_root .. " FILE*.TXT -i", 1)

  -- 测试8: 组合条件搜索 (Lua文件且不区分大小写)
  run_test("Combined Conditions", "find " .. test_root .. " *.LUA -i", 2)

  -- 测试9: 搜索不存在的路径
  run_test("Search Non-existent Path", "find /non_existent_path", 0)

  -- 清理测试文件
  print("\nCleaning up test files...")
  fs.delete(test_root)

  term.setTextColor(colors.green)
  print("\nAll tests completed!")
  term.setTextColor(colors.white)
  print("You can run 'find' command directly to search files and directories.")
end

main()