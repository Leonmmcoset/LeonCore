-- network.lua - Network utility tool for CC Tweaked

local expect = require("cc.expect").expect
local rednet = require("rednet")
local term = require("term")
local textutils = require("textutils")
local os = require("os")
local colors = require("colors")

-- Check if HTTP is available
local http_available = package.loaded.http ~= nil
local http = nil
if http_available then
  http = require("http")
end

local function print_usage()
  print("Network Utility Tool")
  print("Usage:")
  print("  network status          - Check network status")
  print("  network scan <ip> [port_range] - Scan ports on a device")
  print("  network discover        - Discover remote devices")
  print("  network help            - Show this help")
end

local function check_network_status()
  print("=== Network Status ===")
  print("HTTP: " .. (http_available and "Enabled" or "Disabled"))

  local modems = {}
  for _, side in pairs(peripheral.getNames()) do
    if peripheral.getType(side) == "modem" then
      table.insert(modems, side)
    end
  end

  print("Available modems: " .. #modems)
  if #modems > 0 then
    print("Modem list:")
    for _, modem in ipairs(modems) do
      print("  - " .. modem .. " (Open: " .. tostring(rednet.isOpen(modem)) .. ")")
    end
  end
end

local function scan_ports(ip, port_range)
  if not http_available then
    error("HTTP is not enabled in the ComputerCraft configuration", 0)
  end

  expect(1, ip, "string")
  expect(2, port_range, "string", "nil")

  local start_port, end_port = 1, 1024
  if port_range then
    start_port, end_port = port_range:match("(%d+)-(%d+)")
    if not start_port or not end_port then
      error("Invalid port range format. Use: start-end", 0)
    end
    start_port = tonumber(start_port)
    end_port = tonumber(end_port)
  end

  print("Scanning ports " .. start_port .. "-" .. end_port .. " on " .. ip)
  print("Press Ctrl+T to cancel")

  local open_ports = {}
  local timeout = 0.5  -- seconds per port

  for port = start_port, end_port do
    term.write("Scanning port " .. port .. "... ")

    local success, result = pcall(function()
      local url = "http://" .. ip .. ":" .. port
      local handle = http.get(url, nil, true, timeout)
      if handle then
        handle.close()
        return true
      end
      return false
    end)

    if success and result then
      print(colors.green .. "OPEN" .. colors.white)
      table.insert(open_ports, port)
    else
      print(colors.red .. "CLOSED" .. colors.white)
    end

    -- Check for interrupt
    local timer_id = os.startTimer(0.1)
    while true do
      local event, param1 = os.pullEventRaw()
      if event == "timer" and param1 == timer_id then
        break
      elseif event == "terminate" then
        print("\nScan cancelled.")
        return
      end
    end  -- Small delay to prevent CPU overload
  end

  print("\nScan complete.")
  if #open_ports > 0 then
    print("Open ports found: " .. #open_ports)
    for _, port in ipairs(open_ports) do
      print("  - " .. port)
    end
  else
    print("No open ports found.")
  end
end

local function discover_devices()
  -- Find available modems and open them
  local modems = {}
  for _, side in pairs(peripheral.getNames()) do
    if peripheral.getType(side) == "modem" then
      table.insert(modems, side)
      if not rednet.isOpen(side) then
        rednet.open(side)
      end
    end
  end

  if #modems == 0 then
    error("No modems found. Please attach a modem.", 0)
  end

  print("Discovering devices on network...")
  print("Press Ctrl+T to cancel")

  -- Ensure rednet is running without blocking
  if not rednet.isOpen() then
    -- We don't use rednet.run() as it blocks, instead we'll handle events manually
    for _, modem in ipairs(modems) do
      rednet.open(modem)
    end
  end

  -- Send broadcast
  rednet.broadcast("DISCOVER")

  local devices = {}
  local timeout = 5  -- seconds
  local timer = os.startTimer(timeout)

  while true do
    local event = table.pack(os.pullEvent())
    if event[1] == "timer" and event[2] == timer then
      break
    elseif event[1] == "rednet_message" then
      local sender_id = event[2]
      local message = event[3]
      if message == "DISCOVER_RESPONSE" then
        if not devices[sender_id] then
          devices[sender_id] = true
          print("Found device: " .. sender_id)
        end
      end
    elseif event[1] == "terminate" then
      print("\nDiscovery cancelled.")
      break
    end
  end

  -- Close modems
  for _, modem in ipairs(modems) do
    rednet.close(modem)
  end

  print("\nDiscovery complete.")
  print("Found " .. textutils.size(devices) .. " devices.")
end

-- Main program
local args = {...}
if #args == 0 or args[1] == "help" then
  print_usage()
elseif args[1] == "status" then
  check_network_status()
elseif args[1] == "scan" then
  if #args < 2 then
    print("Error: Missing IP address")
    print_usage()
  else
    scan_ports(args[2], args[3])
  end
elseif args[1] == "discover" then
  discover_devices()
else
  print("Error: Unknown command")
  print_usage()
end