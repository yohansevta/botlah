-- improved_main.lua
-- Versi yang diperbaiki dari main.lua dengan error handling yang lebih baik

local function safeRequire(moduleName)
    local success, result = pcall(function()
        return require(moduleName)
    end)
    
    if success then
        print("✓ Successfully loaded module:", moduleName)
        return result
    else
        warn("✗ Failed to load module:", moduleName, "Error:", result)
        return nil
    end
end

local function safeInit(module, moduleName)
    if not module then
        warn("Module", moduleName, "is nil, skipping initialization")
        return false
    end
    
    if type(module) ~= 'table' then
        warn("Module", moduleName, "is not a table, skipping initialization")
        return false
    end
    
    if type(module.init) ~= 'function' then
        warn("Module", moduleName, "does not have init function, skipping initialization")
        return false
    end
    
    local success, err = pcall(module.init)
    if success then
        print("✓ Successfully initialized module:", moduleName)
        return true
    else
        warn("✗ Failed to initialize module:", moduleName, "Error:", err)
        return false
    end
end

-- Check if we're running in the right environment
if not game or not game:GetService then
    error("This script must be run in Roblox environment")
end

-- Check required services
local requiredServices = {
    "Players",
    "RunService", 
    "UserInputService",
    "ReplicatedStorage"
}

for _, serviceName in ipairs(requiredServices) do
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    
    if not success then
        error("Failed to get service: " .. serviceName)
    end
    
    print("✓ Service available:", serviceName)
end

print("Starting bootstrap process...")

-- Bootstrap: Load all modules with improved error handling
local modules = {
    'autosell',
    'dashboard', 
    'enhancement',
    'fishing',
    'movement',
    'utils',
    'weather',
}

local loadedModules = {}
local failedModules = {}

for _, mod in ipairs(modules) do
    print("Attempting to load module:", mod)
    
    local loaded = safeRequire('modules.' .. mod)
    
    if loaded then
        local initSuccess = safeInit(loaded, mod)
        if initSuccess then
            loadedModules[#loadedModules + 1] = mod
        else
            failedModules[#failedModules + 1] = mod
        end
    else
        failedModules[#failedModules + 1] = mod
    end
end

print("===== Bootstrap Summary =====")
print("Successfully loaded modules:", #loadedModules)
for _, mod in ipairs(loadedModules) do
    print("  ✓", mod)
end

if #failedModules > 0 then
    print("Failed modules:", #failedModules)
    for _, mod in ipairs(failedModules) do
        print("  ✗", mod)
    end
end

print("Bootstrap completed. Total modules loaded:", #loadedModules, "out of", #modules)

-- Create a simple status UI to show what loaded
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
    local function createStatusGui()
        local success, err = pcall(function()
            local gui = Instance.new("ScreenGui")
            gui.Name = "BootstrapStatus"
            gui.ResetOnSpawn = false
            gui.Parent = LocalPlayer.PlayerGui
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 300, 0, 200)
            frame.Position = UDim2.new(1, -320, 0, 20)
            frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            frame.BorderSizePixel = 0
            frame.Parent = gui
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = frame
            
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, 0, 0, 30)
            title.Text = "Botlah Status"
            title.Font = Enum.Font.GothamBold
            title.TextSize = 16
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.BackgroundTransparency = 1
            title.Parent = frame
            
            local statusText = "Loaded: " .. #loadedModules .. "/" .. #modules .. " modules\n"
            for _, mod in ipairs(loadedModules) do
                statusText = statusText .. "✓ " .. mod .. "\n"
            end
            for _, mod in ipairs(failedModules) do
                statusText = statusText .. "✗ " .. mod .. "\n"
            end
            
            local status = Instance.new("TextLabel")
            status.Size = UDim2.new(1, -10, 1, -35)
            status.Position = UDim2.new(0, 5, 0, 30)
            status.Text = statusText
            status.Font = Enum.Font.Gotham
            status.TextSize = 12
            status.TextColor3 = Color3.fromRGB(200, 200, 200)
            status.BackgroundTransparency = 1
            status.TextXAlignment = Enum.TextXAlignment.Left
            status.TextYAlignment = Enum.TextYAlignment.Top
            status.TextWrapped = true
            status.Parent = frame
            
            -- Auto-hide after 10 seconds
            game:GetService("Debris"):AddItem(gui, 10)
        end)
        
        if not success then
            warn("Failed to create status GUI:", err)
        end
    end
    
    createStatusGui()
end
