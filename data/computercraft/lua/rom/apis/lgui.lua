-- lgui.lua - Simple GUI library for CC Tweaked
-- Version: 0.1

local lgui = {}

-- Dependencies
local term = require("term")
local window = require("window")
local colors = require("colors")
local keys = require("keys")

-- Constants
lgui.colors = {
  BLACK = colors.black,
  WHITE = colors.white,
  RED = colors.red,
  GREEN = colors.green,
  BLUE = colors.blue,
  YELLOW = colors.yellow,
  CYAN = colors.cyan,
  MAGENTA = colors.magenta,
  GRAY = colors.gray,
  LIGHT_GRAY = colors.lightGray,
  LIGHT_RED = colors.lightRed,
  LIGHT_GREEN = colors.lightGreen,
  LIGHT_BLUE = colors.lightBlue,
  LIGHT_YELLOW = colors.lightYellow,
  LIGHT_CYAN = colors.lightCyan,
  LIGHT_MAGENTA = colors.lightMagenta
}

-- Base class for UI elements
local UIElement = {}
UIElement.__index = UIElement

function UIElement:new(x, y, width, height)
  local obj = setmetatable({}, self)
  obj.x = x
  obj.y = y
  obj.width = width
  obj.height = height
  obj.visible = true
  obj.enabled = true
  obj.bgColor = lgui.colors.BLACK
  obj.fgColor = lgui.colors.WHITE
  obj.parent = nil
  return obj
end

function UIElement:setPosition(x, y)
  self.x = x
  self.y = y
  if self.parent then self.parent:requestRedraw() end
end

function UIElement:setSize(width, height)
  self.width = width
  self.height = height
  if self.parent then self.parent:requestRedraw() end
end

function UIElement:setVisible(visible)
  self.visible = visible
  if self.parent then self.parent:requestRedraw() end
end

function UIElement:setEnabled(enabled)
  self.enabled = enabled
  if self.parent then self.parent:requestRedraw() end
end

function UIElement:setColors(fg, bg)
  self.fgColor = fg or self.fgColor
  self.bgColor = bg or self.bgColor
  if self.parent then self.parent:requestRedraw() end
end

function UIElement:containsPoint(x, y)
  return x >= self.x and x <= self.x + self.width - 1 and
         y >= self.y and y <= self.y + self.height - 1
end

function UIElement:draw()
  -- To be overridden by subclasses
end

function UIElement:handleEvent(event, ...)
  -- To be overridden by subclasses
  return false
end

-- Label class
local Label = setmetatable({}, UIElement)
Label.__index = Label

