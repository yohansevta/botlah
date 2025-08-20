-- rayfield.lua
-- Minimal Rayfield-like UI loader for deployment. Provides a simple API
-- Usage: local Rayfield = require(path_to_rayfield); local ui = Rayfield:CreateWindow(opts)

local Rayfield = {}

local function Make(parent, className, props)
    local obj = Instance.new(className)
    if props then
        for k,v in pairs(props) do
            obj[k] = v
        end
    end
    obj.Parent = parent
    return obj
end

function Rayfield:CreateWindow(opts)
    opts = opts or {}
    local title = opts.Name or "RayfieldUI"
    local player = game:GetService("Players").LocalPlayer
    local gui = Make(player:WaitForChild("PlayerGui"), "ScreenGui", {Name = title, ResetOnSpawn = false})

    local main = Make(gui, "Frame", {Name = "Main", Size = UDim2.new(0,480,0,380), Position = UDim2.new(0,18,0,70), BackgroundColor3 = Color3.fromRGB(28,28,34), BorderSizePixel = 0})
    Make(main, "UICorner", {})
    local header = Make(main, "Frame", {Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1, Name = "Header"})

    local titleLabel = Make(header, "TextLabel", {Text = opts.Title or "Rayfield Window", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Color3.fromRGB(235,235,235), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0,10,0,6), Size = UDim2.new(1,-100,1,0)})
    -- simple button container
    local btnContainer = Make(header, "Frame", {Size = UDim2.new(0,120,1,0), Position = UDim2.new(1,-125,0,0), BackgroundTransparency = 1})

    local minimize = Make(btnContainer, "TextButton", {Text = "−", Size = UDim2.new(0,32,0,26), Position = UDim2.new(0,4,0.5,-13), Font = Enum.Font.GothamBold, TextSize = 16, BackgroundColor3 = Color3.fromRGB(60,60,66)})
    Make(minimize, "UICorner", {})
    local reload = Make(btnContainer, "TextButton", {Text = "🔄", Size = UDim2.new(0,32,0,26), Position = UDim2.new(0,42,0.5,-13), Font = Enum.Font.GothamBold, TextSize = 14, BackgroundColor3 = Color3.fromRGB(70,130,200)})
    Make(reload, "UICorner", {})
    local close = Make(btnContainer, "TextButton", {Text = "X", Size = UDim2.new(0,32,0,26), AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-4,0.5,-13), Font = Enum.Font.GothamBold, TextSize = 16, BackgroundColor3 = Color3.fromRGB(160,60,60)})
    Make(close, "UICorner", {})

    local Sidebar = Make(main, "Frame", {Size = UDim2.new(0,120,1,-50), Position = UDim2.new(0,10,0,45), BackgroundColor3 = Color3.fromRGB(22,22,28)})
    Make(Sidebar, "UICorner", {})

    local Content = Make(main, "Frame", {Size = UDim2.new(1,-145,1,-50), Position = UDim2.new(0,140,0,45), BackgroundTransparency = 1})

    local api = {
        Gui = gui,
        Main = main,
        Sidebar = Sidebar,
        Content = Content,
        Buttons = {},
        Tabs = {},
        Close = close,
        Minimize = minimize,
        Reload = reload
    }

    function api:CreateTab(name)
        local btn = Make(Sidebar, "TextButton", {Size = UDim2.new(1,-10,0,40), Position = UDim2.new(0,5,0,#api.Buttons*50 + 10), Text = name, Font = Enum.Font.GothamSemibold, TextSize = 14, BackgroundColor3 = Color3.fromRGB(40,40,46), TextColor3 = Color3.fromRGB(200,200,200), TextXAlignment = Enum.TextXAlignment.Left})
        Make(btn, "UICorner", {})
        local frame = Make(Content, "Frame", {Size = UDim2.new(1,0,1,-85), BackgroundTransparency = 1, Visible = false})
        api.Buttons[#api.Buttons+1] = btn
        api.Tabs[name] = {Button = btn, Frame = frame}
        local index = #api.Buttons
        btn.Position = UDim2.new(0,5,0,10 + (index-1) * 50)
        btn.MouseButton1Click:Connect(function()
            for k,v in pairs(api.Tabs) do v.Frame.Visible = (k==name) end
        end)
        return frame, btn
    end

    function api:Destroy()
        if gui and gui.Parent then gui:Destroy() end
    end

    return api
end

return Rayfield
