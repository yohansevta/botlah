-- main_fixed.lua
-- Bootstrap sistem modular untuk Botlah AutoFish (Fixed untuk loadstring)
-- Memuat semua modules dengan error handling yang baik

print("🚀 Starting Botlah Modular System (Fixed)...")

-- Check if we're in the right environment
if not game or not game:GetService then
    error("❌ This script must be run in Roblox environment")
end

-- Verify required services are available
local requiredServices = {
    "Players", "RunService", "UserInputService", "ReplicatedStorage"
}

for _, serviceName in ipairs(requiredServices) do
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    
    if not success then
        error("❌ Failed to get service: " .. serviceName)
    end
end

print("✅ Environment check passed")

-- Function to load module from GitHub
local function loadModuleFromGitHub(moduleName)
    local url = "https://raw.githubusercontent.com/yohansevta/botlah/main/modules/" .. moduleName .. ".lua"
    print("📥 Loading module from GitHub:", moduleName)
    
    local success, result = pcall(function()
        local moduleCode = game:HttpGet(url)
        if not moduleCode or moduleCode == "" then
            error("Empty module code")
        end
        
        local loadFunc = loadstring(moduleCode)
        if not loadFunc then
            error("Failed to compile module")
        end
        
        return loadFunc()
    end)
    
    if success then
        print("✅ Module loaded:", moduleName)
        return result
    else
        warn("❌ Failed to load module:", moduleName, "Error:", result)
        return nil
    end
end

-- Initialize UI Context first
local uiInitialized = false
local UIContext = nil

local function initializeUI()
    print("📱 Initializing UI System...")
    
    local success, result = pcall(function()
        -- Load Rayfield UI library
        local rayfield = loadModuleFromGitHub("rayfield")
        if not rayfield then
            error("Failed to load Rayfield UI library")
        end
        
        -- Create main window
        local window = rayfield:CreateWindow({
            Name = "Botlah AutoFish",
            Title = "Modular Fishing System v2.0"
        })
        
        if not window then
            error("Failed to create UI window")
        end
        
        -- Store UI context globally
        _G.BotlahUI = {
            window = window,
            rayfield = rayfield,
            tabs = {}
        }
        
        print("✅ UI Window created successfully")
        return true
    end)
    
    if success then
        print("✅ UI System initialized")
        uiInitialized = true
        return true
    else
        warn("❌ Failed to initialize UI:", result)
        return false
    end
end

-- Safe module initialization function  
local function safeInitModule(module, moduleName)
    if not module then
        warn("❌ Cannot init nil module:", moduleName)
        return false
    end
    
    if type(module.init) ~= 'function' then
        warn("⚠️ Module", moduleName, "has no init function, skipping")
        return true -- Not an error, just no init needed
    end
    
    local success, err = pcall(function()
        -- Create tab for module if UI is available
        if _G.BotlahUI and _G.BotlahUI.window then
            local tab = _G.BotlahUI.window:CreateTab(moduleName:gsub("^%l", string.upper))
            _G.BotlahUI.tabs[moduleName] = tab
            print("📋 Created tab for module:", moduleName)
        end
        
        module.init()
    end)
    
    if success then
        print("✅ Module initialized:", moduleName)
        return true
    else
        warn("❌ Failed to initialize module:", moduleName, "Error:", err)
        return false
    end
end

-- Bootstrap: Load all modules
local modules = {
    'utils',      -- Load utils first (other modules depend on it)
    'dashboard',
    'fishing',
    'autosell', 
    'enhancement',
    'movement',
    'weather',
}

local loadedModules = {}
local failedModules = {}

-- Initialize UI first
if initializeUI() then
    print("📊 Loading modules...")
    
    -- Load and initialize each module
    for _, moduleName in ipairs(modules) do
        print("📥 Loading module:", moduleName)
        
        local module = loadModuleFromGitHub(moduleName)
        
        if module then
            local initSuccess = safeInitModule(module, moduleName)
            if initSuccess then
                loadedModules[#loadedModules + 1] = moduleName
                -- Store module reference for later use
                _G["Botlah_" .. moduleName] = module
            else
                failedModules[#failedModules + 1] = moduleName
            end
        else
            failedModules[#failedModules + 1] = moduleName
        end
        
        -- Small delay to prevent rate limiting
        wait(0.1)
    end
else
    warn("❌ Failed to initialize UI system, aborting module loading")
end

-- Summary report
print("=" .. string.rep("=", 50))
print("📊 BOTLAH MODULAR SYSTEM - BOOTSTRAP SUMMARY")
print("=" .. string.rep("=", 50))
print("✅ Successfully loaded modules:", #loadedModules)
for _, mod in ipairs(loadedModules) do
    print("   ✓", mod)
end

if #failedModules > 0 then
    print("❌ Failed modules:", #failedModules)
    for _, mod in ipairs(failedModules) do
        print("   ✗", mod)
    end
end

print("📈 System Status:", #loadedModules .. "/" .. #modules, "modules loaded")

if #loadedModules > 0 then
    print("🎉 Botlah Modular System ready!")
    if _G.BotlahUI then
        print("🎮 UI should be visible now - check for the 'Botlah AutoFish' window")
    else
        warn("⚠️ UI system not available")
    end
else
    warn("⚠️ No modules loaded successfully!")
end

print("=" .. string.rep("=", 50))

-- Auto-show first tab if UI is available
if _G.BotlahUI and _G.BotlahUI.tabs.utils then
    spawn(function()
        wait(1)
        print("🎯 Auto-activating first module tab...")
    end)
end
