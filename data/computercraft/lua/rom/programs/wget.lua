-- wget

if not package.loaded.http then
  error("HTTP is not enabled in the ComputerCraft configuration", 0)
end

local http = require("http")
local fs = require("fs")

local args = {...}

if #args == 0 then
  io.stderr:write([[Usage:
wget <url> [filename]
wget run <url>
]])
  return
end

local function get(url)
  local handle, err = http.get(url, nil, true)
  if not handle then
    error(err, 0)
  end

  local data = handle.readAll()
  handle.close()

  return data
end

if args[1] == "run" then
  local data = get(args[2])
  -- 确保常用模块已加载
  if not _G.fs then _G.fs = require("fs") end
  if not _G.term then _G.term = require("term") end
  if not _G.colors then _G.colors = require("colors") end
  if not _G.textutils then _G.textutils = require("textutils") end
  if not _G.shell then _G.shell = require("shell") end
  if not _G.http then _G.http = require("http") end

  -- 执行下载的代码
  local func, err = load(data, "=<wget-run>", "t", _G)
  if not func then
    error("Failed to load downloaded code: " .. err, 0)
  end
  assert(pcall(func))
else
  local filename = args[2] or (args[1]:match("[^/]+$")) or
    error("could not determine file name", 0)
  local data = get(args[1])
  local handle, err = io.open(filename, "w")
  if not handle then
    error(err, 0)
  end
  handle:write(data)
  handle:close()
end
