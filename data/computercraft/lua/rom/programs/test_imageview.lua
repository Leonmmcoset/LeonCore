-- test_imageview.lua: Test the imageview command
local shell = require("shell")

print("=== Image Viewer Test ===")
print("Note: This program uses the paintutils library for image handling,")
print("      not an 'image' API. CC Tweaked doesn't have an 'image' API.")
print("")
print("Testing imageview command with a sample image...")
print("This will attempt to load a test image from the internet.")
print("Press Ctrl+T to stop the test if needed.")
print("\nNote: You need an internet connection for this test.")
print("\n3...")
os.sleep(1)
print("2...")
os.sleep(1)
print("1...")
os.sleep(1)

-- Use a sample image URL that's known to work
local testImageUrl = "http://time.syiban.com/img/xcx.png"

-- Execute the imageview command with the test URL
local success, errorMsg = shell.execute("imageview " .. testImageUrl)

if success then
  print("\nTest completed successfully.")
  print("The image viewer is working correctly with paintutils.")
else
  print("\nTest failed: " .. errorMsg)
  print("Make sure you have internet access and the URL is valid.")
end

print("\nTest finished. Press any key to return.")
os.pullEvent("key")