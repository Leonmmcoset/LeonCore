-- LeonCore Updater
-- Version: 0.3.8
-- This script ensures reliable updates for the LeonCore operating system

-- Ensure core APIs are available
local fs = rawget(_G, "fs") or error("Filesystem API not available")
local term = rawget(_G, "term") or error("Terminal API not available")
local http = rawget(_G, "http")
if not http then
  -- Try to load the http module if not directly available
  local success
  success, http = pcall(require, "http")
  if not success then
    error("HTTP API not available. Cannot perform update.")
  end
  _G.http = http
end

-- Configuration
_G._RC_ROM_DIR = _RC_ROM_DIR or "/LeonCore"
if _RC_ROM_DIR == "/rom" then _RC_ROM_DIR = "/LeonCore" end

local REPO_OWNER = "Leonmmcoset"
local REPO_NAME = "LeonCore"
local BRANCH = "main"
local BASE_PATH = "data/computercraft/lua/"

-- Fail-safe mechanism
local function createFailsafe()
  local start_rc = [[
    local fs = rawget(_G, "fs")
    local term = rawget(_G, "term")
    
    local function setupScreen()
      local w, h = term.getSize()
      term.setBackgroundColor(0x4000) -- Red background
      term.clear()
      
      local title = "LeonCore Updater (Failure Notice)"
      term.setTextColor(0x1) -- White text
      local x = math.floor(w/2 - #title/2)
      term.setCursorPos(x > 1 and x or 1, 1)
      term.write(title)
      
      local message = {
        "A LeonCore update has failed or",
        "been interrupted.",
        "Your files should remain intact.",
        "",
        "Press any key to revert to the ROM."
      }
      
      for i, line in ipairs(message) do
        term.setCursorPos(math.floor(w/2 - #line/2), i + 3)
        term.write(line)
      end
      term.setCursorBlink(true)
    end
    
    -- Setup the screen and wait for user input
    setupScreen()
    repeat local event = {coroutine.yield()} until event[1] == "char" or event[1] == "key"
    
    -- Cleanup and reboot
    pcall(fs.delete, _RC_ROM_DIR)
    pcall(fs.delete, "/.start_rc.lua")
    
    os.reboot()
    while true do coroutine.yield() end
  ]]
  
  local handle, err = fs.open("/.start_rc.lua", "w")
  if handle then
    handle.write(start_rc)
    handle.close()
  else
    error("Failed to create failsafe: " .. (err or "unknown error"))
  end
end

-- Helper function to set cursor position
local function at(x, y)
  term.setCursorPos(x, y)
  return term
end

-- HTTP request with error handling
local function httpGet(url, timeout) 
  timeout = timeout or 30
  
  local request = http.request(url, nil, nil, true)
  if not request then
    return nil, "Failed to initiate HTTP request"
  end
  
  local startTime = os.clock()
  while true do
    local event = table.pack(coroutine.yield())
    
    if os.clock() - startTime > timeout then
      return nil, "HTTP request timed out"
    end
    
    if event[1] == "http_success" and event[2] == request then
      local response = event[3]
      local data = response.readAll()
      response.close()
      return data
    elseif event[1] == "http_failure" and event[2] == request then
      return nil, "HTTP request failed: " .. (event[3] or "unknown error")
    end
  end
end

-- Load JSON library
local function loadJsonLib()
  local jsonData, err = httpGet("https://raw.githubusercontent.com/rxi/json.lua/master/json.lua")
  if not jsonData then
    -- Try alternative source if first fails
    jsonData, err = httpGet("https://raw.githubusercontent.com/meepdarknessmeep/json.lua/master/json.lua")
    if not jsonData then
      return nil, "Failed to load JSON library: " .. err
    end
  end
  
  local success, json = pcall(loadstring(jsonData, "json.lua"))
  if not success then
    return nil, "Failed to parse JSON library: " .. json
  end
  
  return json()
end

-- Get current version from installer.lua
local function getCurrentVersion()
  if fs.exists(_RC_ROM_DIR .. "/installer.lua") then
    local handle = fs.open(_RC_ROM_DIR .. "/installer.lua", "r")
    if handle then
      local content = handle.readAll()
      handle.close()
      
      local version = content:match('local%s+version%s*=%s*"([^"]+)"')
      if version then
        return version
      end
    end
  end
  return "unknown"
end

-- Main update function
local function updateSystem()
  createFailsafe()
  
  -- Setup terminal
  local w, h = term.getSize()
  term.clear()
  term.setBackgroundColor(0x8000) -- Blue background
  term.setTextColor(0x1) -- White text
  
  -- Header function
  local function header()
    term.setBackgroundColor(0x8000)
    term.setTextColor(0x10) -- Cyan text
    at(1, 1).clearLine()
    at(1, 1).write("LeonCore Updater")
    at(1, 2).clearLine()
    at(1, 2).write("=====================")
    term.setTextColor(0x1)
  end
  
  -- Write function with scrolling
  local y = 1
  local function write(text)
    term.setBackgroundColor(0x8000)
    if y > h - 3 then
      term.scroll(1)
      header()
    else
      y = y + 1
    end
    at(1, y + 2).write(text)
  end
  
  -- Progress bar function
  local function progress(a, b)
    term.setBackgroundColor(0x8000)
    at(1, 3).clearLine()
    
    local barWidth = w - 4
    local progressWidth = math.ceil(barWidth * (a / b))
    
    term.setTextColor(0x1) -- White text for progress number
    at(1, 3).write(string.format("%d/%d ", a, b))
    
    term.setBackgroundColor(0x1) -- White background for progress bar
    at(#string.format("%d/%d ", a, b) + 1, 3).write(" ":rep(progressWidth))
    
    term.setBackgroundColor(0x8000) -- Reset to blue background
  end
  
  -- Initialize header
  header()
  
  -- Display current version
  local currentVersion = getCurrentVersion()
  write("Current version: " .. currentVersion)
  
  -- Load JSON library
  write("Loading JSON library...")
  local json, err = loadJsonLib()
  if not json then
    write("Error: " .. err)
    write("Press any key to exit.")
    term.setCursorBlink(true)
    repeat local event = {coroutine.yield()} until event[1] == "char" or event[1] == "key"
    return false
  end
  
  -- Get repository tree
  write("Getting repository file list...")
  local repodata, err = httpGet("https://api.github.com/repos/" .. REPO_OWNER .. "/" .. REPO_NAME .. "/git/trees/" .. BRANCH .. "?recursive=1")
  if not repodata then
    write("Error: " .. err)
    write("Press any key to exit.")
    term.setCursorBlink(true)
    repeat local event = {coroutine.yield()} until event[1] == "char" or event[1] == "key"
    return false
  end
  
  -- Parse repository data
  local success, parsedData = pcall(json.decode, repodata)
  if not success then
    write("Error parsing repository data: " .. parsedData)
    write("Press any key to exit.")
    term.setCursorBlink(true)
    repeat local event = {coroutine.yield()} until event[1] == "char" or event[1] == "key"
    return false
  end
  
  -- Filter files to download
  write("Filtering files for download...")
  local filesToDownload = {}
  local directoriesToCreate = {}
  
  for _, entry in pairs(parsedData.tree) do
    if entry.path and entry.path:sub(1, #BASE_PATH) == BASE_PATH then
      local relativePath = entry.path:sub(#BASE_PATH + 1)
      local realPath = relativePath:gsub("^/?rom", _RC_ROM_DIR)
      
      if entry.type == "tree" then
        table.insert(directoriesToCreate, realPath)
      elseif entry.type == "blob" and realPath ~= "unbios.lua" then
        table.insert(filesToDownload, {
          path = relativePath,
          realPath = realPath
        })
      end
    end
  end
  
  write("Found " .. #filesToDownload .. " files to update.")
  
  -- Create directories
  write("Creating necessary directories...")
  for _, dirPath in ipairs(directoriesToCreate) do
    pcall(fs.makeDir, dirPath)
  end
  
  -- Download and write files
  write("Downloading and installing files...")
  local successCount = 0
  local failCount = 0
  local lastProgress = 0
  
  for i, fileInfo in ipairs(filesToDownload) do
    local url = "https://raw.githubusercontent.com/" .. REPO_OWNER .. "/" .. REPO_NAME .. "/" .. BRANCH .. "/" .. BASE_PATH .. fileInfo.path
    local content, err = httpGet(url)
    
    if content then
      -- Ensure the directory exists
      local dir = fs.getDir(fileInfo.realPath)
      if not fs.isDir(dir) then
        pcall(fs.makeDir, dir)
      end
      
      -- Write the file
      local handle, writeErr = fs.open(fileInfo.realPath, "w")
      if handle then
        handle.write(content)
        handle.close()
        successCount = successCount + 1
        
        -- Update progress bar if it changed significantly
        local currentProgress = math.floor((i / #filesToDownload) * 10)
        if currentProgress > lastProgress then
          lastProgress = currentProgress
          progress(i, #filesToDownload)
        end
      else
        failCount = failCount + 1
        write("Failed to write " .. fileInfo.realPath .. ": " .. (writeErr or "unknown error"))
      end
    else
      failCount = failCount + 1
      write("Failed to download " .. fileInfo.path .. ": " .. err)
    end
  end
  
  -- Final status
  progress(#filesToDownload, #filesToDownload)
  write("")
  write("Update completed!")
  write(string.format("Success: %d, Failed: %d", successCount, failCount))
  
  if failCount > 0 then
    write("")
    write("Some files failed to update.")
    write("You may need to run the updater again.")
  end
  
  write("")
  write("Press any key to reboot and apply changes.")
  term.setCursorBlink(true)
  repeat local event = {coroutine.yield()} until event[1] == "char" or event[1] == "key"
  
  -- Cleanup and reboot
  pcall(fs.delete, "/.start_rc.lua")
  os.reboot()
  while true do coroutine.yield() end
end

-- Run the update with error handling
local success, err = pcall(updateSystem)
if not success then
  term.clear()
  term.setBackgroundColor(0x4000)
  term.setTextColor(0x1)
  at(1, 1).write("LeonCore Update Error")
  at(1, 3).write("An error occurred during the update:")
  at(1, 5).write(err)
  at(1, 7).write("Press any key to exit.")
  term.setCursorBlink(true)
  repeat local event = {coroutine.yield()} until event[1] == "char" or event[1] == "key"
  
  -- Try to cleanup
  pcall(fs.delete, "/.start_rc.lua")
end
