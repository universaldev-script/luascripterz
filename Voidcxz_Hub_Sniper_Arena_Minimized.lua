-- ============================================================
--  VOIDCXZ UI — SNIPER ARENA EDITION (Potassium)
--  ESP + Aimbot (ПКМ) + Triggerbot (игроки + NPC) + Watermark
-- ============================================================

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
--  UI LIBRARY
-- ============================================================
local Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Surface = Color3.fromRGB(24, 24, 30),
    SurfaceAlt = Color3.fromRGB(30, 30, 38),
    Outline = Color3.fromRGB(45, 45, 55),
    Text = Color3.fromRGB(235, 235, 240),
    TextDim = Color3.fromRGB(140, 140, 155),
    Accent = Color3.fromRGB(160, 90, 255),
    AccentBright = Color3.fromRGB(190, 120, 255),
    Success = Color3.fromRGB(90, 220, 130),
    Danger = Color3.fromRGB(255, 75, 90),
    Warning = Color3.fromRGB(255, 190, 80),
}

local Fonts = {
    Bold = Enum.Font.GothamBold,
    Medium = Enum.Font.GothamMedium,
    Regular = Enum.Font.Gotham,
}

local function new(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    return inst
end

local function corner(parent, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", {
        Color = color or Theme.Outline,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function tween(inst, props, time, style, dir)
    return TweenService:Create(inst,
        TweenInfo.new(time or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props):Play()
end

local Neverlose = {}
Neverlose.__index = Neverlose

function Neverlose.new(title, subtitle)
    local self = setmetatable({}, Neverlose)
    self.Title = title or "Voidcxz"
    self.Subtitle = subtitle or ""
    self.Tabs = {}
    self.ActiveTab = nil
    self.Opened = true

    self.Gui = new("ScreenGui", {
        Name = "VoidcxzUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })

    if gethui then
        self.Gui.Parent = gethui()
    elseif game:GetService("CoreGui") then
        self.Gui.Parent = game:GetService("CoreGui")
    else
        self.Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    self:_buildMain()
    self:_buildToggleButton()
    self:_buildKeybind()
    return self
end

function Neverlose:_buildMain()
    local main = new("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 580, 0, 420),
        Position = UDim2.new(0.5, -290, 0.5, -210),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = self.Gui,
    })
    self.Main = main
    corner(main, 10)
    stroke(main, Theme.Outline, 1)

    local topbar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = main,
    })
    corner(topbar, 10)

    new("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = topbar,
    })

    new("TextLabel", {
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        Font = Fonts.Bold,
        TextSize = 15,
        TextColor3 = Color3.new(1, 1, 1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar,
    })

    -- Minimize button: hides the main window and shows the floating restore button.
    local minimizeBtn = new("TextButton", {
        Size = UDim2.new(0, 28, 0, 24),
        Position = UDim2.new(1, -72, 0, 6),
        BackgroundColor3 = Theme.SurfaceAlt,
        Text = "—",
        Font = Fonts.Bold,
        TextSize = 14,
        TextColor3 = Theme.TextDim,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = topbar,
    })
    corner(minimizeBtn, 5)
    minimizeBtn.MouseButton1Click:Connect(function()
        self:Toggle(false)
    end)

    local closeBtn = new("TextButton", {
        Size = UDim2.new(0, 32, 0, 24),
        Position = UDim2.new(1, -38, 0, 6),
        BackgroundColor3 = Theme.SurfaceAlt,
        Text = "✕",
        Font = Fonts.Bold,
        TextSize = 13,
        TextColor3 = Theme.TextDim,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = topbar,
    })
    corner(closeBtn, 5)
    closeBtn.MouseButton1Click:Connect(function() self:Toggle(false) end)

    local sidebar = new("Frame", {
        Size = UDim2.new(0, 150, 1, -58),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = main,
    })

    new("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.Outline,
        BorderSizePixel = 0,
        Parent = sidebar,
    })

    local tabList = new("ScrollingFrame", {
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Outline,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    })
    self.TabList = tabList

    new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = tabList,
    })

    local content = new("Frame", {
        Size = UDim2.new(1, -150, 1, -58),
        Position = UDim2.new(0, 150, 0, 36),
        BackgroundTransparency = 1,
        Parent = main,
    })
    self.Content = content

    local bottom = new("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 1, -22),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = main,
    })
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Outline,
        BorderSizePixel = 0,
        Parent = bottom,
    })
    new("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Subtitle,
        Font = Fonts.Regular,
        TextSize = 11,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = bottom,
    })

    self:_makeDraggable(topbar, main)
