
-- main.lua
-- Bootstrap sistem modular untuk Botlah AutoFish
-- Memuat semua modules dengan error handling yang baik

print("🚀 Starting Botlah Modular System...")

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

-- Initialize UI Context first
local uiInitialized = false
local UIContext = nil

local function initializeUI()
    local success, result = pcall(function()
        local rayfield = require(script.modules.rayfield)
        local context = require(script.modules.ui_context)
        UIContext = context
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

-- Safe module loader function
local function safeLoadModule(moduleName)
    local success, moduleResult = pcall(function()
        return require(script.modules[moduleName])
    end)
    
    if not success then
        warn("❌ Failed to load module:", moduleName, "Error:", moduleResult)
        return nil, moduleResult
    end
    
    if type(moduleResult) ~= 'table' then
        warn("❌ Module", moduleName, "is not a table")
        return nil, "Module is not a table"
    end
    
    print("✅ Module loaded:", moduleName)
    return moduleResult, nil
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
    
    local success, err = pcall(module.init)
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
        
        local module, loadError = safeLoadModule(moduleName)
        
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
    print("🎮 Check the UI for available features")
else
    warn("⚠️ No modules loaded successfully!")
end

print("=" .. string.rep("=", 50))
