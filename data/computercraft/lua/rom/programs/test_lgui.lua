-- test_lgui.lua - Test script for lgui library

-- Load the GUI library
local lgui = require("lgui")

-- Create a main window
local mainWindow = lgui.createWindow(2, 2, 40, 15, "LGUI Test")

-- Add a label
local titleLabel = lgui.Label:new(2, 2, "LGUI Test Application", 36)
titleLabel:setAlignment("center")
titleLabel:setColors(lgui.colors.YELLOW, lgui.colors.BLACK)
mainWindow:addChild(titleLabel)

-- Add a text field
local textField = lgui.TextField:new(5, 4, 30)
textField:setText("Enter your name...")
textField:setColors(lgui.colors.WHITE, lgui.colors.BLACK)
mainWindow:addChild(textField)

-- Add a button that shows the text from the text field
local showButton = lgui.Button:new(5, 6, 15, 3, "Show Text")
showButton:setColors(lgui.colors.WHITE, lgui.colors.BLUE)
showButton:setOnClick(function()
  local text = textField:getText()
  if text and text ~= "" then
    resultLabel:setText("You entered: " .. text)
  else
    resultLabel:setText("Please enter some text first")
  end
end)
mainWindow:addChild(showButton)

-- Add a button that changes the background color
local colorButton = lgui.Button:new(22, 6, 15, 3, "Change Color")
colorButton:setColors(lgui.colors.WHITE, lgui.colors.GREEN)
local colors = {lgui.colors.RED, lgui.colors.GREEN, lgui.colors.BLUE, lgui.colors.YELLOW}
local currentColor = 1
colorButton:setOnClick(function()
  currentColor = currentColor % #colors + 1
  mainWindow:setColors(lgui.colors.WHITE, colors[currentColor])
  mainWindow:requestRedraw()
end)
mainWindow:addChild(colorButton)

-- Add a result label
local resultLabel = lgui.Label:new(5, 10, "", 30)
resultLabel:setColors(lgui.colors.CYAN, lgui.colors.BLACK)
mainWindow:addChild(resultLabel)

-- Add an exit button
local exitButton = lgui.Button:new(15, 12, 12, 3, "Exit")
exitButton:setColors(lgui.colors.WHITE, lgui.colors.RED)
exitButton:setOnClick(function()
  lgui.stop()
end)
mainWindow:addChild(exitButton)

-- Start the GUI
print("Starting LGUI test application...")
print("Click and drag the window title bar to move the window.")
print("Type in the text field and click 'Show Text' to see what you entered.")
print("Click 'Change Color' to change the window background color.")
print("Click 'Exit' to quit the application.")
lgui.start()
print("LGUI test application closed.")