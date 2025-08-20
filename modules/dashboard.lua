local UIContext = require(script.Parent.ui_context)
function Dashboard.init()
    local tab = UIContext.window:CreateTab("Dashboard")
    local label = Instance.new("TextLabel")
    label.Text = "Welcome to Dashboard!"
    label.Size = UDim2.new(1,0,0,40)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.Parent = tab
end
-- dashboard.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Utils = require(script.Parent.utils)

local Dashboard = {
    fishCaught = {},
    rareFishCaught = {},
    locationStats = {},
    sessionStats = { startTime = tick(), fishCount = 0, rareCount = 0, totalValue = 0, currentLocation = "Unknown" },
    heatmap = {},
    optimalTimes = {}
}

local FishRarity = {
    MYTHIC = {"Hawks Turtle","Dotted Stingray","Hammerhead Shark","Manta Ray","Abyss Seahorse","Blueflame Ray","Prismy Seahorse","Loggerhead Turtle"},
    LEGENDARY = {"Blue Lobster","Greenbee Grouper","Starjam Tang","Yellowfin Tuna","Chrome Tuna","Magic Tang","Enchanted Angelfish","Lavafin Tuna","Lobster","Bumblebee Grouper"},
    EPIC = {"Domino Damsel","Panther Grouper","Unicorn Tang","Dorhey Tang","Moorish Idol","Cow Clownfish","Astra Damsel","Firecoal Damsel","Longnose Butterfly","Sushi Cardinal"},
    RARE = {"Scissortail Dartfish","White Clownfish","Darwin Clownfish","Korean Angelfish","Candy Butterfly","Jewel Tang","Charmed Tang","Kau Cardinal","Fire Goby"},
    UNCOMMON = {"Maze Angelfish","Tricolore Butterfly","Flame Angelfish","Yello Damselfish","Vintage Damsel","Coal Tang","Magma Goby","Banded Butterfly","Shrimp Goby"},
    COMMON = {"Orangy Goby","Specked Butterfly","Corazon Damse","Copperband Butterfly","Strawberry Dotty","Azure Damsel","Clownfish"}
}

local LocationMap = {
    ["Kohana Volcano"] = {x = -594, z = 149},
    ["Crater Island"] = {x = 1010, z = 5078},
    ["Kohana"] = {x = -650, z = 711},
    ["Lost Isle"] = {x = -3618, z = -1317},
    ["Stingray Shores"] = {x = 45, z = 2987},
    ["Esoteric Depths"] = {x = 1944, z = 1371},
    ["Weather Machine"] = {x = -1488, z = 1876},
    ["Tropical Grove"] = {x = -2095, z = 3718},
    ["Coral Reefs"] = {x = -3023, z = 2195}
}

local function GetFishRarity(fishName)
    for rarity, fishList in pairs(FishRarity) do
        for _, fish in pairs(fishList) do
            if string.find(string.lower(fishName), string.lower(fish)) then
                return rarity
            end
        end
    end
    return "COMMON"
end

local function LogFishCatch(fishName, location)
    local currentTime = tick()
    local rarity = GetFishRarity(fishName)
    table.insert(Dashboard.fishCaught, { name = fishName, rarity = rarity, location = location or Dashboard.sessionStats.currentLocation, timestamp = currentTime, hour = tonumber(os.date("%H", currentTime)) })
    if rarity ~= "COMMON" then
        table.insert(Dashboard.rareFishCaught, { name = fishName, rarity = rarity, location = location or Dashboard.sessionStats.currentLocation, timestamp = currentTime })
        Dashboard.sessionStats.rareCount = Dashboard.sessionStats.rareCount + 1
    end
    local loc = location or Dashboard.sessionStats.currentLocation
    if not Dashboard.locationStats[loc] then Dashboard.locationStats[loc] = {total = 0, rare = 0, common = 0, lastCatch = 0} end
    Dashboard.locationStats[loc].total = Dashboard.locationStats[loc].total + 1
    Dashboard.locationStats[loc].lastCatch = currentTime
    if rarity ~= "COMMON" then Dashboard.locationStats[loc].rare = Dashboard.locationStats[loc].rare + 1 else Dashboard.locationStats[loc].common = Dashboard.locationStats[loc].common + 1 end
    Dashboard.sessionStats.fishCount = Dashboard.sessionStats.fishCount + 1
    if LocationMap[loc] then
        local key = loc
        if not Dashboard.heatmap[key] then Dashboard.heatmap[key] = {count = 0, rare = 0, efficiency = 0} end
        Dashboard.heatmap[key].count = Dashboard.heatmap[key].count + 1
        if rarity ~= "COMMON" then Dashboard.heatmap[key].rare = Dashboard.heatmap[key].rare + 1 end
        Dashboard.heatmap[key].efficiency = Dashboard.heatmap[key].rare / Dashboard.heatmap[key].count
    end
    local hour = tonumber(os.date("%H", currentTime))
    if not Dashboard.optimalTimes[hour] then Dashboard.optimalTimes[hour] = {total = 0, rare = 0} end
    Dashboard.optimalTimes[hour].total = Dashboard.optimalTimes[hour].total + 1
    if rarity ~= "COMMON" then Dashboard.optimalTimes[hour].rare = Dashboard.optimalTimes[hour].rare + 1 end
end

local function DetectCurrentLocation()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return "Unknown" end
    local pos = LocalPlayer.Character.HumanoidRootPart.Position
    if pos.Z > 4500 then
        return "Crater Island"
    elseif pos.Z > 2500 then
        return "Stingray Shores"
    elseif pos.Z > 1500 then
        return "Esoteric Depths"
    elseif pos.Z > 700 then
        return "Kohana"
    elseif pos.Z > 3000 and pos.X < -2000 then
        return "Tropical Grove"
    elseif pos.Z > 1800 and pos.X < -3000 then
        return "Coral Reefs"
    elseif pos.X < -3500 then
        return "Lost Isle"
    elseif pos.X < -1400 and pos.Z > 1500 then
        return "Weather Machine"
    elseif pos.Z < 500 and pos.X < -500 then
        return "Kohana Volcano"
    else
        return "Unknown Area"
    end
end

local function LocationTracker()
    while true do
        local newLocation = DetectCurrentLocation()
        if newLocation ~= Dashboard.sessionStats.currentLocation then
            Dashboard.sessionStats.currentLocation = newLocation
            Utils.Notify("Dashboard", "Location changed to: " .. newLocation)
        end
        task.wait(3)
    end
end

-- Expose
Dashboard.LogFishCatch = LogFishCatch
Dashboard.DetectCurrentLocation = DetectCurrentLocation
Dashboard.LocationTracker = LocationTracker
Dashboard.GetFishRarity = GetFishRarity

return Dashboard
