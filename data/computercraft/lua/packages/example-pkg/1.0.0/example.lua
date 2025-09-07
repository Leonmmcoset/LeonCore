-- Example Package Program
local colors = require('colors')
local term = require('term')

function drawTopBar()
  local w, h = term.getSize()
  term.setBackgroundColor(colors.cyan)
  term.setTextColor(colors.white)
  term.setCursorPos(1, 1)
  term.clearLine()
  local title = "=== Example Package v1.0.0 ==="
  local pos = math.floor((w - #title) / 2) + 1
  term.setCursorPos(pos, 1)
  term.write(title)
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.setCursorPos(1, 3)
end

drawTopBar()
print("\nThis is an example package that demonstrates the features of LeonOS package manager.")
print("\nUsage:")
print("  pkg install example-pkg  - Install this package")
print("  pkg remove example-pkg   - Uninstall this package")
print("  pkg list                 - List installed packages")