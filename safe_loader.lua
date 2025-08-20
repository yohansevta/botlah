-- Alternative loading method with error handling
-- Gunakan script ini sebagai pengganti loadstring

local function safeLoad(url)
    print("Attempting to load from:", url)
    
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        warn("Failed to fetch script:", result)
        return false
    end
    
    if not result or result == "" then
        warn("Empty script received")
        return false
    end
    
    print("Script fetched successfully, length:", #result)
    
    local loadSuccess, loadError = pcall(function()
        local func = loadstring(result)
        if not func then
            error("Failed to compile script")
        end
        func()
    end)
    
    if not loadSuccess then
        warn("Failed to execute script:", loadError)
        return false
    end
    
    print("Script executed successfully!")
    return true
end

-- Try loading the script from our own repository
local url = "https://raw.githubusercontent.com/yohansevta/botlah/main/autofish_original.lua"
safeLoad(url)
