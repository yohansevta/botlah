local UIContext = require(script.Parent.ui_context)
function AutoSell.init()
    local tab = UIContext.window:CreateTab("AutoSell")
    local label = Instance.new("TextLabel")
    label.Text = "AutoSell Status: " .. tostring(AutoSell.enabled and "Enabled" or "Disabled")
    label.Size = UDim2.new(1,0,0,40)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = tab
end
-- autosell.lua
local Utils = require(script.Parent.utils)
local ResolveRemote = Utils.ResolveRemote

local AutoSell = {
    enabled = false,
    threshold = 50,
    isCurrentlySelling = false,
    allowedRarities = { COMMON = true, UNCOMMON = true, RARE = false, EPIC = false, LEGENDARY = false, MYTHIC = false },
    sellCount = { COMMON = 0, UNCOMMON = 0, RARE = 0, EPIC = 0, LEGENDARY = 0, MYTHIC = 0 },
    lastSellTime = 0,
    sellCooldown = 5,
    serverThreshold = 50,
    lastSyncTime = 0,
    syncCooldown = 2,
    isThresholdSynced = false,
    syncRetries = 0,
    maxSyncRetries = 3
}

local function GetTotalFishForSell()
    local total = 0
    for r, c in pairs(AutoSell.sellCount) do if AutoSell.allowedRarities[r] then total = total + c end end
    return total
end

local function ResetSellCounts()
    for r,_ in pairs(AutoSell.sellCount) do AutoSell.sellCount[r] = 0 end
end

local function SyncAutoSellThresholdWithServer(newThreshold)
    local now = tick()
    if now - AutoSell.lastSyncTime < AutoSell.syncCooldown then return false, "sync_cooldown" end
    local updateThresholdRemote = ResolveRemote("RF/UpdateAutoSellThreshold")
    if not updateThresholdRemote then return false, "remote_not_found" end
    AutoSell.lastSyncTime = now
    local ok, res = pcall(function() return updateThresholdRemote:InvokeServer(newThreshold) end)
    if ok then
        AutoSell.serverThreshold = newThreshold
        AutoSell.isThresholdSynced = true
        AutoSell.syncRetries = 0
        Utils.Notify("Auto Sell Sync", "Threshold synced: " .. tostring(newThreshold))
        return true, res
    else
        AutoSell.syncRetries = AutoSell.syncRetries + 1
        AutoSell.isThresholdSynced = false
        Utils.Notify("Auto Sell Sync", "Sync failed: " .. tostring(res))
        if AutoSell.syncRetries < AutoSell.maxSyncRetries then
            task.spawn(function() task.wait(AutoSell.syncCooldown*2); SyncAutoSellThresholdWithServer(newThreshold) end)
        end
        return false, res
    end
end

local function CheckAndAutoSell()
    if not AutoSell.enabled or AutoSell.isCurrentlySelling then return end
    local total = GetTotalFishForSell()
    if total < AutoSell.threshold then return end
    local now = tick()
    if now - AutoSell.lastSellTime < AutoSell.sellCooldown then return end
    AutoSell.isCurrentlySelling = true
    AutoSell.lastSellTime = now
    task.spawn(function()
        -- Try to teleport to seller and invoke sell remote
        local sellRemote = ResolveRemote("RF/SellAllItems")
        if not sellRemote then Utils.Notify("Auto Sell", "Sell remote not found"); AutoSell.isCurrentlySelling = false; return end
        local ok, res = pcall(function() if sellRemote:IsA("RemoteFunction") then return sellRemote:InvokeServer() else sellRemote:FireServer() end end)
        if ok then Utils.Notify("Auto Sell", "Auto sell successful"); ResetSellCounts() else Utils.Notify("Auto Sell", "Auto sell failed: " .. tostring(res)) end
        AutoSell.isCurrentlySelling = false
    end)
end

AutoSell.GetTotalFishForSell = GetTotalFishForSell
AutoSell.ResetSellCounts = ResetSellCounts
AutoSell.CheckAndAutoSell = CheckAndAutoSell
AutoSell.SyncAutoSellThresholdWithServer = SyncAutoSellThresholdWithServer

return AutoSell