end

function Neverlose:_makeDraggable(dragArea, target)
    local dragging, dragStart, startPos = false, nil, nil
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

function Neverlose:_buildToggleButton()
    -- Floating restore button shown while the hub is minimized.
    local btn = new("TextButton", {
        Name = "FloatingBtn",
        Size = UDim2.new(0, 54, 0, 54),
        Position = UDim2.new(0, 20, 1, -74),
        BackgroundColor3 = Theme.Surface,
        Text = "VX",
        Font = Fonts.Bold,
        TextSize = 17,
        TextColor3 = Theme.Accent,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 1000,
        Parent = self.Gui,
    })
    corner(btn, 27)
    stroke(btn, Theme.Accent, 2)
    btn.MouseButton1Click:Connect(function() self:Toggle(true) end)
    self.FloatingBtn = btn
end

function Neverlose:_buildKeybind()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.K then
            self:Toggle(not self.Opened)
        end
    end)
end

function Neverlose:Toggle(state)
    self.Opened = state
    self.Main.Visible = state
    self.FloatingBtn.Visible = not state
end

function Neverlose:Tab(name)
    local tabBtn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Surface,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Parent = self.TabList,
    })
    corner(tabBtn, 6)

    local indicator = new("Frame", {
        Size = UDim2.new(0, 3, 0, 16),
        Position = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Visible = false,
        Parent = tabBtn,
    })

    local label = new("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Fonts.Medium,
        TextSize = 13,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabBtn,
    })

    local page = new("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Outline,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.Content,
    })

    new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = page,
    })

    local tabData = { Button = tabBtn, Label = label, Indicator = indicator, Page = page, Name = name }

    tabBtn.MouseEnter:Connect(function()
        if self.ActiveTab ~= tabData then tween(tabBtn, { BackgroundColor3 = Theme.SurfaceAlt }) end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.ActiveTab ~= tabData then tween(tabBtn, { BackgroundColor3 = Theme.Surface }) end
    end)
    tabBtn.MouseButton1Click:Connect(function() self:SelectTab(tabData) end)

    table.insert(self.Tabs, tabData)
    if not self.ActiveTab then self:SelectTab(tabData) end
    return tabData
end

function Neverlose:SelectTab(tabData)
    if self.ActiveTab then
        local prev = self.ActiveTab
        prev.Indicator.Visible = false
        prev.Label.TextColor3 = Theme.TextDim
        prev.Button.BackgroundColor3 = Theme.Surface
        prev.Page.Visible = false
    end
    self.ActiveTab = tabData
    tabData.Indicator.Visible = true
    tabData.Label.TextColor3 = Theme.Text
    tabData.Button.BackgroundColor3 = Theme.SurfaceAlt
    tabData.Page.Visible = true
end

function Neverlose:Section(tab, text)
    local holder = new("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = tab.Page,
    })
    new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text:upper(),
        Font = Fonts.Bold,
        TextSize = 11,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder,
    })
    return holder
end

function Neverlose:Toggle_(tab, name, default, callback)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = tab.Page,
    })
    corner(row, 6)
    stroke(row, Theme.Outline, 1, 0.5)

    new("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Fonts.Medium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local switch = new("Frame", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -52, 0.5, -10),
        BackgroundColor3 = default and Theme.Accent or Theme.SurfaceAlt,
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(switch, 10)

    local knob = new("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(240, 240, 245),
        BorderSizePixel = 0,
        Parent = switch,
    })
    corner(knob, 8)

    local hitbox = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    })

    local state = default
    local function apply(v)
        state = v
        tween(switch, { BackgroundColor3 = v and Theme.Accent or Theme.SurfaceAlt }, 0.15)
        tween(knob, { Position = v and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }, 0.15)
        if callback then callback(v) end
    end
    hitbox.MouseButton1Click:Connect(function() apply(not state) end)
    return { Set = apply, Get = function() return state end, Frame = row }
