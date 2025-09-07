-- Turtle Auto Farmer Program
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
term.setBackgroundColor(colors.green)
term.at(1, 1).clearLine()
term.at(1, 1).write("=== Turtle Auto Farmer ===")

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
local WHEAT_THRESHOLD = 64 -- 小麦存储阈值
local SEED_SLOT = 1 -- 种子存放槽位
local WHEAT_SLOT = 2 -- 小麦存放槽位
local FUEL_THRESHOLD = 200 -- 燃料不足阈值
local INVENTORY_FULL_THRESHOLD = 0 -- 背包满时剩余空格数 (0表示16个格子全满)
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


-- 从背包中寻找燃料并填充
local function refuelFromInventory()
  print(colors.yellow .. "Fuel low! Searching for fuel in inventory..." .. colors.white)
  local initial_slot = turtle.getSelectedSlot()
  local fuel_found = false
  
  -- 遍历所有16个背包槽位
  for slot = 1, 16 do
    if turtle.getItemCount(slot) > 0 then
      turtle.select(slot)
      local itemDetail = turtle.getItemDetail()
      
      -- 检查物品是否可以作为燃料
      if itemDetail and itemDetail.fuel ~= nil and itemDetail.fuel > 0 then
        print(colors.green .. "Found fuel in slot " .. slot .. ": " .. itemDetail.name .. " (" .. itemDetail.fuel .. " fuel)" .. colors.white)
        
        -- 填充燃料
        local success = turtle.refuel(1)
        if success then
          print(colors.green .. "Refueled successfully! Current fuel: " .. turtle.getFuelLevel() .. colors.white)
          fuel_found = true
          break -- 找到燃料后退出循环
        else
          print(colors.red .. "Failed to refuel with slot " .. slot .. colors.white)
        end
      end
    end
  end
  
  -- 恢复原来选择的槽位
  turtle.select(initial_slot)
  
  return fuel_found
end

-- 检查燃料是否充足
local function checkFuel()
  local currentFuel = turtle.getFuelLevel()
  local fuelLimit = turtle.getFuelLimit()
  
  -- 无限燃料模式或燃料充足
  if fuelLimit == "unlimited" or currentFuel >= FUEL_THRESHOLD then
    return true
  end
  
  -- 尝试从背包中寻找燃料
  return refuelFromInventory()
end

-- 检测前方是否有成熟的麦子
local function detectWheat()
  local success, data = turtle.inspect()
  if success then
    -- 先检查是否是箱子
    if isChest(data) then
      print(colors.red .. "Found chest! Mining is prohibited." .. colors.white)
      return false
    elseif data.name and data.name == "minecraft:wheat" then
      -- 检查是否成熟 (age为7时成熟)
      if data.metadata and data.metadata.age == 7 then
        return true
      end
    end
  end
  return false
end

-- 收割麦子
local function harvestWheat()
  print("Harvesting wheat...")
  -- 再次检查是否是箱子，防止误挖
  local success, data = turtle.inspect()
  if success and not isChest(data) then
    turtle.dig()
  else
    print(colors.red .. "Cannot harvest: Detected chest or invalid block." .. colors.white)
  end
  -- 等待掉落物
  os.sleep(0.5)
  
  -- 收集掉落的小麦和种子
  local initial_slot = turtle.getSelectedSlot()
  
  -- 检查是否获得了小麦
  for slot = 1, 16 do
    if turtle.getItemCount(slot) > 0 then
      turtle.select(slot)
      local itemDetail = turtle.getItemDetail()
      if itemDetail and itemDetail.name == "minecraft:wheat" then
        -- 移动小麦到指定槽位
        if slot ~= WHEAT_SLOT and turtle.getItemCount(WHEAT_SLOT) == 0 then
          turtle.select(slot)
          turtle.transferTo(WHEAT_SLOT, turtle.getItemCount(slot))
        end
      elseif itemDetail and itemDetail.name == "minecraft:wheat_seeds" then
        -- 移动种子到指定槽位
        if slot ~= SEED_SLOT then
          turtle.select(slot)
          turtle.transferTo(SEED_SLOT, turtle.getItemCount(slot))
        end
      end
    end
  end
  
  turtle.select(initial_slot)
end

