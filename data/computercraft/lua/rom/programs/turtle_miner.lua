-- Turtle Auto Miner Program
-- Part of LeonOS for CC Tweaked

local term = require("term")
local colors = require("colors")
local textutils = require("textutils")
local os = require("os")

-- 保存当前颜色设置
local old_fg = term.getTextColor()
local old_bg = term.getBackgroundColor()

-- 设置名称栏颜色并显示
term.setTextColor(colors.white)
term.setBackgroundColor(colors.cyan)
term.at(1, 1).clearLine()
term.at(1, 1).write("=== Turtle Auto Miner ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

-- 检查是否有turtle
local turtle = require("turtle")
if not turtle then
  error("No turtle detected. Please run this program on a turtle.", 0)
end

-- 配置常量
local FUEL_THRESHOLD = 500 -- 燃料不足阈值
local INVENTORY_FULL_THRESHOLD = 0 -- 背包满时剩余空格数 (0表示16个格子全满)
local COAL_NAMES = {"minecraft:coal", "minecraft:charcoal"} -- 煤炭物品名称
local CHEST_NAMES = {"chest", "shulker_box"} -- 箱子类型名称

-- 坐标跟踪变量
local initialX, initialY, initialZ = 0, 0, 0
local currentX, currentY, currentZ = 0, 0, 0
local direction = 0 -- 0: 北, 1: 东, 2: 南, 3: 西

-- 检查是否是箱子
local function isChest(block_data)
  if not block_data or not block_data.name then
    return false
  end
  for _, chest_name in ipairs(CHEST_NAMES) do
    if string.find(block_data.name, chest_name) then
      return true
    end
  end
  return false
end


-- 检查燃料是否充足
local function checkFuel()
  local currentFuel = turtle.getFuelLevel()
  local fuelLimit = turtle.getFuelLimit()
  
  -- 无限燃料模式或燃料充足
  if fuelLimit == "unlimited" or currentFuel >= FUEL_THRESHOLD then
    return true
  end
  
  return false
end

-- 寻找并使用燃料
local function refuel()
  print(colors.yellow .. "Fuel low! Searching for fuel..." .. colors.white)
  local initial_slot = turtle.getSelectedSlot()
  local found_fuel = false
  
  -- 检查背包中是否有燃料
  for slot = 1, 16 do
    if turtle.getItemCount(slot) > 0 then
      turtle.select(slot)
      local itemDetail = turtle.getItemDetail()
      if itemDetail and itemDetail.fuel then
        found_fuel = true
        print("Found fuel in slot " .. slot .. ": " .. itemDetail.name)
        print("Refueling...")
        turtle.refuel(turtle.getItemCount(slot))
        print(colors.green .. "Fuel level: " .. turtle.getFuelLevel() .. colors.white)
        break
      end
    end
  end
  
  -- 恢复原来选中的槽位
  turtle.select(initial_slot)
  
  -- 如果没有找到燃料，尝试向下挖寻找煤矿
  if not found_fuel then
    print(colors.red .. "No fuel in inventory. Searching for coal ore..." .. colors.white)
    local old_slot = turtle.getSelectedSlot()
    
    -- 先检查脚下是否有方块
    if not turtle.detectDown() then
      print("Nothing below. Moving down...")
      if not turtle.down() then
        print(colors.red .. "Cannot move down." .. colors.white)
        turtle.select(old_slot)
        return false
      end
    end
    
    -- 挖掘脚下可能的煤矿
      for i = 1, 3 do -- 尝试挖3格
        turtle.select(old_slot) -- 确保使用正确的工具
        if turtle.detectDown() then
          -- 检查是否是箱子
          local success, data = turtle.inspectDown()
          if success and isChest(data) then
            print(colors.red .. "Found chest below! Mining is prohibited." .. colors.white)
          else
            turtle.digDown()
          end
        -- 检查是否挖到了煤炭
        for slot = 1, 16 do
          if turtle.getItemCount(slot) > 0 then
            turtle.select(slot)
            local itemDetail = turtle.getItemDetail()
            if itemDetail then
              for _, coal_name in ipairs(COAL_NAMES) do
                if string.find(itemDetail.name, coal_name) then
                  print(colors.green .. "Found coal!" .. colors.white)
                  turtle.refuel(turtle.getItemCount(slot))
                  turtle.select(old_slot)
                  return true
                end
              end
            end
          end
        end
      end
      
      if turtle.down() then
        currentY = currentY - 1
      else
        break
      end
    end
    
    -- 回到原来的位置
    for i = 1, 3 do
      if turtle.up() then
        currentY = currentY + 1
      else
        break
      end
    end
    
    turtle.select(old_slot)
  end
  
  return found_fuel or checkFuel()
end

-- 检查背包是否已满
local function isInventoryFull()
  local empty_slots = 0
  for i = 1, 16 do
    if turtle.getItemCount(i) == 0 then
      empty_slots = empty_slots + 1
    end
  end
  return empty_slots <= INVENTORY_FULL_THRESHOLD
end

-- 返回初始位置
local function returnToStart()
  print(colors.yellow .. "Returning to starting position..." .. colors.white)
  
  -- 先调整方向朝北
  while direction ~= 0 do
    turtle.turnRight()
    direction = (direction + 1) % 4
  end
  
  -- 移动回初始X坐标
  if currentX > 0 then
    for _ = 1, currentX do
      turtle.back()
    end
  elseif currentX < 0 then
    for _ = 1, -currentX do
      turtle.forward()
    end
  end
  
  -- 调整方向朝西
  while direction ~= 3 do
    turtle.turnRight()
    direction = (direction + 1) % 4
  end
  
  -- 移动回初始Z坐标
  if currentZ > 0 then
    for _ = 1, currentZ do
      turtle.back()
    end
  elseif currentZ < 0 then
    for _ = 1, -currentZ do
      turtle.forward()
    end
  end
  
  -- 恢复朝北方向
  while direction ~= 0 do
    turtle.turnRight()
    direction = (direction + 1) % 4
  end
  
  -- 移动回初始Y坐标
  if currentY > 0 then
    for _ = 1, currentY do
      turtle.down()
    end
  elseif currentY < 0 then
    for _ = 1, -currentY do
      turtle.up()
    end
  end
  
  -- 重置当前坐标
  currentX, currentY, currentZ = 0, 0, 0
  print(colors.green .. "Returned to starting position." .. colors.white)
end

-- 寻找附近的箱子并存放物品
local function findChestAndDeposit()
  print(colors.yellow .. "Inventory is full. Returning to start position first..." .. colors.white)
  
  -- 先返回初始位置
  returnToStart()
  
  print(colors.yellow .. "Looking for chest near starting position..." .. colors.white)
  
  -- 尝试在周围寻找箱子
  for direction = 1, 4 do -- 四个方向
    local found_chest = false
    
    -- 检查前方是否有箱子
    local success, data = turtle.inspect()
    if success then
      if data.name and (string.find(data.name, "chest") or string.find(data.name, "shulker_box")) then
        found_chest = true
      end
    end
    
    if found_chest then
      print(colors.green .. "Found chest! Depositing items..." .. colors.white)
      
      -- 存放所有物品（除了工具和燃料）
      local initial_slot = turtle.getSelectedSlot()
      for slot = 1, 16 do
        if turtle.getItemCount(slot) > 0 then
          turtle.select(slot)
          local itemDetail = turtle.getItemDetail()
          
          -- 跳过工具和燃料
          if itemDetail then
            local is_tool = itemDetail.damage ~= nil
            local is_fuel = itemDetail.fuel or false
            
            if not is_tool and not is_fuel then
              turtle.drop()
            end
          end
        end
      end
      
      turtle.select(initial_slot)
      print(colors.green .. "Deposit complete!" .. colors.white)
      return true
    end
    
    -- 转向下一个方向
    turtle.turnRight()
  end
  
  -- 如果没找到箱子，尝试向上和向下
  print("Checking up and down...")
  
  -- 检查上方
  local success, data = turtle.inspectUp()
  if success and data.name and (string.find(data.name, "chest") or string.find(data.name, "shulker_box")) then
    print(colors.green .. "Found chest above! Depositing items..." .. colors.white)
    local initial_slot = turtle.getSelectedSlot()
    for slot = 1, 16 do
      if turtle.getItemCount(slot) > 0 then
        turtle.select(slot)
        local itemDetail = turtle.getItemDetail()
        if itemDetail and not itemDetail.damage and not itemDetail.fuel then
          turtle.dropUp()
        end
      end
    end
    turtle.select(initial_slot)
    print(colors.green .. "Deposit complete!" .. colors.white)
    return true
  end
  
  -- 检查下方
  success, data = turtle.inspectDown()
  if success and data.name and (string.find(data.name, "chest") or string.find(data.name, "shulker_box")) then
    print(colors.green .. "Found chest below! Depositing items..." .. colors.white)
    local initial_slot = turtle.getSelectedSlot()
    for slot = 1, 16 do
      if turtle.getItemCount(slot) > 0 then
        turtle.select(slot)
        local itemDetail = turtle.getItemDetail()
        if itemDetail and not itemDetail.damage and not itemDetail.fuel then
          turtle.dropDown()
        end
      end
    end
    turtle.select(initial_slot)
    print(colors.green .. "Deposit complete!" .. colors.white)
    return true
  end
  
  print(colors.red .. "No chest found nearby. Already at starting position." .. colors.white)
  return false
end

-- 自动挖矿主循环
local function startMining()
  print(colors.green .. "Starting auto mining..." .. colors.white)
  print("Press Ctrl+T to stop.")
  
  -- 重置坐标
  currentX, currentY, currentZ = 0, 0, 0
  direction = 0 -- 初始方向朝北
  
  -- 捕获Ctrl+T中断，确保在停止时返回初始位置
  local success, error = pcall(function()
  while true do
    -- 检查燃料
    if not checkFuel() then
      if not refuel() then
        print(colors.red .. "Critical fuel shortage! Stopping mining." .. colors.white)
        break
      end
    end
    
    -- 检查背包是否已满
    if isInventoryFull() then
      if not findChestAndDeposit() then
        print(colors.red .. "Cannot deposit items. Stopping mining." .. colors.white)
        break
      end
    end
    
    -- 尝试挖掘前方
      if not turtle.detect() then
      print("Moving forward...")
        if turtle.forward() then
          -- 更新坐标 based on direction
          if direction == 0 then -- 北
            currentZ = currentZ - 1
          elseif direction == 1 then -- 东
            currentX = currentX + 1
          elseif direction == 2 then -- 南
            currentZ = currentZ + 1
          elseif direction == 3 then -- 西
            currentX = currentX - 1
          end
        else
          print(colors.red .. "Cannot move forward. Changing direction." .. colors.white)
          turtle.turnRight()
          direction = (direction + 1) % 4
        if not turtle.forward() then
          turtle.turnLeft()
          turtle.turnLeft()
          direction = (direction + 2) % 4
          if turtle.forward() then
            -- 更新坐标 based on direction
            if direction == 0 then -- 北
              currentZ = currentZ - 1
            elseif direction == 1 then -- 东
              currentX = currentX + 1
            elseif direction == 2 then -- 南
              currentZ = currentZ + 1
            elseif direction == 3 then -- 西
              currentX = currentX - 1
            end
          else
            turtle.turnRight()
            direction = (direction + 1) % 4
            if turtle.up() then
              currentY = currentY + 1
            end
          end
        end
      end
    else
        -- 检查是否是箱子
        local success, data = turtle.inspect()
        if success and isChest(data) then
          print(colors.red .. "Found chest! Mining is prohibited. Changing direction." .. colors.white)
          turtle.turnRight()
          direction = (direction + 1) % 4
        else
          print("Mining...")
          turtle.dig()
        end
      -- 检查是否有掉落物需要捡起
      -- os.sleep(0.5)
    end
    
    -- 检查上方是否有方块可以挖掘
      if turtle.detectUp() then
        -- 检查是否是箱子
        local success, data = turtle.inspectUp()
        if success and isChest(data) then
          print(colors.red .. "Found chest above! Mining is prohibited." .. colors.white)
        else
          print("Mining above...")
          turtle.digUp()
        end
      -- os.sleep(0.5)
    end
    
    -- 短暂延迟避免CPU占用过高
    -- os.sleep(0.1)
  end
  
  end
  )
  
  -- 确保在停止时返回初始位置
  if not success then
    print(colors.red .. "Program interrupted: " .. tostring(error) .. "" .. colors.white)
  end
  
  print(colors.yellow .. "Returning to starting position before stopping..." .. colors.white)
  returnToStart()
  print(colors.yellow .. "Auto mining stopped." .. colors.white)
end

-- 显示帮助信息
local function showHelp()
  print("Turtle Auto Miner")
  print("Usage: turtle_miner")
  print("")
  print("Features:")
  print("  - Automatically mines blocks in front of the turtle")
  print("  - Refuels automatically when fuel is low")
  print("  - Searches for coal ore if no fuel is available in inventory")
  print("  - Finds nearby chests and deposits items when inventory is full")
  print("  - Press Ctrl+T to stop the program")
end

-- 主程序
local args = {...}
if #args > 0 and (args[1] == "help" or args[1] == "-h" or args[1] == "--help") then
  showHelp()
else
  startMining()
end