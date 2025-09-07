-- LeonOS storage command
local rc = require("rc")
local textutils = require("textutils")
local term = require("term")
local colors = require("colors")
local fs = require("fs")

-- 保存当前颜色设置
local old_fg = term.getTextColor()
local old_bg = term.getBackgroundColor()

-- 设置名称栏颜色并显示
term.setTextColor(colors.white)
term.setBackgroundColor(colors.cyan)
term.at(1, 1).clearLine()
term.at(1, 1).write("=== Storage Information ===")

-- 恢复颜色设置
term.setTextColor(old_fg)
term.setBackgroundColor(old_bg)
term.at(1, 2)

-- 获取存储信息
local total_space = fs.getSize("/")
local free_space = fs.getFreeSpace("/")
local used_space = total_space - free_space

-- 格式化存储容量（转换为MB）
local function formatSize(bytes)
  return string.format("%.2f MB", bytes / 1024 / 1024)
end

-- 显示存储信息
textutils.coloredPrint(colors.yellow, "Total Space:", colors.white, formatSize(total_space))
textutils.coloredPrint(colors.yellow, "Used Space:", colors.white, formatSize(used_space))
textutils.coloredPrint(colors.yellow, "Free Space:", colors.white, formatSize(free_space))

-- 显示存储空间使用百分比
local usage_percent = (used_space / total_space) * 100
textutils.coloredPrint(colors.yellow, "Usage:", colors.white, string.format("%.1f%%", usage_percent))

-- 显示存储设备信息（如果可用）
local function getDriveInfo()
  local drives = fs.list("/")
  if drives and #drives > 0 then
    textutils.coloredPrint(colors.yellow, "Storage Devices:", colors.white)
    for _, drive in ipairs(drives) do
      if fs.isDir("/" .. drive) and drive ~= "rom" and drive ~= "tmp" then
        local drive_size = fs.getSize("/" .. drive)
        print(string.format("  - %s: %s", drive, formatSize(drive_size)))
      end
    end
  end
end

getDriveInfo()

-- 提示信息
term.setTextColor(colors.green)
print("\nTip: Use 'delete' command to free up space.")
term.setTextColor(colors.white)