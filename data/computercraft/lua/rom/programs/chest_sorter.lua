-- Chest Sorter Program
-- Part of LeonOS for CC Tweaked

local term = require("term")
local colors = require("colors")
local peripheral = require("peripheral")
local textutils = require("textutils")
local os = require("os")
local fs = require("fs")

-- 配置文件路径
local CONFIG_FILE = "/chest_sorter_config.json"

-- 保存当前颜色设置
local old_fg = term.getTextColor()
local old_bg = term.getBackgroundColor()

-- 设置名称栏颜色并显示
term.setTextColor(colors.white)
term.setBackgroundColor(colors.blue)
term.at(1, 1).clearLine()
term.at(1, 1).write("=== Chest Sorter ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

-- 检查是否有比较器(comparator)连接
local comparator = nil
local peripherals = peripheral.getNames()
local comparator_name = nil

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
    -- 查找比较器名称
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
      -- 查找比较器名称
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

if not comparator then
  -- 如果仍然没有找到比较器，列出所有连接的外围设备
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
  print(colors.red .. "Troubleshooting steps:" .. colors.white)
  print("1. Ensure the comparator is directly connected to the computer")
  print("2. Check if the comparator is powered")
  print("3. Verify that the comparator is not broken")
  print("4. Try reconnecting the comparator")
  error("Please connect a comparator to the computer.", 0)
else
  -- 测试比较器信号
  local signal = comparator.getOutputSignal()
  print(colors.green .. "Comparator test successful!" .. colors.white)
  print("Comparator name: " .. comparator_name)
  print("Output signal level: " .. signal)
  if signal > 0 then
    print(colors.blue .. "Comparator is detecting items in connected chests." .. colors.white)
  else
    print(colors.yellow .. "Comparator is not detecting any items. Try adding items to a chest." .. colors.white)
  end
end

-- 存储所有连接的外围设备名称
local connected_peripherals = peripherals

-- 定义配置变量
local config = {
  input_chest = nil,
  output_chests = {}
}

-- 加载配置
local function loadConfig()
  if fs.exists(CONFIG_FILE) then
    local file = fs.open(CONFIG_FILE, "r")
    local content = file.readAll()
    file.close()
    config = textutils.unserialiseJSON(content)
    return true
  end
  return false
end

-- 保存配置
local function saveConfig()
  local file = fs.open(CONFIG_FILE, "w")
  file.write(textutils.serialiseJSON(config))
  file.close()
end

-- 设置向导
local function setupWizard()
  print(colors.yellow .. "First time setup wizard..." .. colors.white)
  print("This will guide you through setting up your chest sorter.")
  print("")

  -- 列出所有连接的箱子类型外围设备
  local chests = {}
  for _, name in ipairs(connected_peripherals) do
    local peripheral_type = peripheral.getType(name)
    -- 检查是否为箱子类型的外围设备
    if peripheral_type == "chest" or peripheral_type == "trapped_chest" or peripheral_type == "barrel" then
      table.insert(chests, name)
    end
  end

  if #chests == 0 then
    error("No chests detected. Please connect at least one chest.", 0)
  end

  print("Available chests:")
  for i, chest in ipairs(chests) do
    print(i .. ". " .. chest)
  end
  print("")

  -- 选择输入箱
  print("Please select the input chest (where items will be placed for sorting):")
  local input_index = tonumber(io.read())
  while not input_index or input_index < 1 or input_index > #chests do
    print(colors.red .. "Invalid selection. Please enter a number between 1 and " .. #chests .. colors.white)
    input_index = tonumber(io.read())
  end
  config.input_chest = chests[input_index]
  print("Input chest set to: " .. config.input_chest)
  print("")

  -- 选择输出箱并分配类别
  print("Now, let's set up output chests for different item categories.")
  print("Enter 'done' when finished.")
  print("")

  config.output_chests = {}
  local remaining_chests = {}
  for i, chest in ipairs(chests) do
    if i ~= input_index then
      table.insert(remaining_chests, chest)
    end
  end

  while #remaining_chests > 0 do
    print("Available output chests:")
    for i, chest in ipairs(remaining_chests) do
      print(i .. ". " .. chest)
    end
    print("Enter 'done' to finish setup.")
    print("")
    print("Select a chest to assign a category (or 'done'):")
    local selection = io.read()

    if selection == "done" then
      break
    end

    local chest_index = tonumber(selection)
    if chest_index and chest_index >= 1 and chest_index <= #remaining_chests then
      local selected_chest = remaining_chests[chest_index]
      print("Enter a category name for this chest (e.g., 'coal', 'tools', 'food'):")
      local category = io.read()
      while category == "" do
        print(colors.red .. "Category name cannot be empty. Please enter a valid name." .. colors.white)
        category = io.read()
      end

      config.output_chests[category] = selected_chest
      print("Assigned chest '" .. selected_chest .. "' to category '" .. category .. "'")
      print("")

      -- 从剩余箱子中移除已分配的箱子
      table.remove(remaining_chests, chest_index)
    else
      print(colors.red .. "Invalid selection. Please try again." .. colors.white)
    end
  end

  -- 保存配置
  saveConfig()
  print(colors.green .. "Setup complete! Configuration saved." .. colors.white)
  print("")
end

-- 自动分类函数
local function autoSort()
  print(colors.green .. "Starting auto-sorting..." .. colors.white)
  print("Press Ctrl+T to stop.")

  -- 检查全局比较器对象是否有效
  if not comparator then
    print(colors.red .. "Comparator not available." .. colors.white)
    return
  end

  -- 捕获Ctrl+T中断
  local success, error = pcall(function()
    while true do
      -- 使用比较器检测输入箱是否有物品变化
      local input_chest = peripheral.wrap(config.input_chest)
      if not input_chest then
        print(colors.red .. "Failed to connect to input chest." .. colors.white)
        break
      end

      -- 检查比较器信号
      local comparator_level = comparator.getOutputSignal()
      if comparator_level > 0 then
        print(colors.blue .. "Comparator detected items in input chest." .. colors.white)

        -- 遍历输入箱的所有槽位
        local items_found = false
        for slot = 1, 16 do
          local item = input_chest.getItemDetail(slot)
          if item then
            items_found = true
            print("Found item: " .. item.name)

            -- 尝试找到匹配的类别
            local category_found = false
            for category, chest_name in pairs(config.output_chests) do
              if string.find(item.name, category) or string.find(item.displayName, category) then
                local output_inventory = peripheral.wrap(chest_name)
                if output_inventory then
                  print("Moving to '" .. category .. "' chest...")
                  input_chest.pushItems(chest_name, slot)
                  category_found = true
                  break
                else
                  print(colors.red .. "Failed to connect to '" .. category .. "' chest." .. colors.white)
                end
              end
            end

            if not category_found then
              print(colors.yellow .. "No matching category found for '" .. item.name .. "'." .. colors.white)
            end

            -- 短暂延迟避免过快处理
            os.sleep(0.1)
          end
        end
      else
        -- 如果比较器没有检测到物品，稍作等待
        os.sleep(0.5)
      end
    end
  end)

  if not success then
    print(colors.red .. "Program interrupted: " .. tostring(error) .. "" .. colors.white)
  end

  print(colors.yellow .. "Auto-sorting stopped." .. colors.white)
end

-- 显示教程
local function showTutorial()
  term.clear()
  term.setCursorPos(1, 1)
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.blue)
  term.clearLine()
  term.write("=== Chest Sorter Tutorial ===")
  term.setTextColor(old_fg)
  term.setBackgroundColor(old_bg)
  term.setCursorPos(1, 2)
  print("")
  print("How to use the Chest Sorter:")
  print("")
  print("1. Connect your computer to a comparator.")
  print("2. Connect the comparator to all chests you want to use.")
  print("3. Run the program: 'chest_sorter'")
  print("4. Follow the setup wizard to:")
  print("   a. Select an input chest (where you'll place items to sort)")
  print("   b. Assign output chests to categories (e.g., 'coal', 'tools')")
  print("5. After setup, the program will automatically sort items:")
  print("   - The comparator will detect when items are added to the input chest")
  print("   - Items will be moved to the appropriate output chest based on category names")
  print("")
  print("Troubleshooting:")
  print("- If you get a 'No comparator detected' error:")
  print("  1. Check that the comparator is properly connected to the computer")
  print("  2. Make sure the comparator is receiving a redstone signal from the chests")
  print("  3. Verify that the comparator is not broken")
  print("")
  print("Tips:")
  print("- Use specific category names for better sorting (e.g., 'iron_ore' instead of 'ore')")
  print("- You can edit the configuration later by deleting '" .. CONFIG_FILE .. "'")
  print("  and running the program again to restart the setup wizard.")
  print("- Press Ctrl+T to stop the program.")
  print("")
  print("Press any key to continue...")
  io.read()
end

-- 主程序
local function main(...)  -- 改为可变参数函数
  -- 检查是否需要显示教程
  local args = {...}
  if #args > 0 and args[1] == "tutorial" then
    showTutorial()
    return
  end

  -- 加载配置或运行设置向导
  if not loadConfig() then
    setupWizard()
  end

  -- 显示当前配置
  print(colors.cyan .. "Current Configuration:" .. colors.white)
  print("Input chest: " .. config.input_chest)
  print("Output chests:")
  for category, chest in pairs(config.output_chests) do
    print("  - '" .. category .. "': " .. chest)
  end
  print("")

  -- 开始自动分类
  autoSort()
end

-- 运行主程序
main()