-- ui_context.lua
-- Singleton context untuk Rayfield window utama
local Rayfield = require(script.Parent.rayfield)
local context = {}

if not context.window then
    context.window = Rayfield:CreateWindow({
        Name = "Spinner_xxx AutoFish",
        Title = "Smart AI Fishing Configuration"
    })
end

return context
