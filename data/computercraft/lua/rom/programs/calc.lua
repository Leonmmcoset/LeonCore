-- Calculator program calc.lua
local term = require("term")
local keys = require("keys")
local colors = require("colors")

-- Function to draw top bar
local function drawTopBar()
    -- Get terminal size
    local w, h = term.getSize()
    
    -- Save cursor position
    local cx, cy = term.getCursorPos()
    
    -- Set top bar color
    term.setTextColor(colors.yellow)
    term.setBackgroundColor(colors.blue)
    
    -- Move to top-left corner
    term.setCursorPos(1, 1)
    
    -- Draw top bar with centered title
    local title = "=== LeonOS Calculator ==="
    local padding = math.floor((w - #title) / 2)
    term.write(string.rep(" ", padding) .. title .. string.rep(" ", padding))
    
    -- Reset colors
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    
    -- Restore cursor position
    term.setCursorPos(cx, cy)
end

-- Clear screen and show UI
term.clear()
drawTopBar()

-- Move cursor to below top bar and show instructions
term.setCursorPos(1, 3)
print("Enter an expression, press Enter to calculate (type 'q' to quit)")
print("Supports +, -, *, /, ^(exponent), %(modulus), and parentheses")
print("---------------------------")

while true do
    -- Show prompt
    io.write("> ")
    local input = io.read()
    
    -- Check for exit
    if input == "q" or input == "quit" then
        break
    end
    
    -- Check for clear screen
    if input == "clear" then
        term.clear()
drawTopBar()
        -- Move cursor to below top bar and show instructions
        term.setCursorPos(1, 3)
        print("Enter an expression, press Enter to calculate (type 'q' to quit)")
        print("Supports +, -, *, /, ^(exponent), %(modulus), and parentheses")
        print("---------------------------")
        goto continue
    end
    
    -- Calculate expression
    local success, result = pcall(function()
        -- Replace Chinese parentheses with English ones
        input = input:gsub("（", "("):gsub("）", ")")
        -- Safely execute expression
        local func = load("return " .. input)
        if func then
            return func()
        else
            error("Invalid expression")
        end
    end)
    
    -- Show result
    if success then
        print("Result: " .. result)
    else
        print("Error: " .. tostring(result))
    end
    
    ::continue::
end

print("Calculator has exited")