end

function Neverlose:Slider(tab, name, min, max, default, callback)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = tab.Page,
    })
    corner(row, 6)
    stroke(row, Theme.Outline, 1, 0.5)

    new("TextLabel", {
        Size = UDim2.new(1, -24, 0, 18),
        Position = UDim2.new(0, 12, 0, 4),
        BackgroundTransparency = 1,
        Text = name,
        Font = Fonts.Medium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local valueLabel = new("TextLabel", {
        Size = UDim2.new(0, 80, 0, 18),
        Position = UDim2.new(1, -92, 0, 4),
        BackgroundTransparency = 1,
        Text = tostring(default),
        Font = Fonts.Bold,
        TextSize = 13,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })

    local barBg = new("Frame", {
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 30),
        BackgroundColor3 = Theme.SurfaceAlt,
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(barBg, 3)

    local fill = new("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = barBg,
    })
    corner(fill, 3)

    local knob = new("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(240, 240, 245),
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = barBg,
    })
    corner(knob, 6)

    local dragging = false
    local hitbox = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "",
        Parent = barBg,
    })

    local value = default
    local function setFromX(x)
        local rel = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * rel + 0.5)
        value = v
        valueLabel.Text = tostring(v)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -6, 0.5, -6)
        if callback then callback(v) end
    end

    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setFromX(input.Position.X)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then setFromX(input.Position.X) end
    end)

    return { Set = setFromX, Get = function() return value end, Frame = row }
end

function Neverlose:Button(tab, name, callback)
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Surface,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Parent = tab.Page,
    })
    corner(btn, 6)
    stroke(btn, Theme.Outline, 1, 0.5)

    new("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Fonts.Medium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
    })

    btn.MouseEnter:Connect(function() tween(btn, { BackgroundColor3 = Theme.SurfaceAlt }) end)
    btn.MouseLeave:Connect(function() tween(btn, { BackgroundColor3 = Theme.Surface }) end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    return btn
end

function Neverlose:Notify(title, content, duration)
    duration = duration or 3
    local notif = new("Frame", {
        Size = UDim2.new(0, 280, 0, 60),
        Position = UDim2.new(1, 300, 0, 20),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = self.Gui,
    })
    corner(notif, 8)
    stroke(notif, Theme.Accent, 1)

    new("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = notif,
    })

    new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        Font = Fonts.Bold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })

    new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 14, 0, 26),
        BackgroundTransparency = 1,
        Text = content,
        Font = Fonts.Regular,
        TextSize = 12,
        TextColor3 = Theme.TextDim,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })

    tween(notif, { Position = UDim2.new(1, -300, 0, 20) }, 0.25)
    task.delay(duration, function()
        tween(notif, { Position = UDim2.new(1, 300, 0, 20) }, 0.25)
        task.wait(0.3)
        notif:Destroy()
    end)
end

function Neverlose:Destroy()
    if self.Gui then self.Gui:Destroy() end
end

-- ============================================================
--  CONFIG
-- ============================================================
local PlayerESP = {
    Enabled = false,
    ShowName = true,
    ShowDistance = true,
    MaxDistance = 2000,
    BoxColor = Color3.fromRGB(90, 220, 130),
}

local NpcESP = {
    Enabled = false,
    ShowName = true,
    ShowDistance = true,
    MaxDistance = 2000,
    BoxColor = Color3.fromRGB(255, 130, 60),
}

local Aimbot = {
    Enabled = false,
    FOV = 200,
    Smoothness = 0.35,
    ReactionTime = 0,
    VisibleCheck = true,
    TeamCheck = true,
    TargetPart = "Head",
    MaxDistance = 3000,
    DrawFOV = true,
    UseSnap = false,
    TargetPlayers = true,
    TargetNpcs = true,
    HoldingRMB = false,
}

