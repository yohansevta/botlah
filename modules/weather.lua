local UIContext = require(script.Parent.ui_context)
function Weather.init()
    local tab = UIContext.window:CreateTab("Weather")
    local label = Instance.new("TextLabel")
    label.Text = "Weather Status: " .. tostring(Weather.enabled and "Enabled" or "Disabled")
    label.Size = UDim2.new(1,0,0,40)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = tab
end
-- weather.lua
local Utils = require(script.Parent.utils)
local ResolveRemote = Utils.ResolveRemote

local Weather = {
    enabled = false,
    autoPurchase = false,
    weatherTypes = {"All","Rain","Storm","Sunny","Cloudy","Fog","Wind"},
    selectedWeather = "All",
    lastPurchaseTime = 0,
    cooldownTime = 5,
    sessionId = 0
}

local purchaseWeatherEventRemote = ResolveRemote("RF/PurchaseWeatherEvent")

local function PurchaseWeatherEvent(weatherType)
    if not Weather.enabled or not purchaseWeatherEventRemote then return false end
    local now = tick(); if now - Weather.lastPurchaseTime < Weather.cooldownTime then return false end
    Weather.lastPurchaseTime = now
    local ok, res = pcall(function() return purchaseWeatherEventRemote:InvokeServer(weatherType) end)
    if ok then Utils.Notify("Weather", "Purchased: " .. weatherType); return true else Utils.Notify("Weather", "Failed purchase: " .. tostring(res)); return false end
end

local function PurchaseAllWeatherEvents()
    if not Weather.enabled or not purchaseWeatherEventRemote then return false end
    local types = {"Rain","Storm","Sunny","Cloudy","Fog","Wind"}
    for i, t in ipairs(types) do
        PurchaseWeatherEvent(t)
        task.wait(Weather.cooldownTime + 0.5)
    end
    return true
end

local function WeatherRunner(mySessionId)
    Utils.Notify("Weather", "Auto Weather started")
    while Weather.enabled and Weather.sessionId == mySessionId do
        if Weather.autoPurchase then
            if Weather.selectedWeather == "All" then PurchaseAllWeatherEvents() task.wait(60) else PurchaseWeatherEvent(Weather.selectedWeather) task.wait(10) end
        end
        task.wait(0.1)
    end
    Utils.Notify("Weather", "Auto Weather stopped")
end

Weather.PurchaseWeatherEvent = PurchaseWeatherEvent
Weather.PurchaseAllWeatherEvents = PurchaseAllWeatherEvents
Weather.WeatherRunner = WeatherRunner

return Weather
