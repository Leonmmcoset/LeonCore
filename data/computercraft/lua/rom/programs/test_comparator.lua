-- comparator_tester.lua
-- Tool to test comparator connections for Chest Sorter

local term = require("term")
local colors = require("colors")
local peripheral = require("peripheral")
local textutils = require("textutils")

-- 保存当前颜色设置
local old_fg = term.getTextColor()
local old_bg = term.getBackgroundColor()

-- 设置名称栏颜色并显示
term.setTextColor(colors.white)
term.setBackgroundColor(colors.blue)
term.at(1, 1).clearLine()
term.at(1, 1).write("=== Comparator Tester ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

print("This tool will help test your comparator connection.")
print("It uses the same detection logic as the Chest Sorter.")
print("")

-- 检测比较器
local comparator = nil
local comparator_name = nil
local peripherals = peripheral.getNames()

print(colors.blue .. "Searching for comparator..." .. colors.white)

-- 方法1: 尝试将每个外围设备都作为比较器检查
for _, name in ipairs(peripherals) do
  print("Checking peripheral: " .. name)
  local device = peripheral.wrap(name)
  
  -- 检查设备是否有getOutputSignal方法
  if device and type(device.getOutputSignal) == "function" then
    comparator = device
    comparator_name = name
    print(colors.green .. "Found potential comparator: " .. name .. " (Type: " .. peripheral.getType(name) .. ")" .. colors.white)
    break
  end
end

-- 方法2: 如果上述方法失败，尝试直接使用peripheral.find
if not comparator then
  print(colors.yellow .. "Method 1 failed. Trying peripheral.find..." .. colors.white)
  comparator = peripheral.find("comparator")
  if comparator then
    -- 尝试获取设备名称
    for _, name in ipairs(peripherals) do
      if peripheral.wrap(name) == comparator then
        comparator_name = name
        break
      end
    end
    print(colors.green .. "Comparator detected using peripheral.find!" .. colors.white)
  end
end

-- 方法3: 尝试使用redstone比较器的其他可能名称
if not comparator then
  print(colors.yellow .. "Method 2 failed. Trying alternative names..." .. colors.white)
  local alternative_names = {"redstone_comparator", "minecraft:comparator", "comparator_block", "comparator"}
  for _, alt_name in ipairs(alternative_names) do
    comparator = peripheral.find(alt_name)
    if comparator then
      -- 尝试获取设备名称
      for _, name in ipairs(peripherals) do
        if peripheral.wrap(name) == comparator then
          comparator_name = name
          break
        end
      end
      print(colors.green .. "Comparator detected using alternative name: " .. alt_name .. "!" .. colors.white)
      break
    end
  end
end

-- 方法4: 尝试检测redstone接口
if not comparator then
  print(colors.yellow .. "Method 3 failed. Trying redstone interface..." .. colors.white)
  local redstone = peripheral.find("redstone")
  if redstone then
    -- 检查redstone接口是否有比较器功能
    if type(redstone.getComparatorOutput) == "function" then
      comparator = redstone
      comparator_name = "redstone_interface"
      print(colors.green .. "Found redstone interface with comparator functionality!" .. colors.white)
    end
  end
end

-- 显示结果
if not comparator then
  print(colors.red .. "No comparator detected!" .. colors.white)
  if #peripherals > 0 then
    print(colors.yellow .. "Connected peripherals:" .. colors.white)
    for _, name in ipairs(peripherals) do
      local p_type = peripheral.getType(name)
      print("- " .. name .. " (Type: " .. p_type .. ")")
    end
  else
    print(colors.red .. "No peripherals detected at all." .. colors.white)
  end
  print("")
  print(colors.red .. "Troubleshooting steps:" .. colors.white)
  print("1. Ensure the comparator is directly connected to the computer")
  print("2. Check if the comparator is powered")
  print("3. Verify that the comparator is not broken")
  print("4. Try reconnecting the comparator")
  print("5. Make sure the comparator is placed next to a chest")
else
  print(colors.green .. "Comparator detected successfully!" .. colors.white)
  print("Comparator name: " .. (comparator_name or "unknown"))
  print("Comparator type: " .. peripheral.getType(comparator_name))
  
  -- 测试比较器信号
  print("")
  print(colors.blue .. "Testing comparator signal..." .. colors.white)
  local signal = comparator.getOutputSignal()
  print("Output signal level: " .. signal)
  
  if signal > 0 then
    print(colors.green .. "Comparator is detecting items in connected chests." .. colors.white)
  else
    print(colors.yellow .. "Comparator is not detecting any items." .. colors.white)
    print("Try adding items to a chest connected to the comparator.")
  end
  
  -- 持续监控信号
  print("")
  print(colors.blue .. "Monitoring signal changes (press any key to stop)..." .. colors.white)
  while true do
    os.sleep(0.5)
    local new_signal = comparator.getOutputSignal()
    if new_signal ~= signal then
      signal = new_signal
      print("Signal changed to: " .. signal)
      if signal > 0 then
        print(colors.green .. "Comparator is now detecting items!" .. colors.white)
      else
        print(colors.yellow .. "Comparator stopped detecting items." .. colors.white)
      end
    end
    if term.hasFocus() and term.getKey() ~= nil then
      break
    end
  end
end

-- 恢复终端设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
print("")
print("Test completed.")