function Label:new(x, y, text, width)
  local obj = UIElement:new(x, y, width or #text, 1)
  obj = setmetatable(obj, self)
  obj.text = text
  obj.align = "left"
  return obj
end

function Label:setText(text)
  self.text = text
  if #text > self.width then
    self.width = #text
  end
  if self.parent then self.parent:requestRedraw() end
end

function Label:setAlignment(align)
  self.align = align
  if self.parent then self.parent:requestRedraw() end
end

function Label:draw()
  if not self.visible then return end

  local oldFg = term.getTextColor()
  local oldBg = term.getBackgroundColor()
  term.setTextColor(self.fgColor)
  term.setBackgroundColor(self.bgColor)

  local displayText = self.text
  if #displayText > self.width then
    displayText = displayText:sub(1, self.width)
  end

  if self.align == "center" then
    local padding = math.floor((self.width - #displayText) / 2)
    term.setCursorPos(self.x + padding, self.y)
    term.write(displayText)
  elseif self.align == "right" then
    local padding = self.width - #displayText
    term.setCursorPos(self.x + padding, self.y)
    term.write(displayText)
  else -- left
    term.setCursorPos(self.x, self.y)
    term.write(displayText)
  end

  term.setTextColor(oldFg)
  term.setBackgroundColor(oldBg)
end

-- Button class
local Button = setmetatable({}, UIElement)
Button.__index = Button

function Button:new(x, y, width, height, text)
  local obj = UIElement:new(x, y, width, height)
  obj = setmetatable(obj, self)
  obj.text = text or "Button"
  obj.onClick = nil
  obj.active = false
  obj.borderColor = lgui.colors.GRAY
  return obj
end

function Button:setText(text)
  self.text = text
  if self.parent then self.parent:requestRedraw() end
end

function Button:setOnClick(callback)
  self.onClick = callback
end

function Button:draw()
  if not self.visible then return end

  local oldFg = term.getTextColor()
  local oldBg = term.getBackgroundColor()

  -- Draw border
  term.setTextColor(self.borderColor)
  term.setBackgroundColor(self.bgColor)

  -- Top border
  term.setCursorPos(self.x, self.y)
  term.write(" ")
  for i = 1, self.width - 2 do
    term.write("-")
  end
  term.write(" ")

  -- Middle rows
  for y = 1, self.height - 2 do
    term.setCursorPos(self.x, self.y + y)
    term.write("|")
    term.setCursorPos(self.x + self.width - 1, self.y + y)
    term.write("|")
  end

  -- Bottom border
  term.setCursorPos(self.x, self.y + self.height - 1)
  term.write(" ")
  for i = 1, self.width - 2 do
    term.write("-")
  end
  term.write(" ")

  -- Draw text
  if self.active and self.enabled then
    term.setTextColor(self.bgColor)
    term.setBackgroundColor(self.fgColor)
  else
    term.setTextColor(self.fgColor)
    term.setBackgroundColor(self.bgColor)
  end

  local textX = self.x + math.floor((self.width - #self.text) / 2)
  local textY = self.y + math.floor(self.height / 2)
  term.setCursorPos(textX, textY)
  term.write(self.text)

  term.setTextColor(oldFg)
  term.setBackgroundColor(oldBg)
end

function Button:handleEvent(event, ...)
  if not self.enabled or not self.visible then return false end

  if event == "mouse_click" then
    local button, x, y = ...
    if button == 1 and self:containsPoint(x, y) then
      self.active = true
      if self.parent then self.parent:requestRedraw() end
      return true
    end
  elseif event == "mouse_up" then
    local button, x, y = ...
    if button == 1 and self.active then
      self.active = false
      if self.parent then self.parent:requestRedraw() end
      if self:containsPoint(x, y) and self.onClick then
        self.onClick()
      end
      return true
    end
  end
  return false
end

-- TextField class
local TextField = setmetatable({}, UIElement)
TextField.__index = TextField

function TextField:new(x, y, width)
  local obj = UIElement:new(x, y, width, 1)
  obj = setmetatable(obj, self)
  obj.text = ""
  obj.cursorPos = 0
  obj.focused = false
  obj.onChange = nil
  obj.borderColor = lgui.colors.GRAY
  return obj
end

function TextField:setText(text)
  self.text = text
  self.cursorPos = #text
  if self.parent then self.parent:requestRedraw() end
  if self.onChange then self.onChange(self.text) end
end

function TextField:getText()
  return self.text
end

function TextField:setOnChange(callback)
  self.onChange = callback
end

function TextField:focus()
  self.focused = true
  if self.parent then self.parent:requestRedraw() end
end

function TextField:blur()
  self.focused = false
  if self.parent then self.parent:requestRedraw() end
end

function TextField:draw()
  if not self.visible then return end

  local oldFg = term.getTextColor()
  local oldBg = term.getBackgroundColor()

  -- Draw border
  term.setTextColor(self.borderColor)
  term.setBackgroundColor(self.bgColor)
  term.setCursorPos(self.x, self.y)
  term.write("[")
  for i = 1, self.width - 2 do
    term.write(" ")
  end
  term.write("]")

  -- Draw text
  term.setTextColor(self.fgColor)
  term.setBackgroundColor(self.bgColor)

  local displayText = self.text
  if #displayText > self.width - 2 then
    -- Scroll text if too long
    local start = math.max(1, #displayText - (self.width - 2) + 1)
    displayText = displayText:sub(start)
    self.cursorPosDisplay = self.cursorPos - start + 1
  else
    self.cursorPosDisplay = self.cursorPos + 1
  end

  term.setCursorPos(self.x + 1, self.y)
  term.write(displayText)
  term.write(string.rep(" ", (self.width - 2) - #displayText))

  -- Draw cursor
  if self.focused and self.enabled then
    term.setCursorPos(self.x + self.cursorPosDisplay, self.y)
    -- CC Tweaked doesn't support term.blink, so we'll invert the colors instead
    local currentFg = term.getTextColor()
    local currentBg = term.getBackgroundColor()
    term.setTextColor(currentBg)
    term.setBackgroundColor(currentFg)
    term.write(" ")
    term.setTextColor(currentFg)
    term.setBackgroundColor(currentBg)
    term.setCursorPos(self.x + self.cursorPosDisplay, self.y)
  end

  term.setTextColor(oldFg)
  term.setBackgroundColor(oldBg)
end

function TextField:handleEvent(event, ...)
  if not self.enabled or not self.visible then return false end

  if event == "mouse_click" then
    local button, x, y = ...
    if button == 1 and self:containsPoint(x, y) then
      self:focus()
      -- Set cursor position based on click
      local relX = x - self.x - 1
      if relX < 0 then relX = 0 end
      if relX > #self.text then relX = #self.text end
      self.cursorPos = relX
      return true
    elseif button == 1 then
      self:blur()
    end
  elseif event == "key" and self.focused then
    local key = ...
    if key == keys.backspace then
      if self.cursorPos > 0 then
        self.text = self.text:sub(1, self.cursorPos - 1) .. self.text:sub(self.cursorPos + 1)
        self.cursorPos = self.cursorPos - 1
        if self.parent then self.parent:requestRedraw() end
        if self.onChange then self.onChange(self.text) end
      end
      return true
    elseif key == keys.delete then
      if self.cursorPos < #self.text then
        self.text = self.text:sub(1, self.cursorPos) .. self.text:sub(self.cursorPos + 2)
        if self.parent then self.parent:requestRedraw() end
        if self.onChange then self.onChange(self.text) end
      end
      return true
    elseif key == keys.left then
      if self.cursorPos > 0 then
        self.cursorPos = self.cursorPos - 1
        if self.parent then self.parent:requestRedraw() end
      end
      return true
    elseif key == keys.right then
      if self.cursorPos < #self.text then
        self.cursorPos = self.cursorPos + 1
        if self.parent then self.parent:requestRedraw() end
      end
      return true
    elseif key == keys.home then
      self.cursorPos = 0
      if self.parent then self.parent:requestRedraw() end
      return true
    elseif key == keys["end"] then
      self.cursorPos = #self.text
      if self.parent then self.parent:requestRedraw() end
      return true
    end
  elseif event == "char" and self.focused then
    local char = ...
    self.text = self.text:sub(1, self.cursorPos) .. char .. self.text:sub(self.cursorPos + 1)
    self.cursorPos = self.cursorPos + 1
    if self.parent then self.parent:requestRedraw() end
    if self.onChange then self.onChange(self.text) end
    return true
  end
  return false
end

-- Window class
local Window = setmetatable({}, UIElement)
Window.__index = Window

function Window:new(x, y, width, height, title)
  local obj = UIElement:new(x, y, width, height)
  obj = setmetatable(obj, self)
  obj.title = title or "Window"
  obj.children = {}
  obj.dragging = false
  obj.dragOffsetX = 0
  obj.dragOffsetY = 0
  obj.needsRedraw = true
  obj.borderColor = lgui.colors.GRAY
  obj.titleBarColor = lgui.colors.CYAN
  obj.titleTextColor = lgui.colors.WHITE
  return obj
end

function Window:addChild(child)
  table.insert(self.children, child)
  child.parent = self
  self:requestRedraw()
end

function Window:removeChild(child)
  for i, c in ipairs(self.children) do
    if c == child then
      table.remove(self.children, i)
      child.parent = nil
      self:requestRedraw()
      return true
    end
  end
  return false
end

function Window:requestRedraw()
  self.needsRedraw = true
end

function Window:draw()
  if not self.visible then return end

  if not self.needsRedraw then return end
  self.needsRedraw = false

  local oldFg = term.getTextColor()
  local oldBg = term.getBackgroundColor()

  -- Draw border
  term.setTextColor(self.borderColor)
  term.setBackgroundColor(self.bgColor)

  -- Top border with title
  term.setCursorPos(self.x, self.y)
  term.write(" ")
  term.setTextColor(self.titleTextColor)
  term.setBackgroundColor(self.titleBarColor)
  local title = " " .. self.title .. " "
  term.write(title)
  term.setTextColor(self.borderColor)
  term.setBackgroundColor(self.bgColor)
  for i = #title + 1, self.width - 2 do
    term.write("-")
  end
  term.write(" ")

  -- Middle rows
  for y = 1, self.height - 2 do
    term.setCursorPos(self.x, self.y + y)
    term.write("|")
    term.setCursorPos(self.x + self.width - 1, self.y + y)
    term.write("|")
  end

  -- Bottom border
  term.setCursorPos(self.x, self.y + self.height - 1)
  term.write(" ")
  for i = 1, self.width - 2 do
    term.write("-")
  end
  term.write(" ")

  -- Clear content area
  term.setBackgroundColor(self.bgColor)
  for y = 1, self.height - 2 do
    term.setCursorPos(self.x + 1, self.y + y)
    term.write(string.rep(" ", self.width - 2))
  end

  -- Draw children
  for _, child in ipairs(self.children) do
    child:draw()
  end

  term.setTextColor(oldFg)
  term.setBackgroundColor(oldBg)
end

function Window:handleEvent(event, ...)
  if not self.visible then return false end

  -- Handle window events first
  if event == "mouse_click" then
    local button, x, y = ...
    if button == 1 and y == self.y and x >= self.x and x <= self.x + self.width - 1 then
      -- Start dragging
      self.dragging = true
      self.dragOffsetX = x - self.x
      self.dragOffsetY = y - self.y
      return true
    end
  elseif event == "mouse_drag" then
    local button, x, y = ...
    if button == 1 and self.dragging then
      -- Drag window
      self:setPosition(x - self.dragOffsetX, y - self.dragOffsetY)
      return true
    end
  elseif event == "mouse_up" then
    local button, x, y = ...
    if button == 1 and self.dragging then
      -- Stop dragging
      self.dragging = false
      return true
    end
  end

  -- Handle child events (reverse order so topmost gets events first)
  for i = #self.children, 1, -1 do
    local child = self.children[i]
    if child:handleEvent(event, ...) then
      return true
    end
  end

  return false
end

function Window:show()
  self:setVisible(true)
  self:requestRedraw()
  self:draw()
end

function Window:hide()
  self:setVisible(false)
end

-- Main GUI manager
local GUIManager = {}
GUIManager.__index = GUIManager

function GUIManager:new()
  local obj = setmetatable({}, self)
  obj.windows = {}
  obj.running = false
  return obj
end

function GUIManager:addWindow(window)
  table.insert(self.windows, window)
  window.parent = self
end

function GUIManager:removeWindow(window)
  for i, w in ipairs(self.windows) do
    if w == window then
      table.remove(self.windows, i)
      window.parent = nil
      return true
    end
  end
  return false
end

function GUIManager:requestRedraw()
  for _, window in ipairs(self.windows) do
    window:requestRedraw()
  end
end

function GUIManager:draw()
  term.clear()
  for _, window in ipairs(self.windows) do
    window:draw()
  end
end

function GUIManager:handleEvents()
  while self.running do
    -- Safely get the pullEvent function with multiple fallbacks
    local pullEventFunc = os.pullEvent
    if type(pullEventFunc) ~= "function" then
      -- Try using rc.pullEvent as fallback if rc is available
      if rc and type(rc.pullEvent) == "function" then
        pullEventFunc = rc.pullEvent
      else
        -- In CC Tweaked, os.pullEventRaw is always available
        pullEventFunc = os.pullEventRaw
        if type(pullEventFunc) ~= "function" then
          error("No valid event pulling function found. Ensure you're running in a CC Tweaked environment.")
        end
      end
    end
    
    -- Get the next event
    local event = {pullEventFunc()}
    local eventName = event[1]
    local handled = false

    -- Handle events for all windows (reverse order so topmost gets events first)
    for i = #self.windows, 1, -1 do
      local window = self.windows[i]
      if window:handleEvent(unpack(event)) then
        handled = true
        break
      end
    end

    -- Redraw if needed
    local needsRedraw = false
    for _, window in ipairs(self.windows) do
      if window.needsRedraw then
        needsRedraw = true
        break
      end
    end

    if needsRedraw then
      self:draw()
    end
  end
end

function GUIManager:start()
  self.running = true
  self:draw()
  self:handleEvents()
end

function GUIManager:stop()
  self.running = false
  term.blink(false)
end

-- Export classes
lgui.UIElement = UIElement
lgui.Label = Label
lgui.Button = Button
lgui.TextField = TextField
lgui.Window = Window
lgui.GUIManager = GUIManager

-- Create a default manager
local defaultManager = GUIManager:new()
lgui.manager = defaultManager

-- Helper functions
function lgui.createWindow(x, y, width, height, title)
  local win = Window:new(x, y, width, height, title)
  defaultManager:addWindow(win)
  return win
end

function lgui.start()
  defaultManager:start()
end

function lgui.stop()
  defaultManager:stop()
end

return lgui