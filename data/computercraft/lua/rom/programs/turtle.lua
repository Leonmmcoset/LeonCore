-- turtle.lua - Turtle control program for CC Tweaked

local term = require("term")
local colors = require("colors")
local expect = require("cc.expect").expect
local textutils = require("textutils")

-- 保存当前颜色设置
local old_fg = term.getTextColor()
local old_bg = term.getBackgroundColor()

-- 设置名称栏颜色并显示
term.setTextColor(colors.white)
term.setBackgroundColor(colors.cyan)
term.at(1, 1).clearLine()
term.at(1, 1).write("=== Turtle Control ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

-- 检查是否有turtle
local turtle = require("turtle")
if not turtle then
  error("No turtle detected. Please run this program on a turtle.", 0)
end

-- 显示帮助信息
local function show_help()
  print("Turtle Control Program")
  print("Usage:")
  print("  turtle <command> [arguments]")
  print("")
  print("Movement Commands:")
  print("  forward, f          - Move forward")
  print("  back, b             - Move back")
  print("  up, u               - Move up")
  print("  down, d             - Move down")
  print("  left, l             - Turn left")
  print("  right, r            - Turn right")
  print("")
  print("Mining Commands:")
  print("  dig, d [up|down]    - Dig forward (or up/down)")
  print("  digall              - Dig in all directions")
  print("")
  print("Placement Commands:")
  print("  place [up|down]     - Place block forward (or up/down)")
  print("")
  print("Inventory Commands:")
  print("  inventory, inv      - Show inventory")
  print("  select <slot>       - Select slot (1-16)")
  print("")
  print("Fuel Commands:")
  print("  refuel [amount]     - Refuel using items from inventory (optional amount)")
  print("")
  print("Utility Commands:")
  print("  help, h             - Show this help message")
  print("  version, v          - Show program version")
end

-- 显示版本信息
local function show_version()
  print("Turtle Control Program v1.0")
  print("Part of LeonOS for CC Tweaked")
end

-- 移动命令
local function move_forward()
  print("Moving forward...")
  if turtle.forward() then
    print(colors.green .. "Success!" .. colors.white)
  else
    print(colors.red .. "Failed! Blocked or no fuel." .. colors.white)
  end
end

local function move_back()
  print("Moving back...")
  if turtle.back() then
    print(colors.green .. "Success!" .. colors.white)
  else
    print(colors.red .. "Failed! Blocked or no fuel." .. colors.white)
  end
end

local function move_up()
  print("Moving up...")
  if turtle.up() then
    print(colors.green .. "Success!" .. colors.white)
  else
    print(colors.red .. "Failed! Blocked or no fuel." .. colors.white)
  end
end

local function move_down()
  print("Moving down...")
  if turtle.down() then
    print(colors.green .. "Success!" .. colors.white)
  else
    print(colors.red .. "Failed! Blocked or no fuel." .. colors.white)
  end
end

local function turn_left()
  print("Turning left...")
  turtle.turnLeft()
  print(colors.green .. "Success!" .. colors.white)
end

local function turn_right()
  print("Turning right...")
  turtle.turnRight()
  print(colors.green .. "Success!" .. colors.white)
end

-- 挖掘命令
local function dig(direction)
  direction = direction or "forward"
  print("Digging " .. direction .. "...")
  local success
  if direction == "up" then
    success = turtle.digUp()
  elseif direction == "down" then
    success = turtle.digDown()
  else
    success = turtle.dig()
  end
  if success then
    print(colors.green .. "Success!" .. colors.white)
  else
    print(colors.red .. "Failed! Nothing to dig or no tool." .. colors.white)
  end
end

local function dig_all()
  print("Digging in all directions...")
  dig()
  dig("up")
  dig("down")
end

-- 放置命令
local function place(direction)
  direction = direction or "forward"
  print("Placing block " .. direction .. "...")
  local success
  if direction == "up" then
    success = turtle.placeUp()
  elseif direction == "down" then
    success = turtle.placeDown()
  else
    success = turtle.place()
  end
  if success then
    print(colors.green .. "Success!" .. colors.white)
  else
    print(colors.red .. "Failed! No block to place or invalid position." .. colors.white)
  end
end

-- 物品栏命令
local function show_inventory()
  print("Turtle Inventory:")
  print("=================")
  for i = 1, 16 do
    local itemCount = turtle.getItemCount(i)
    if itemCount > 0 then
      term.setTextColor(colors.yellow)
      print("Slot " .. i .. ":" .. colors.white .. " " .. itemCount .. " items")
    else
      print("Slot " .. i .. ": Empty")
    end
  end
end

local function select_slot(slot)
  expect(1, slot, "number")
  if slot < 1 or slot > 16 then
    error("Slot must be between 1 and 16", 0)
  end
  print("Selecting slot " .. slot .. "...")
  if turtle.select(slot) then
    print(colors.green .. "Success!" .. colors.white)
  else
    print(colors.red .. "Failed! Invalid slot." .. colors.white)
  end
end

-- 燃料命令
local function refuel(amount)
  expect(1, amount, "number", "nil")
  amount = amount or 64 -- 默认使用最大数量

  print("Current fuel level: " .. turtle.getFuelLevel() .. "/" .. turtle.getFuelLimit())
  print("Searching for fuel...")

  local initial_slot = turtle.getSelectedSlot()
  local found_fuel = false

  for slot = 1, 16 do
    if turtle.getItemCount(slot) > 0 then
      turtle.select(slot)
      local itemDetail = turtle.getItemDetail()
      if itemDetail and itemDetail.fuel then
        found_fuel = true
        print("Found fuel in slot " .. slot .. ": " .. itemDetail.name)
        local fuelAmount = math.min(amount, turtle.getItemCount(slot))
        print("Refueling with " .. fuelAmount .. " items...")
        if turtle.refuel(fuelAmount) then
          print(colors.green .. "Success! Fuel level: " .. turtle.getFuelLevel() .. colors.white)
          if turtle.getFuelLevel() >= turtle.getFuelLimit() then
            print("Fuel tank is full!")
            break
          end
          amount = amount - fuelAmount
          if amount <= 0 then
            break
          end
        else
          print(colors.red .. "Failed to refuel with this item." .. colors.white)
        end
      end
    end
  end

  -- 恢复原来选中的槽位
  turtle.select(initial_slot)

  if not found_fuel then
    print(colors.red .. "No fuel found in inventory." .. colors.white)
  end
end

-- 主程序
local args = {...}
if #args == 0 then
  show_help()
else
  local command = args[1]:lower()
  if command == "help" or command == "h" then
    show_help()
  elseif command == "version" or command == "v" then
    show_version()
  elseif command == "forward" or command == "f" then
    move_forward()
  elseif command == "back" or command == "b" then
    move_back()
  elseif command == "up" or command == "u" then
    move_up()
  elseif command == "down" or command == "d" then
    if #args > 1 and (args[2] == "up" or args[2] == "down") then
      dig(args[2])
    else
      move_down()
    end
  elseif command == "left" or command == "l" then
    turn_left()
  elseif command == "right" or command == "r" then
    turn_right()
  elseif command == "dig" then
    if #args > 1 and (args[2] == "up" or args[2] == "down") then
      dig(args[2])
    else
      dig()
    end
  elseif command == "digall" then
    dig_all()
  elseif command == "place" then
    if #args > 1 and (args[2] == "up" or args[2] == "down") then
      place(args[2])
    else
      place()
    end
  elseif command == "inventory" or command == "inv" then
    show_inventory()
  elseif command == "select" then
    if #args > 1 then
      select_slot(tonumber(args[2]))
    else
      error("Missing slot number", 0)
    end
  elseif command == "refuel" then
    if #args > 1 then
      refuel(tonumber(args[2]))
    else
      refuel()
    end
  else
    error("Unknown command: " .. command, 0)
  end
end