-- 种植种子
local function plantSeed()
  -- 检查是否有种子
  if turtle.getItemCount(SEED_SLOT) == 0 then
    print(colors.red .. "No seeds available!" .. colors.white)
    return false
  end
  
  -- 选择种子槽位
  turtle.select(SEED_SLOT)
  
  -- 检查脚下是否有泥土或耕地
  local success, data = turtle.inspectDown()
  if success and (data.name == "minecraft:dirt" or data.name == "minecraft:grass_block" or data.name == "minecraft:farmland") then
    print("Planting seed...")
    turtle.placeDown()
    return true
  end
  
  return false
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

-- 寻找附近的箱子并存放小麦和处理背包满的情况
local function findChestAndDeposit()
  -- 检查是否需要存放小麦或背包已满
  local need_deposit = false
  
  -- 检查小麦数量
  turtle.select(WHEAT_SLOT)
  if turtle.getItemCount(WHEAT_SLOT) >= WHEAT_THRESHOLD then
    need_deposit = true
  end
  
  -- 检查背包是否已满
  if isInventoryFull() then
    print(colors.yellow .. "Inventory is full. Returning to start position first..." .. colors.white)
    need_deposit = true
  end
  
  -- 如果不需要存放，直接返回
  if not need_deposit then
    return true
  end
  
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
      print(colors.green .. "Found chest! Depositing wheat..." .. colors.white)
      
      -- 存放小麦
      turtle.select(WHEAT_SLOT)
      turtle.drop()
      
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
    print(colors.green .. "Found chest above! Depositing wheat..." .. colors.white)
    turtle.select(WHEAT_SLOT)
    turtle.dropUp()
    print(colors.green .. "Deposit complete!" .. colors.white)
    return true
  end
  
  -- 检查下方
  success, data = turtle.inspectDown()
  if success and data.name and (string.find(data.name, "chest") or string.find(data.name, "shulker_box")) then
    print(colors.green .. "Found chest below! Depositing wheat..." .. colors.white)
    turtle.select(WHEAT_SLOT)
    turtle.dropDown()
    print(colors.green .. "Deposit complete!" .. colors.white)
    return true
  end
  
  print(colors.red .. "No chest found nearby. Already at starting position." .. colors.white)
  return false
end

-- 自动种植和收割主循环
local function startFarming()
  print(colors.green .. "Starting auto farming..." .. colors.white)
  print("Press Ctrl+T to stop.")
  
  -- 重置坐标
  currentX, currentY, currentZ = 0, 0, 0
  direction = 0 -- 初始方向朝北
  
  -- 捕获Ctrl+T中断，确保在停止时返回初始位置
  local success, error = pcall(function()
  while true do
    -- 检查燃料
    if not checkFuel() then
      print(colors.red .. "Fuel low! Stopping farming." .. colors.white)
      break
    end
    
    -- 检查是否需要存放小麦或背包已满
    if not findChestAndDeposit() then
      print(colors.red .. "Cannot deposit items. Stopping farming." .. colors.white)
      break
    end
    
    -- 检测并收割成熟的麦子
    if detectWheat() then
      harvestWheat()
    else
      -- 没有成熟的麦子，向前移动
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
      end
    end
    
    -- 种植种子
    plantSeed()
    
    -- 短暂延迟避免CPU占用过高
    os.sleep(0.1)
  end
  
  end
  )
  
  -- 确保在停止时返回初始位置
  if not success then
    print(colors.red .. "Program interrupted: " .. tostring(error) .. "" .. colors.white)
  end
  
  print(colors.yellow .. "Returning to starting position before stopping..." .. colors.white)
  returnToStart()
  print(colors.yellow .. "Auto farming stopped." .. colors.white)
end

-- 显示帮助信息
local function showHelp()
  print("Turtle Auto Farmer")
  print("Usage: turtle_farmer")
  print("")
  print("Features:")
  print("  - Automatically detects and harvests mature wheat")
  print("  - Plants wheat seeds automatically")
  print("  - Deposits wheat in nearby chests when inventory is full")
  print("  - Press Ctrl+T to stop the program")
end

-- 主程序
local args = {...}
if #args > 0 and (args[1] == "help" or args[1] == "-h" or args[1] == "--help") then
  showHelp()
else
  startFarming()
end