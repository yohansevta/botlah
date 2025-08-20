-- fixed_loader.lua
-- Script yang diperbaiki untuk load script original dengan error handling yang baik

local function safeLoadAndRun(url, fallbackScript)
    print("=== Fixed Loader Starting ===")
    print("Target URL:", url)
    
    -- Step 1: Try to fetch the script
    local fetchSuccess, scriptContent = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not fetchSuccess then
        warn("Failed to fetch script from URL:", scriptContent)
        if fallbackScript then
            print("Trying fallback script...")
            scriptContent = fallbackScript
        else
            return false
        end
    end
    
    if not scriptContent or scriptContent == "" then
        warn("Empty script content received")
        return false
    end
    
    print("Script fetched successfully, length:", #scriptContent)
    
    -- Step 2: Try to compile the script
    local compileSuccess, compiledFunction = pcall(function()
        return loadstring(scriptContent)
    end)
    
    if not compileSuccess or not compiledFunction then
        warn("Failed to compile script:", compiledFunction)
        return false
    end
    
    print("Script compiled successfully")
    
    -- Step 3: Try to execute with comprehensive error handling
    local executeSuccess, executeError = pcall(function()
        -- Set up error handling for the executed script
        local oldError = getgenv and getgenv().error or error
        local errors = {}
        
        if getgenv then
            getgenv().error = function(msg)
                table.insert(errors, tostring(msg))
                warn("Script error caught:", msg)
                -- Don't actually error, just log it
            end
        end
        
        -- Execute the script
        compiledFunction()
        
        -- Restore original error function
        if getgenv then
            getgenv().error = oldError
        end
        
        -- Check if any errors were caught
        if #errors > 0 then
            warn("Script executed with", #errors, "errors:")
            for i, err in ipairs(errors) do
                warn("  Error", i .. ":", err)
            end
        else
            print("Script executed without errors")
        end
    end)
    
    if not executeSuccess then
        warn("Failed to execute script:", executeError)
        
        -- Try to provide more specific error information
        if string.find(tostring(executeError), "attempt to index") then
            warn("Possible cause: Missing game services or objects")
        elseif string.find(tostring(executeError), "attempt to call") then
            warn("Possible cause: Missing functions or methods")
        elseif string.find(tostring(executeError), "timeout") then
            warn("Possible cause: Network timeout or slow connection")
        end
        
        return false
    end
    
    print("=== Fixed Loader Completed Successfully ===")
    return true
end

-- Main execution
local originalUrl = "https://raw.githubusercontent.com/MELLISAEFFENDY/bikin/refs/heads/main/16.lua"
local success = safeLoadAndRun(originalUrl)

if not success then
    warn("Failed to load original script, trying local fallback...")
    
    -- Try loading our improved main script as fallback
    local fallbackUrl = "https://raw.githubusercontent.com/yohansevta/botlah/main/improved_main.lua"
    local fallbackSuccess = safeLoadAndRun(fallbackUrl)
    
    if fallbackSuccess then
        print("Fallback script loaded successfully!")
    else
        warn("All loading attempts failed!")
        
        -- Create a simple error notification
        if game and game:GetService("Players").LocalPlayer then
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            
            spawn(function()
                wait(1)
                if LocalPlayer:FindFirstChild("PlayerGui") then
                    local gui = Instance.new("ScreenGui")
                    gui.Name = "LoadError"
                    gui.Parent = LocalPlayer.PlayerGui
                    
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(0, 400, 0, 150)
                    frame.Position = UDim2.new(0.5, -200, 0.5, -75)
                    frame.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
                    frame.Parent = gui
                    
                    local title = Instance.new("TextLabel")
                    title.Size = UDim2.new(1, 0, 0, 40)
                    title.Text = "Script Loading Failed"
                    title.Font = Enum.Font.GothamBold
                    title.TextSize = 18
                    title.TextColor3 = Color3.fromRGB(255, 100, 100)
                    title.BackgroundTransparency = 1
                    title.Parent = frame
                    
                    local msg = Instance.new("TextLabel")
                    msg.Size = UDim2.new(1, -20, 1, -50)
                    msg.Position = UDim2.new(0, 10, 0, 40)
                    msg.Text = "Failed to load script. Check console for details.\nTry using debug_script.lua first."
                    msg.Font = Enum.Font.Gotham
                    msg.TextSize = 14
                    msg.TextColor3 = Color3.fromRGB(255, 255, 255)
                    msg.BackgroundTransparency = 1
                    msg.TextWrapped = true
                    msg.Parent = frame
                    
                    game:GetService("Debris"):AddItem(gui, 8)
                end
            end)
        end
    end
end
