-- modular_debug.lua
-- Debug script khusus untuk sistem modular

print("🧪 MODULAR SYSTEM DEBUG")
print("=" .. string.rep("=", 40))

-- Test 1: Environment Check
print("\n🔍 Test 1: Environment Check")
local envTests = {
    {"game service", function() return game ~= nil end},
    {"Players service", function() return game:GetService("Players") ~= nil end},
    {"LocalPlayer", function() return game:GetService("Players").LocalPlayer ~= nil end},
    {"PlayerGui", function() return game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") ~= nil end},
    {"HttpGet function", function() return type(game.HttpGet) == "function" end},
    {"loadstring function", function() return type(loadstring) == "function" end}
}

for _, test in ipairs(envTests) do
    local success, result = pcall(test[2])
    if success and result then
        print("✅", test[1])
    else
        print("❌", test[1], "- FAILED")
    end
end

-- Test 2: Module Loading Test
print("\n🔍 Test 2: Module Loading Test")
local function testModuleLoad(moduleName)
    local url = "https://raw.githubusercontent.com/yohansevta/botlah/main/modules/" .. moduleName .. ".lua"
    print("📡 Testing:", moduleName)
    
    local success, result = pcall(function()
        local code = game:HttpGet(url)
        if not code or code == "" then
            error("Empty response")
        end
        print("  📥 Downloaded:", #code, "bytes")
        
        local func = loadstring(code)
        if not func then
            error("Compilation failed")
        end
        print("  ⚙️ Compiled successfully")
        
        local module = func()
        if type(module) ~= "table" then
            error("Module is not a table")
        end
        print("  📦 Module loaded:", type(module))
        
        if type(module.init) == "function" then
            print("  🎯 Init function available")
        else
            print("  ⚠️ No init function")
        end
        
        return true
    end)
    
    if success then
        print("  ✅ Module test PASSED")
    else
        print("  ❌ Module test FAILED:", result)
    end
    
    return success
end

local testModules = {"utils", "rayfield", "dashboard", "fishing"}
local passedModules = 0

for _, mod in ipairs(testModules) do
    if testModuleLoad(mod) then
        passedModules = passedModules + 1
    end
    print() -- Empty line
end

-- Test 3: UI Creation Test
print("🔍 Test 3: UI Creation Test")
local uiSuccess, uiError = pcall(function()
    print("📱 Testing Rayfield UI creation...")
    
    -- Load Rayfield
    local rayfieldUrl = "https://raw.githubusercontent.com/yohansevta/botlah/main/modules/rayfield.lua"
    local rayfieldCode = game:HttpGet(rayfieldUrl)
    local rayfield = loadstring(rayfieldCode)()
    
    print("✅ Rayfield loaded")
    
    -- Create test window
    local window = rayfield:CreateWindow({
        Name = "Debug Test",
        Title = "UI Test Window"
    })
    
    print("✅ Window created")
    
    -- Create test tab
    local tab = window:CreateTab("Test Tab")
    print("✅ Tab created")
    
    -- Test basic UI element
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        local testGui = Instance.new("ScreenGui")
        testGui.Name = "DebugTest"
        testGui.Parent = LocalPlayer.PlayerGui
        
        local testFrame = Instance.new("Frame")
        testFrame.Size = UDim2.new(0, 200, 0, 100)
        testFrame.Position = UDim2.new(0, 20, 0, 20)
        testFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        testFrame.Parent = testGui
        
        local testLabel = Instance.new("TextLabel")
        testLabel.Size = UDim2.new(1, 0, 1, 0)
        testLabel.Text = "✅ UI TEST SUCCESS!"
        testLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        testLabel.BackgroundTransparency = 1
        testLabel.Font = Enum.Font.GothamBold
        testLabel.TextSize = 14
        testLabel.Parent = testFrame
        
        print("✅ Test UI element created")
        
        -- Auto cleanup after 5 seconds
        game:GetService("Debris"):AddItem(testGui, 5)
        
        return true
    else
        error("PlayerGui not available")
    end
end)

if uiSuccess then
    print("✅ UI Test PASSED - UI system working!")
else
    print("❌ UI Test FAILED:", uiError)
end

-- Summary
print("\n" .. "=" .. string.rep("=", 40))
print("📊 DEBUG SUMMARY")
print("=" .. string.rep("=", 40))
print("📦 Modules tested:", passedModules .. "/" .. #testModules)
print("🎨 UI system:", uiSuccess and "WORKING" or "FAILED")

if passedModules == #testModules and uiSuccess then
    print("🎉 ALL TESTS PASSED!")
    print("💡 The modular system should work.")
    print("🔧 Try using main_fixed.lua instead of main.lua")
else
    print("⚠️ Some tests failed.")
    print("💡 Check the specific errors above.")
end

print("\n🎯 Recommended actions:")
if not uiSuccess then
    print("   1. Use quick_loader.lua for simple UI")
    print("   2. Check executor compatibility")
end
if passedModules < #testModules then
    print("   3. Check internet connection")
    print("   4. Verify GitHub repository access")
end

print("=" .. string.rep("=", 40))