local Triggerbot = {
    Enabled = false,
    Delay = 0.05,
    VisibleCheck = true,
    TeamCheck = true,
    MaxDistance = 2000,
    TargetPart = "Head",
    Holding = false,
    TargetPlayers = true,
    TargetNpcs = true,
}

local Watermark = {
    Enabled = true,
    Frame = nil,
    Text = nil,
    Dragging = false,
    DragStart = nil,
    StartPos = nil,
}

-- ============================================================
--  STATE
-- ============================================================
local unloaded = false
local espCache = {}
local npcEspCache = {}
local fovCircle = nil
local currentTarget = nil
local lastTargetSetTime = 0
local NeverloseInstance = nil

-- ============================================================
--  HELPERS
-- ============================================================
local function isAlive(plr)
    if not plr then return false end
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getRoot(plr)
    if not plr or not plr.Character then return nil end
    return plr.Character:FindFirstChild("HumanoidRootPart")
end

local function getHead(plr)
    if not plr or not plr.Character then return nil end
    return plr.Character:FindFirstChild("Head")
end

local function isSameTeam(a, b)
    if not a or not b then return false end
    return a.Team == b.Team
end

local function isNpcModel(model)
    if not model then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    if model:FindFirstChildOfClass("Humanoid") then return true end
    return false
end

-- ============================================================
--  WATERMARK
-- ============================================================
local function createWatermark()
    if not NeverloseInstance then return end
    if Watermark.Frame then return end

    local wm = new("Frame", {
        Name = "VoidcxzWatermark",
        Size = UDim2.new(0, 220, 0, 28),
        Position = UDim2.new(0, 20, 0, 80),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = NeverloseInstance.Gui,
        ZIndex = 500,
    })
    corner(wm, 6)
    stroke(wm, Theme.Accent, 1, 0.2)

    local accentBar = new("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = wm,
        ZIndex = 501,
    })
    corner(accentBar, 6)

    local textLabel = new("TextLabel", {
        Name = "Info",
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "Voidcxz | Ping: -- | FPS: -- | --:--:--",
        Font = Fonts.Bold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = wm,
        ZIndex = 501,
    })

    Watermark.Frame = wm
    Watermark.Text = textLabel

    wm.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Watermark.Dragging = true
            Watermark.DragStart = input.Position
            Watermark.StartPos = wm.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Watermark.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - Watermark.DragStart
            wm.Position = UDim2.new(
                Watermark.StartPos.X.Scale,
                Watermark.StartPos.X.Offset + delta.X,
                Watermark.StartPos.Y.Scale,
                Watermark.StartPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Watermark.Dragging = false
        end
    end)
end

local function updateWatermark()
    if not Watermark.Frame or not Watermark.Enabled then return end
    if not Watermark.Text then return end

    local ping = 0
    pcall(function()
        ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)

    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local timeStr = os.date("%H:%M:%S")

    Watermark.Text.Text = string.format("Voidcxz | Ping: %d | FPS: %d | %s", ping, fps, timeStr)
end

local function setWatermarkVisible(state)
    Watermark.Enabled = state
    if state then
        createWatermark()
    end
    if Watermark.Frame then
        Watermark.Frame.Visible = state
    end
end

-- ============================================================
--  ESP через Drawing (игроки)
-- ============================================================
local function createESP(plr)
    if plr == LocalPlayer then return end
    if espCache[plr] then return end
    if not Drawing then return end

    local box = Drawing.new("Square")
    box.Filled = false
    box.Color = PlayerESP.BoxColor
    box.Thickness = 1.5
    box.Visible = false

    local nameText = Drawing.new("Text")
    nameText.Text = plr.Name
    nameText.Color = Color3.fromRGB(240, 240, 245)
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Visible = false

    espCache[plr] = { box = box, nameText = nameText }
end

local function removeESP(plr)
    local data = espCache[plr]
    if not data then return end
    pcall(function() data.box:Remove() end)
    pcall(function() data.nameText:Remove() end)
    espCache[plr] = nil
