-- Debug script untuk troubleshooting
-- Jalankan script ini terlebih dahulu untuk mengecek error

local success, err = pcall(function()
    print("Starting debug script...")
    
    -- Test basic services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    
    print("✓ All services loaded successfully")
    
    -- Test LocalPlayer
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        error("LocalPlayer not found!")
    end
    print("✓ LocalPlayer found:", LocalPlayer.Name)
    
    -- Test PlayerGui
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    if not PlayerGui then
        error("PlayerGui not found!")
    end
    print("✓ PlayerGui found")
    
    -- Test creating a simple UI
    local testGui = Instance.new("ScreenGui")
    testGui.Name = "TestGui"
    testGui.Parent = PlayerGui
    
    local testFrame = Instance.new("Frame")
    testFrame.Size = UDim2.new(0, 200, 0, 100)
    testFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
    testFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    testFrame.Parent = testGui
    
    local testLabel = Instance.new("TextLabel")
    testLabel.Size = UDim2.new(1, 0, 1, 0)
    testLabel.Text = "DEBUG UI WORKING!"
    testLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    testLabel.BackgroundTransparency = 1
    testLabel.Font = Enum.Font.GothamBold
    testLabel.TextSize = 14
    testLabel.Parent = testFrame
    
    print("✓ Test UI created successfully")
    
    -- Wait and cleanup
    wait(3)
    testGui:Destroy()
    print("✓ Test UI cleaned up")
    
    print("Debug completed successfully!")
    
end)

if not success then
    warn("Debug script failed:", err)
else
    print("✓ Debug script completed without errors")
end
