-- quick_loader.lua
-- Simple loader for our local autofish script

print("🎣 Loading Botlah AutoFish Script...")
print("📍 Source: Your own GitHub repository")

local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/yohansevta/botlah/main/autofish_original.lua"))()
end)

if success then
    print("✅ Botlah AutoFish loaded successfully!")
    print("🚀 UI should appear shortly...")
else
    warn("❌ Failed to load script:", result)
    print("🔧 Try using fixed_loader.lua or safe_loader.lua instead")
end