end

local function updateESP()
    if not PlayerESP.Enabled then return end
    if not Drawing then return end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not espCache[plr] then createESP(plr) end
        local data = espCache[plr]
        if not data then continue end

        local root = getRoot(plr)
        local head = getHead(plr)
        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")

        if not root or not head or not hum or hum.Health <= 0 then
            data.box.Visible = false
            data.nameText.Visible = false
            continue
        end

        local dist = (myPos - root.Position).Magnitude
        if dist > PlayerESP.MaxDistance then
            data.box.Visible = false
            data.nameText.Visible = false
            continue
        end

        local headScreen, onScreenHead = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local rootScreen, onScreenRoot = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.5, 0))

        if not onScreenHead or not onScreenRoot then
            data.box.Visible = false
            data.nameText.Visible = false
            continue
        end

        local height = math.abs(rootScreen.Y - headScreen.Y)
        local width = height * 0.6
        local x = headScreen.X - width / 2
        local y = headScreen.Y

        data.box.Size = Vector2.new(width, height)
        data.box.Position = Vector2.new(x, y)
        data.box.Visible = true
        data.box.Color = PlayerESP.BoxColor

        if PlayerESP.ShowName then
            local text = plr.Name
            if PlayerESP.ShowDistance then
                text = text .. string.format(" [%dm]", math.floor(dist))
            end
            data.nameText.Text = text
            data.nameText.Position = Vector2.new(headScreen.X, y - 18)
            data.nameText.Visible = true
        else
            data.nameText.Visible = false
        end
    end
end

local function clearAllESP()
    for plr, _ in pairs(espCache) do removeESP(plr) end
end

-- ============================================================
--  ESP для NPC
-- ============================================================
local function createNpcESP(model)
    if npcEspCache[model] then return end
    if not Drawing then return end

    local box = Drawing.new("Square")
    box.Filled = false
    box.Color = NpcESP.BoxColor
    box.Thickness = 1.5
    box.Visible = false

    local nameText = Drawing.new("Text")
    nameText.Text = model.Name
    nameText.Color = Color3.fromRGB(240, 240, 245)
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Visible = false

    npcEspCache[model] = { box = box, nameText = nameText }
end

local function removeNpcESP(model)
    local data = npcEspCache[model]
    if not data then return end
    pcall(function() data.box:Remove() end)
    pcall(function() data.nameText:Remove() end)
    npcEspCache[model] = nil
end

local function scanNpcs()
    if not NpcESP.Enabled then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and isNpcModel(obj) then
            if not npcEspCache[obj] then
                createNpcESP(obj)
            end
        end
    end
end

local function updateNpcESP()
    if not NpcESP.Enabled then return end
    if not Drawing then return end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position

    for model, data in pairs(npcEspCache) do
        if not model or not model.Parent then
            removeNpcESP(model)
            continue
        end

        local head = model:FindFirstChild("Head") or model:FindFirstChildWhichIsA("BasePart")
        local root = model:FindFirstChild("HumanoidRootPart") or head
        local hum = model:FindFirstChildOfClass("Humanoid")

        if not head or not root or not hum or hum.Health <= 0 then
            data.box.Visible = false
            data.nameText.Visible = false
            continue
        end

        local dist = (myPos - root.Position).Magnitude
        if dist > NpcESP.MaxDistance then
            data.box.Visible = false
            data.nameText.Visible = false
            continue
        end

        local headScreen, onScreenHead = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local rootScreen, onScreenRoot = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.5, 0))

        if not onScreenHead or not onScreenRoot then
            data.box.Visible = false
            data.nameText.Visible = false
            continue
        end

        local height = math.abs(rootScreen.Y - headScreen.Y)
        local width = height * 0.6
        local x = headScreen.X - width / 2
        local y = headScreen.Y

        data.box.Size = Vector2.new(width, height)
        data.box.Position = Vector2.new(x, y)
        data.box.Visible = true
        data.box.Color = NpcESP.BoxColor

        if NpcESP.ShowName then
            local text = model.Name
            if NpcESP.ShowDistance then
                text = text .. string.format(" [%dm]", math.floor(dist))
            end
            data.nameText.Text = text
            data.nameText.Position = Vector2.new(headScreen.X, y - 18)
            data.nameText.Visible = true
        else
            data.nameText.Visible = false
        end
    end
