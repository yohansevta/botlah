-- ui_complete_test.lua
-- Test lengkap untuk memastikan UI dengan tab dan konten berfungsi

print("🧪 COMPLETE UI TEST - Testing tabs and content")

local function createTestUI()
    print("🎨 Creating test UI with tabs and content...")
    
    local success, result = pcall(function()
        -- Load Rayfield
        local rayfieldUrl = "https://raw.githubusercontent.com/yohansevta/botlah/main/modules/rayfield.lua"
        local rayfieldCode = game:HttpGet(rayfieldUrl)
        local rayfield = loadstring(rayfieldCode)()
        
        -- Create window
        local window = rayfield:CreateWindow({
            Name = "UI Complete Test",
            Title = "Testing Tabs & Content"
        })
        
        print("✅ Window created")
        
        -- Create multiple tabs with content
        local tabs = {}
        local tabNames = {"Dashboard", "Fishing", "Settings", "About"}
        
        for i, tabName in ipairs(tabNames) do
            local tabFrame, tabButton = window:CreateTab(tabName)
            tabs[tabName] = {frame = tabFrame, button = tabButton}
            
            print("📋 Created tab:", tabName)
            
            -- Add content to each tab
            local header = Instance.new("TextLabel")
            header.Size = UDim2.new(1, -20, 0, 40)
            header.Position = UDim2.new(0, 10, 0, 10)
            header.Text = "🎯 " .. tabName .. " Tab"
            header.TextColor3 = Color3.fromRGB(255, 255, 255)
            header.BackgroundTransparency = 1
            header.Font = Enum.Font.GothamBold
            header.TextSize = 18
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.Parent = tabFrame
            
            local description = Instance.new("TextLabel")
            description.Size = UDim2.new(1, -20, 0, 60)
            description.Position = UDim2.new(0, 10, 0, 50)
            description.Text = "This is the " .. tabName .. " section.\nContent and controls would go here.\nTab switching should work properly."
            description.TextColor3 = Color3.fromRGB(200, 200, 200)
            description.BackgroundTransparency = 1
            description.Font = Enum.Font.Gotham
            description.TextSize = 14
            description.TextWrapped = true
            description.TextXAlignment = Enum.TextXAlignment.Left
            description.TextYAlignment = Enum.TextYAlignment.Top
            description.Parent = tabFrame
            
            -- Add test button
            local testButton = Instance.new("TextButton")
            testButton.Size = UDim2.new(0, 150, 0, 30)
            testButton.Position = UDim2.new(0, 10, 0, 120)
            testButton.Text = "Test " .. tabName
            testButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            testButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            testButton.BorderSizePixel = 0
            testButton.Font = Enum.Font.GothamSemibold
            testButton.TextSize = 14
            testButton.Parent = tabFrame
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 5)
            buttonCorner.Parent = testButton
            
            testButton.MouseButton1Click:Connect(function()
                print("🔘 Button clicked in", tabName, "tab")
                testButton.Text = "✅ Clicked!"
                wait(1)
                testButton.Text = "Test " .. tabName
            end)
            
            -- Add status indicator
            local status = Instance.new("Frame")
            status.Size = UDim2.new(0, 10, 0, 10)
            status.Position = UDim2.new(0, 170, 0, 125)
            status.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
            status.BorderSizePixel = 0
            status.Parent = tabFrame
            
            local statusCorner = Instance.new("UICorner")
            statusCorner.CornerRadius = UDim.new(0, 5)
            statusCorner.Parent = status
            
            print("  ✅ Added content to", tabName)
            
            -- Make first tab visible by default
            if i == 1 then
                tabFrame.Visible = true
                print("  🎯 Set", tabName, "as default visible")
            else
                tabFrame.Visible = false
            end
        end
        
        -- Test tab switching
        print("🔄 Setting up tab switching...")
        for tabName, tabData in pairs(tabs) do
            tabData.button.MouseButton1Click:Connect(function()
                print("📋 Switching to tab:", tabName)
                -- Hide all tabs
                for _, otherTab in pairs(tabs) do
                    otherTab.frame.Visible = false
                end
                -- Show selected tab
                tabData.frame.Visible = true
                print("  ✅ Tab switched to", tabName)
            end)
        end
        
        return {window = window, tabs = tabs, rayfield = rayfield}
    end)
    
    if success then
        print("✅ Complete UI test created successfully!")
        print("🎮 You should see:")
        print("  📱 Window: 'UI Complete Test'")
        print("  📋 Tabs: Dashboard, Fishing, Settings, About")
        print("  🎯 Content in each tab with buttons")
        print("  🔄 Tab switching functionality")
        return result
    else
        print("❌ UI test failed:", result)
        return nil
    end
end

-- Execute test
local ui = createTestUI()

if ui then
    print("\n🎉 UI COMPLETE TEST SUCCESS!")
    print("Try clicking different tabs and buttons")
    
    -- Store globally for inspection
    _G.TestUI = ui
    
    -- Auto cleanup after 30 seconds
    spawn(function()
        wait(30)
        if _G.TestUI and _G.TestUI.window and _G.TestUI.window.Close then
            _G.TestUI.window:Destroy()
        end
        _G.TestUI = nil
        print("🧹 Test UI cleaned up")
    end)
else
    print("❌ UI test failed completely")
end
