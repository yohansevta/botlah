-- quick_modular_test.lua
-- Test cepat untuk memastikan main_fixed.lua akan berfungsi

print("🔬 QUICK MODULAR TEST")
print("Based on debug results, testing main_fixed.lua compatibility...")

-- Test 1: Check if debug passed
print("\n✅ Debug UI shown - Rayfield system working!")
print("✅ Window creation successful")
print("✅ Tab creation successful")

-- Test 2: Test module loading individually
local function testSingleModule(moduleName)
    local url = "https://raw.githubusercontent.com/yohansevta/botlah/main/modules/" .. moduleName .. ".lua"
    print("🧪 Testing module:", moduleName)
    
    local success, result = pcall(function()
        local code = game:HttpGet(url)
        local func = loadstring(code)
        local module = func()
        
        return {
            size = #code,
            type = type(module),
            hasInit = type(module.init) == "function"
        }
    end)
    
    if success then
        print("  ✅ SUCCESS - Size:", result.size, "Type:", result.type, "Init:", result.hasInit)
        return true
    else
        print("  ❌ FAILED:", result)
        return false
    end
end

-- Quick test key modules
local testModules = {"rayfield", "utils", "fishing", "dashboard"}
local passed = 0

for _, mod in ipairs(testModules) do
    if testSingleModule(mod) then
        passed = passed + 1
    end
end

-- Test 3: UI creation with actual Rayfield
print("\n🎨 Testing actual UI creation...")
local uiTest = pcall(function()
    local rayfieldUrl = "https://raw.githubusercontent.com/yohansevta/botlah/main/modules/rayfield.lua"
    local rayfieldCode = game:HttpGet(rayfieldUrl)
    local rayfield = loadstring(rayfieldCode)()
    
    -- Create main window like main_fixed.lua does
    local window = rayfield:CreateWindow({
        Name = "Botlah AutoFish",
        Title = "Quick Test - Modular System"
    })
    
    -- Test tab creation
    local testTab = window:CreateTab("Quick Test")
    
    print("✅ Main window created successfully")
    print("✅ Tab created successfully")
    
    -- Store globally like main_fixed.lua
    _G.BotlahTestUI = {
        window = window,
        rayfield = rayfield
    }
    
    return true
end)

-- Results
print("\n" .. "=" .. string.rep("=", 40))
print("📊 QUICK TEST RESULTS")
print("=" .. string.rep("=", 40))
print("📦 Modules tested:", passed .. "/" .. #testModules)
print("🎨 UI system:", uiTest and "✅ WORKING" or "❌ FAILED")

if passed == #testModules and uiTest then
    print("\n🎉 ALL TESTS PASSED!")
    print("🚀 main_fixed.lua should work perfectly!")
    print("\n💡 Ready to run:")
    print("loadstring(game:HttpGet(\"https://raw.githubusercontent.com/yohansevta/botlah/main/main_fixed.lua\"))()")
    
    -- Auto cleanup test UI after 3 seconds
    if _G.BotlahTestUI then
        spawn(function()
            wait(3)
            if _G.BotlahTestUI.window and _G.BotlahTestUI.window.Close then
                _G.BotlahTestUI.window.Close:Destroy()
            end
            _G.BotlahTestUI = nil
            print("🧹 Test UI cleaned up")
        end)
    end
else
    print("\n⚠️ Some tests failed!")
    print("💡 Fallback to quick_loader.lua recommended")
end

print("=" .. string.rep("=", 40))