end

local function clearAllNpcESP()
    for model, _ in pairs(npcEspCache) do removeNpcESP(model) end
end

-- ============================================================
--  FOV CIRCLE
-- ============================================================
local function updateFovCircle()
    if not Drawing then return end
    if not Aimbot.DrawFOV then
        if fovCircle then fovCircle.Visible = false end
        return
    end

    if not fovCircle then
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 1
        fovCircle.NumSides = 64
        fovCircle.Filled = false
        fovCircle.Color = Theme.Accent
        fovCircle.Transparency = 1
    end

    fovCircle.Radius = Aimbot.FOV
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Visible = Aimbot.Enabled
end

-- ============================================================
--  AIMBOT (игроки + NPC)
-- ============================================================
local function getClosestTarget()
    local bestTarget = nil
    local bestDist = Aimbot.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local myPos = myRoot.Position

    local function checkTarget(model, isPlayerTarget)
        if not model or not model.Parent then return end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end

        local root = model:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local targetPart = model:FindFirstChild(Aimbot.TargetPart) or root
        if not targetPart then return end

        local dist3D = (myPos - root.Position).Magnitude
        if dist3D > Aimbot.MaxDistance then return end

        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then return end

        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist2D > Aimbot.FOV then return end

        if Aimbot.VisibleCheck then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { myChar, Camera }
            params.IgnoreWater = true
            local dir = targetPart.Position - Camera.CFrame.Position
            local result = Workspace:Raycast(Camera.CFrame.Position, dir, params)
            if result and not result.Instance:IsDescendantOf(model) then return end
        end

        if dist2D < bestDist then
            bestDist = dist2D
            bestTarget = {
                model = model,
                part = targetPart,
                distance = dist3D,
                isPlayer = isPlayerTarget,
            }
        end
    end

    if Aimbot.TargetPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            if not isAlive(plr) then continue end
            if Aimbot.TeamCheck and isSameTeam(plr, LocalPlayer) then continue end
            checkTarget(plr.Character, true)
        end
    end

    if Aimbot.TargetNpcs then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not obj:IsA("Model") then continue end
            if not isNpcModel(obj) then continue end
            checkTarget(obj, false)
        end
    end

    return bestTarget
end

local function aimbotLoop()
    if unloaded then return end

    if not Aimbot.Enabled or not Aimbot.HoldingRMB then
        currentTarget = nil
        return
    end

    local target = getClosestTarget()
    if target then
        local now = tick()
        if target.model ~= currentTarget then
            currentTarget = target.model
            lastTargetSetTime = now
        end

        if now - lastTargetSetTime >= Aimbot.ReactionTime then
            local camPos = Camera.CFrame.Position
            local desired = CFrame.new(camPos, target.part.Position)

            if Aimbot.UseSnap then
                pcall(function() Camera.CFrame = desired end)
            else
                local smooth = math.clamp(Aimbot.Smoothness, 0.01, 1)
                pcall(function() Camera.CFrame = Camera.CFrame:Lerp(desired, smooth) end)
            end
        end
    else
        currentTarget = nil
    end
end

