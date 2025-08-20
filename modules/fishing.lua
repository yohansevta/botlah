local UIContext = require(script.Parent.ui_context)
function Fishing.init()
    local tab = UIContext.window:CreateTab("Fishing AI")
    local label = Instance.new("TextLabel")
    label.Text = "Fishing AI Status: Ready"
    label.Size = UDim2.new(1,0,0,40)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = tab
end
-- fishing.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local Utils = require(script.Parent.utils)
local Dashboard = require(script.Parent.dashboard)

local Fishing = {}

local netResolve = Utils.ResolveRemote
local rodRemote = netResolve("RF/ChargeFishingRod")
local miniGameRemote = netResolve("RF/RequestFishingMinigameStarted")
local finishRemote = netResolve("RE/FishingCompleted")
local equipRemote = netResolve("RE/EquipToolFromHotbar")
local fishCaughtRemote = netResolve("RE/FishCaught")

local AnimationMonitor = {isMonitoring = false, currentState = "idle", fishingSuccess = false, animationSequence = {}, lastAnimationTime = 0}

local function GetRealisticTiming(phase)
    local timings = {
        charging = {min = 0.8, max = 1.5}, casting = {min = 0.2, max = 0.4}, waiting = {min = 2.0, max = 4.0}, reeling = {min = 1.0, max = 2.5}, holding = {min = 0.5, max = 1.0}
    }
    local t = timings[phase] or {min = 0.5, max = 1.0}
    return t.min + math.random() * (t.max - t.min)
end

local function MonitorCharacterAnimations()
    if not Players.LocalPlayer.Character or not Players.LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local humanoid = Players.LocalPlayer.Character.Humanoid
    humanoid.AnimationPlayed:Connect(function(animationTrack)
        local animName = animationTrack.Animation and animationTrack.Animation.Name or ""
        local currentTime = tick()
        if string.find(animName, "Fish") or string.find(animName, "Rod") or string.find(animName, "Reel") then
            table.insert(AnimationMonitor.animationSequence, {name = animName, timestamp = currentTime, duration = currentTime - AnimationMonitor.lastAnimationTime})
            AnimationMonitor.lastAnimationTime = currentTime
            if string.find(animName, "Caught") then AnimationMonitor.fishingSuccess = true end
        end
    end)
end

local function DoSmartCycle(config)
    AnimationMonitor.fishingSuccess = false
    AnimationMonitor.currentState = "starting"
    Utils.FixRodOrientation()
    if equipRemote then pcall(function() equipRemote:FireServer(1) end); task.wait(GetRealisticTiming("charging")) end
    AnimationMonitor.currentState = "charging"
    Utils.FixRodOrientation()
    local usePerfect = math.random(1,100) <= (config and config.safeModeChance or 70)
    local timestamp = usePerfect and workspace:GetServerTimeNow() or workspace:GetServerTimeNow() + math.random()*0.5
    if rodRemote and rodRemote:IsA("RemoteFunction") then pcall(function() rodRemote:InvokeServer(timestamp) end) end
    local chargeStart = tick(); local chargeDuration = GetRealisticTiming("charging")
    while tick() - chargeStart < chargeDuration do Utils.FixRodOrientation(); task.wait(0.02) end
    AnimationMonitor.currentState = "casting"
    local x = usePerfect and -1.238 or (math.random(-1000,1000)/1000); local y = usePerfect and 0.969 or (math.random(0,1000)/1000)
    if miniGameRemote and miniGameRemote:IsA("RemoteFunction") then pcall(function() miniGameRemote:InvokeServer(x,y) end) end
    task.wait(GetRealisticTiming("casting"))
    AnimationMonitor.currentState = "waiting"
    task.wait(GetRealisticTiming("waiting"))
    AnimationMonitor.currentState = "completing"; Utils.FixRodOrientation()
    if finishRemote then pcall(function() finishRemote:FireServer() end) end
    task.wait(GetRealisticTiming("reeling"))
    if not AnimationMonitor.fishingSuccess and not fishCaughtRemote then
        local fishByLocation = { ["Coral Reefs"] = {"Hawks Turtle","Blue Lobster"}, ["Stingray Shores"] = {"Dotted Stingray","Yellowfin Tuna"}, ["Ocean"] = {"Hammerhead Shark","Manta Ray"} }
        local currentLocation = Dashboard.DetectCurrentLocation and Dashboard.DetectCurrentLocation() or "Ocean"
        local list = fishByLocation[currentLocation] or fishByLocation["Ocean"]
        local pick = list[math.random(1,#list)]
        print("[Smart Cycle] Simulated catch:", pick, "at", currentLocation)
    end
    AnimationMonitor.currentState = "idle"
end

Fishing.DoSmartCycle = DoSmartCycle
Fishing.MonitorCharacterAnimations = MonitorCharacterAnimations

return Fishing
