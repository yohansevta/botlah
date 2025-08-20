local UIContext = require(script.Parent.ui_context)
function Movement.init()
    local tab = UIContext.window:CreateTab("Player")
    local label = Instance.new("TextLabel")
    label.Text = "Movement Features"
    label.Size = UDim2.new(1,0,0,40)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = tab
end
-- movement.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Utils = require(script.Parent.utils)

local Movement = {
    floatEnabled = false,
    noClipEnabled = false,
    floatHeight = 16,
    floatConnection = nil,
    noClipConnections = {},
    originalProperties = {},
    spinnerEnabled = false,
    spinnerSpeed = 2,
    spinnerDirection = 1,
    spinnerConnection = nil,
    currentRotation = 0
}

local function EnableFloat()
    if Movement.floatEnabled then return end
    local character = LocalPlayer.Character
    if not character then Utils.Notify("Movement", "Character not found"); return end
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then Utils.Notify("Movement", "Humanoid/Root missing"); return end

    Movement.floatEnabled = true
    Movement.originalProperties.PlatformStand = humanoid.PlatformStand
    Movement.originalProperties.WalkSpeed = humanoid.WalkSpeed

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000,4000,4000)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.Parent = rootPart

    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(0, math.huge, 0)
    bodyPosition.Position = rootPart.Position + Vector3.new(0, Movement.floatHeight, 0)
    bodyPosition.Parent = rootPart

    humanoid.PlatformStand = true

    Movement.floatConnection = RunService.Heartbeat:Connect(function()
        if not Movement.floatEnabled then return end
        local camera = workspace.CurrentCamera
        if not camera then return end
        local moveVector = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0,1,0) end
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * (character:FindFirstChild("Humanoid") and character.Humanoid.WalkSpeed or 16)
            local bv = rootPart:FindFirstChildOfClass("BodyVelocity")
            if bv then bv.Velocity = moveVector end
        else
            local bv = rootPart:FindFirstChildOfClass("BodyVelocity")
            if bv then bv.Velocity = Vector3.new(0,0,0) end
        end
    end)

    Utils.Notify("Movement", "Float enabled")
end

local function DisableFloat()
    if not Movement.floatEnabled then return end
    Movement.floatEnabled = false
    if Movement.floatConnection then Movement.floatConnection:Disconnect(); Movement.floatConnection = nil end
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoid and Movement.originalProperties.PlatformStand ~= nil then humanoid.PlatformStand = Movement.originalProperties.PlatformStand end
        if rootPart then
            for _,child in pairs(rootPart:GetChildren()) do
                if child:IsA("BodyVelocity") or child:IsA("BodyPosition") then child:Destroy() end
            end
        end
    end
    Movement.originalProperties = {}
    Utils.Notify("Movement", "Float disabled")
end

local function EnableNoClip()
    if Movement.noClipEnabled then return end
    Movement.noClipEnabled = true
    local character = LocalPlayer.Character
    if not character then Utils.Notify("Movement", "Character not found"); return end
    local function makeNonCollidable(part)
        if part:IsA("BasePart") then
            Movement.originalProperties[part] = part.CanCollide
            part.CanCollide = false
        end
    end
    for _, part in pairs(character:GetChildren()) do makeNonCollidable(part) end
    Movement.noClipConnections[#Movement.noClipConnections+1] = character.ChildAdded:Connect(function(part) if part:IsA("BasePart") then part.CanCollide = false end end)
    Movement.noClipConnections[#Movement.noClipConnections+1] = RunService.Stepped:Connect(function()
        if not Movement.noClipEnabled then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
        end
    end)
    Utils.Notify("Movement", "NoClip enabled")
end

local function DisableNoClip()
    if not Movement.noClipEnabled then return end
    Movement.noClipEnabled = false
    for _, con in pairs(Movement.noClipConnections) do if con then con:Disconnect() end end
    Movement.noClipConnections = {}
    local character = LocalPlayer.Character
    if character then
        for part, original in pairs(Movement.originalProperties) do
            if part and part.Parent and typeof(original) == "boolean" then part.CanCollide = original end
        end
    end
    Movement.originalProperties = {}
    Utils.Notify("Movement", "NoClip disabled")
end

local function EnableSpinner()
    if Movement.spinnerEnabled then return end
    Movement.spinnerEnabled = true
    Movement.currentRotation = 0
    Movement.spinnerConnection = RunService.Heartbeat:Connect(function(dt)
        if not Movement.spinnerEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local rotationSpeed = Movement.spinnerSpeed * Movement.spinnerDirection
        local rotationIncrement = math.rad(rotationSpeed * 60) * dt
        Movement.currentRotation = Movement.currentRotation + rotationIncrement
        local pos = root.Position
        root.CFrame = CFrame.new(pos) * CFrame.Angles(0, Movement.currentRotation, 0)
    end)
    Utils.Notify("Movement", "Auto Spinner enabled")
end

local function DisableSpinner()
    if not Movement.spinnerEnabled then return end
    Movement.spinnerEnabled = false
    if Movement.spinnerConnection then Movement.spinnerConnection:Disconnect(); Movement.spinnerConnection = nil end
    Movement.currentRotation = 0
    Utils.Notify("Movement", "Auto Spinner disabled")
end

Movement.EnableFloat = EnableFloat
Movement.DisableFloat = DisableFloat
Movement.EnableNoClip = EnableNoClip
Movement.DisableNoClip = DisableNoClip
Movement.EnableSpinner = EnableSpinner
Movement.DisableSpinner = DisableSpinner

return Movement
