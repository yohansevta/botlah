local UIContext = require(script.Parent.ui_context)
function Enhancement.init()
    local tab = UIContext.window:CreateTab("Enhancement")
    local label = Instance.new("TextLabel")
    label.Text = "Enhancement Status: " .. tostring(Enhancement.enabled and "Enabled" or "Disabled")
    label.Size = UDim2.new(1,0,0,40)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = tab
end
-- enhancement.lua
local Utils = require(script.Parent.utils)
local ResolveRemote = Utils.ResolveRemote

local Enhancement = {
    enabled = false,
    autoActivateAltar = false,
    autoRollEnchant = false,
    maxRolls = 5,
    currentRolls = 0,
    isEnchanting = false,
    lastActivateTime = 0,
    cooldownTime = 2,
    sessionId = 0
}

local activateEnchantingAltarRemote = ResolveRemote("RE/ActivateEnchantingAltar")
local rollEnchantRemote = ResolveRemote("RE/RollEnchant")
local updateEnchantStateRemote = ResolveRemote("RE/UpdateEnchantState")

local function ActivateEnchantingAltar()
    if not Enhancement.enabled or not activateEnchantingAltarRemote then return false end
    local now = tick()
    if now - Enhancement.lastActivateTime < Enhancement.cooldownTime then return false end
    Enhancement.lastActivateTime = now
    local ok, res = pcall(function() activateEnchantingAltarRemote:FireServer(); return true end)
    if ok then Enhancement.isEnchanting = true; Enhancement.currentRolls = 0; Utils.Notify("Enhancement", "Altar activated") return true else Utils.Notify("Enhancement", "Failed to activate: " .. tostring(res)) return false end
end

local function RollEnchant()
    if not Enhancement.enabled or not rollEnchantRemote then return false end
    if not Enhancement.isEnchanting then return false end
    if Enhancement.currentRolls >= Enhancement.maxRolls then return false end
    local ok, res = pcall(function() rollEnchantRemote:FireServer(); return true end)
    if ok then Enhancement.currentRolls = Enhancement.currentRolls + 1; Utils.Notify("Enhancement", string.format("Enchant roll %d/%d", Enhancement.currentRolls, Enhancement.maxRolls)); return true else Utils.Notify("Enhancement", "Roll failed: " .. tostring(res)); return false end
end

local function EnhancementRunner(mySessionId)
    Utils.Notify("Enhancement", "Auto Enhancement started")
    while Enhancement.enabled and Enhancement.sessionId == mySessionId do
        if Enhancement.autoActivateAltar and not Enhancement.isEnchanting then ActivateEnchantingAltar(); task.wait(1) end
        if Enhancement.autoRollEnchant and Enhancement.isEnchanting then
            if Enhancement.currentRolls < Enhancement.maxRolls then RollEnchant(); task.wait(0.5 + math.random() * 0.5) else Enhancement.isEnchanting = false; Enhancement.currentRolls = 0; task.wait(3) end
        end
        task.wait(0.1)
    end
    Utils.Notify("Enhancement", "Auto Enhancement stopped")
end

Enhancement.ActivateEnchantingAltar = ActivateEnchantingAltar
Enhancement.RollEnchant = RollEnchant
Enhancement.EnhancementRunner = EnhancementRunner

return Enhancement