-- ============================================================
--  TRIGGERBOT (игроки + NPC)
-- ============================================================
local function triggerbotCheck()
    if not Triggerbot.Enabled or not Triggerbot.Holding then return end
    if not isAlive(LocalPlayer) then return end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local function tryFire(model, isPlayerTarget)
        if not model or not model.Parent then return false end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end

        local root = model:FindFirstChild("HumanoidRootPart")
        if not root then return false end

        local targetPart = model:FindFirstChild(Triggerbot.TargetPart) or root
        if not targetPart then return false end

        local dist3D = (myPos - root.Position).Magnitude
        if dist3D > Triggerbot.MaxDistance then return false end

        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then return false end

        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist2D > 15 then return false end

        if Triggerbot.VisibleCheck then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { myChar, Camera }
            params.IgnoreWater = true
            local dir = targetPart.Position - Camera.CFrame.Position
            local result = Workspace:Raycast(Camera.CFrame.Position, dir, params)
            if result and not result.Instance:IsDescendantOf(model) then return false end
        end

        return true
    end

    local function fire()
        task.wait(Triggerbot.Delay)
        if Triggerbot.Enabled and Triggerbot.Holding then
            pcall(function()
                if mouse1click then
                    mouse1click()
                elseif mouse1press and mouse1release then
                    mouse1press()
                    task.wait(0.02)
                    mouse1release()
                end
            end)
        end
    end

    if Triggerbot.TargetPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            if not isAlive(plr) then continue end
            if Triggerbot.TeamCheck and isSameTeam(plr, LocalPlayer) then continue end

            if tryFire(plr.Character, true) then
                fire()
                return
            end
        end
    end

    if Triggerbot.TargetNpcs then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not obj:IsA("Model") then continue end
            if not isNpcModel(obj) then continue end

            if tryFire(obj, false) then
                fire()
                return
            end
        end
    end
end

-- ============================================================
--  INPUT
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aimbot.HoldingRMB = true
        Triggerbot.Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aimbot.HoldingRMB = false
        Triggerbot.Holding = false
        currentTarget = nil
    end
end)

-- ============================================================
--  LOOPS
-- ============================================================
RunService.RenderStepped:Connect(function()
    if unloaded then return end
    updateESP()
    updateNpcESP()
    updateFovCircle()
end)

pcall(function()
    RunService:BindToRenderStep(
        "VoidcxzAimbot",
        Enum.RenderPriority.Camera.Value + 1,
        function()
            if unloaded then return end
            aimbotLoop()
            triggerbotCheck()
        end
    )
end)

task.spawn(function()
    while not unloaded do
        task.wait(0.25)
        updateWatermark()
    end
end)

Players.PlayerAdded:Connect(function(plr)
    task.wait(0.5)
    if PlayerESP.Enabled then createESP(plr) end
end)

Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
end)

task.spawn(function()
    while not unloaded do
        task.wait(0.5)
        if NpcESP.Enabled then
            scanNpcs()
        end
    end
end)

-- ============================================================
--  UI
-- ============================================================
local UI = Neverlose.new("Voidcxz Hub", "Sniper Arena  |  K — toggle menu")
NeverloseInstance = UI

-- ============ VISUALS TAB ============
local VisualsTab = UI:Tab("Visuals")

UI:Section(VisualsTab, "ESP игроков")
UI:Toggle_(VisualsTab, "Включить ESP игроков", false, function(v)
    PlayerESP.Enabled = v
    if not v then clearAllESP() end
end)
UI:Toggle_(VisualsTab, "Показывать имя", true, function(v) PlayerESP.ShowName = v end)
UI:Toggle_(VisualsTab, "Показывать дистанцию", true, function(v) PlayerESP.ShowDistance = v end)
UI:Slider(VisualsTab, "Макс. дистанция", 100, 5000, 2000, function(v) PlayerESP.MaxDistance = v end)

UI:Section(VisualsTab, "ESP NPC")
UI:Toggle_(VisualsTab, "Включить ESP NPC", false, function(v)
    NpcESP.Enabled = v
    if v then scanNpcs() else clearAllNpcESP() end
end)
UI:Toggle_(VisualsTab, "Показывать имя NPC", true, function(v) NpcESP.ShowName = v end)
UI:Toggle_(VisualsTab, "Показывать дистанцию NPC", true, function(v) NpcESP.ShowDistance = v end)
UI:Slider(VisualsTab, "Макс. дистанция NPC", 100, 5000, 2000, function(v) NpcESP.MaxDistance = v end)

-- ============ AIMBOT TAB ============
local AimbotTab = UI:Tab("Aimbot")

