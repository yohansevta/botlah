-- utils.lua
-- Small utility module for notifications, remote resolution, and simple helpers
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local Utils = {}

function Utils.Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 4})
    end)
    warn("[modern_autofish] ", title, text)
end

function Utils.FindNet()
    local ok, net = pcall(function()
        local packages = ReplicatedStorage:FindFirstChild("Packages")
        if not packages then return nil end
        local idx = packages:FindFirstChild("_Index")
        if not idx then return nil end
        local sleit = idx:FindFirstChild("sleitnick_net@0.2.0")
        if not sleit then return nil end
        return sleit:FindFirstChild("net")
    end)
    return ok and net or nil
end

function Utils.ResolveRemote(name)
    local net = Utils.FindNet()
    if not net then return nil end
    local ok, rem = pcall(function() return net:FindFirstChild(name) end)
    return ok and rem or nil
end

function Utils.SafeInvoke(remote, ...)
    if not remote then return false, "nil_remote" end
    if remote:IsA("RemoteFunction") then
        return pcall(function(...) return remote:InvokeServer(...) end, ...)
    else
        return pcall(function(...) remote:FireServer(...) return true end, ...)
    end
end

-- Rod orientation fix helper (lightweight)
local PlayersService = Players
local LocalPlayer = PlayersService.LocalPlayer

Utils.RodFix = {enabled = true, lastFix = 0}
function Utils.FixRodOrientation()
    if not Utils.RodFix.enabled then return end
    if not LocalPlayer or not LocalPlayer.Character then return end
    local now = tick()
    if now - Utils.RodFix.lastFix < 0.05 then return end
    Utils.RodFix.lastFix = now

    local character = LocalPlayer.Character
    local equippedTool = character:FindFirstChildOfClass("Tool")
    if not equippedTool then return end
    local isRod = equippedTool.Name:lower():find("rod") or equippedTool:FindFirstChild("Rod") or equippedTool:FindFirstChild("Handle")
    if not isRod then return end

    local rightArm = character:FindFirstChild("Right Arm")
    if rightArm then
        local rightGrip = rightArm:FindFirstChild("RightGrip")
        if rightGrip and rightGrip:IsA("Motor6D") then
            rightGrip.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            rightGrip.C1 = CFrame.new(0, 0, 0)
            return
        end
    end

    local toolGrip = equippedTool:FindFirstChild("Grip")
    if toolGrip and toolGrip:IsA("CFrameValue") then
        toolGrip.Value = CFrame.new(0, -1.5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
        return
    end

    if not toolGrip then
        toolGrip = Instance.new("CFrameValue")
        toolGrip.Name = "Grip"
        toolGrip.Value = CFrame.new(0, -1.5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
        toolGrip.Parent = equippedTool
    end
end

return Utils