UI:Section(AimbotTab, "Основное")
UI:Toggle_(AimbotTab, "Включить Aimbot", false, function(v) Aimbot.Enabled = v end)
UI:Slider(AimbotTab, "FOV", 50, 1000, 200, function(v) Aimbot.FOV = v end)
UI:Slider(AimbotTab, "Плавность (x0.01)", 1, 100, 35, function(v) Aimbot.Smoothness = v * 0.01 end)
UI:Slider(AimbotTab, "Макс. дистанция", 100, 5000, 3000, function(v) Aimbot.MaxDistance = v end)

UI:Section(AimbotTab, "Реакция")
UI:Slider(AimbotTab, "Задержка перед наводкой (x10ms)", 0, 50, 0, function(v)
    Aimbot.ReactionTime = v * 0.01
end)

UI:Section(AimbotTab, "Цели")
UI:Toggle_(AimbotTab, "🎯 Игроки", true, function(v) Aimbot.TargetPlayers = v end)
UI:Toggle_(AimbotTab, "🐺 NPC", true, function(v) Aimbot.TargetNpcs = v end)

UI:Section(AimbotTab, "Опции")
UI:Toggle_(AimbotTab, "Visible Check", true, function(v) Aimbot.VisibleCheck = v end)
UI:Toggle_(AimbotTab, "Team Check", true, function(v) Aimbot.TeamCheck = v end)
UI:Toggle_(AimbotTab, "⚡ Snap", false, function(v) Aimbot.UseSnap = v end)
UI:Toggle_(AimbotTab, "Показывать FOV-круг", true, function(v) Aimbot.DrawFOV = v end)

-- ============ TRIGGERBOT TAB ============
local TriggerTab = UI:Tab("Triggerbot")

UI:Section(TriggerTab, "Основное")
UI:Toggle_(TriggerTab, "Включить Triggerbot", false, function(v) Triggerbot.Enabled = v end)
UI:Slider(TriggerTab, "Реакция (x10ms)", 0, 50, 5, function(v) Triggerbot.Delay = v * 0.01 end)
UI:Slider(TriggerTab, "Макс. дистанция", 100, 5000, 2000, function(v) Triggerbot.MaxDistance = v end)

UI:Section(TriggerTab, "Цели")
UI:Toggle_(TriggerTab, "🎯 Игроки", true, function(v) Triggerbot.TargetPlayers = v end)
UI:Toggle_(TriggerTab, "🐺 NPC", false, function(v) Triggerbot.TargetNpcs = v end)

UI:Section(TriggerTab, "Опции")
UI:Toggle_(TriggerTab, "Visible Check", true, function(v) Triggerbot.VisibleCheck = v end)
UI:Toggle_(TriggerTab, "Team Check", true, function(v) Triggerbot.TeamCheck = v end)

-- ============ CONTROL TAB ============
local ControlTab = UI:Tab("Control")

UI:Section(ControlTab, "Watermark")
UI:Toggle_(ControlTab, "Включить Watermark", true, function(v)
    setWatermarkVisible(v)
end)

UI:Section(ControlTab, "Скрипт")
UI:Button(ControlTab, "Очистить ESP", function()
    clearAllESP()
    clearAllNpcESP()
    UI:Notify("ESP", "Очищено", 2)
end)
UI:Button(ControlTab, "Unload", function()
    unloaded = true
    clearAllESP()
    clearAllNpcESP()
    if fovCircle then pcall(function() fovCircle:Remove() end) end
    if Watermark.Frame then pcall(function() Watermark.Frame:Destroy() end) end
    pcall(function()
        RunService:UnbindFromRenderStep("VoidcxzAimbot")
    end)
    UI:Destroy()
    print("[Voidcxz] Выгружено.")
end)

-- Инициализация watermark
setWatermarkVisible(true)

print("[Voidcxz] Sniper Arena загружен. K — меню.")
print("[Voidcxz] Aimbot активируется на ПКМ. Цели: игроки + NPC.")
print("[Voidcxz] Watermark включён — перетаскивай мышкой.")
