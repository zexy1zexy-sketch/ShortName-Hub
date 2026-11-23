local Players = game:GetService("Players"); local UIS = game:GetService("UserInputService"); local GuiService = game:GetService("GuiService")
local CREATOR_USER_ID = 7867608166
local LocalPlayer = Players.LocalPlayer
local IsCreator = LocalPlayer ~= nil and LocalPlayer.UserId == CREATOR_USER_ID
local OwnerViewEnabled = IsCreator
local OwnerOnlyFolders = {}
local TweenService = game:GetService("TweenService"); local GUI = {}

local function BuildUpdatesPage(page, config, accent, buttonDark, border, white, grey, label, corner, stroke, tween)
    label(page, "WELCOME BACK", 18, 32).Font = Enum.Font.GothamBold
    label(page, "Here's what's new in ShortName Hub.", 12, 24, grey)
    local welcomeCard = Instance.new("Frame")
    welcomeCard.Size = UDim2.new(1, 0, 0, 104)
    welcomeCard.BackgroundColor3 = buttonDark
    welcomeCard.BorderSizePixel = 0
    welcomeCard.Parent = page
    corner(welcomeCard, 12)
    stroke(welcomeCard, accent.Light, 1.2)
    local welcomeTitle = label(welcomeCard, "SHORTNAME HUB  -  CONTROL CENTER", 13, 25, accent.Light)
    welcomeTitle.Position = UDim2.fromOffset(14, 12)
    welcomeTitle.Font = Enum.Font.GothamBold
    local welcomeDescription = label(welcomeCard, "A cleaner, roomier interface with customizable appearance controls and a streamlined navigation system.", 11, 48, white)
    welcomeDescription.Position = UDim2.fromOffset(14, 42)
    welcomeDescription.TextWrapped = true
    label(page, "LATEST CHANGES  -  v" .. tostring(config.Version or "1.0.2"), 12, 25, accent.Light).Font = Enum.Font.GothamBold
    local updateItems = {
        { "01  -  Modular theme foundation", "Centralized accent palette and active navigation glow." },
        { "02  -  Adjustable appearance", "New interface scale and transparency sliders." },
        { "03  -  Custom backgrounds", "Set a custom Roblox image asset ID or asset URL." },
        { "04  -  Spacious layout", "Larger responsive window and minimal collapsible sidebar." }
    }
    for _, item in ipairs(updateItems) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 40)
        card.BackgroundColor3 = buttonDark
        card.BorderSizePixel = 0
        card.ClipsDescendants = true
        card.Parent = page
        corner(card, 10)
        stroke(card, border, 1)
        local heading = Instance.new("TextButton")
        heading.Size = UDim2.new(1, -20, 0, 38)
        heading.Position = UDim2.fromOffset(10, 1)
        heading.BackgroundTransparency = 1
        heading.Text = "v" .. tostring(config.Version or "1.0.2") .. "  -  " .. item[1] .. "     +"
        heading.TextColor3 = white
        heading.TextSize = 11
        heading.Font = Enum.Font.GothamBold
        heading.TextXAlignment = Enum.TextXAlignment.Left
        heading.Parent = card
        local detail = label(card, item[2], 10, 34, grey)
        detail.Position = UDim2.fromOffset(12, 40)
        detail.TextWrapped = true
        detail.Visible = false
        local expanded = false
        heading.Activated:Connect(function()
            expanded = not expanded
            detail.Visible = expanded
            heading.Text = "v" .. tostring(config.Version or "1.0.2") .. "  -  " .. item[1] .. (expanded and "     -" or "     +")
            tween(card, { Size = UDim2.new(1, 0, 0, expanded and 80 or 40) }, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
        end)
    end
end

function GUI.CreateSlider(parent, title, minimum, maximum, initialValue, accent, callback, formatValue)
    local holder = Instance.new("Frame")
    holder.Name = "SNHSlider_" .. tostring(title):gsub("%W", "")
    holder.Size = UDim2.new(1, 0, 0, 54)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -72, 0, 19)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(155, 155, 175)
    titleLabel.TextSize = 11
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = holder

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.fromOffset(70, 19)
    valueLabel.Position = UDim2.new(1, -70, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(220, 210, 245)
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = holder

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -8, 0, 7)
    track.Position = UDim2.fromOffset(0, 32)
    track.BackgroundColor3 = Color3.fromRGB(47, 43, 58)
    track.BorderSizePixel = 0
    track.Parent = holder
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = accent:Lerp(Color3.new(1, 1, 1), 0.3)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local currentValue = initialValue
    local inputConnection
    local endedConnection

    local function setValue(value, notify)
        currentValue = math.clamp(value, minimum, maximum)
        local alpha = (currentValue - minimum) / (maximum - minimum)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = formatValue and formatValue(currentValue) or tostring(math.floor(currentValue * 100 + 0.5) / 100)
        if notify and callback then callback(currentValue) end
    end

    local function updateFromX(x)
        local width = track.AbsoluteSize.X
        if width <= 0 then return end
        setValue(minimum + (maximum - minimum) * math.clamp((x - track.AbsolutePosition.X) / width, 0, 1), true)
    end

    local function beginDrag(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = true
        updateFromX(input.Position.X)
    end

    track.InputBegan:Connect(beginDrag)
    knob.InputBegan:Connect(beginDrag)
    inputConnection = UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)
    endedConnection = UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    holder.Destroying:Connect(function()
        if inputConnection then inputConnection:Disconnect() end
        if endedConnection then endedConnection:Disconnect() end
    end)

    setValue(initialValue, true)
    return holder, function(value) setValue(value, false) end
end

function GUI.Create(Config, Controller, Scythe, ThanksgivingScanner, FightScanner, FightInspector, FightStructureScanner, RefreshCallback, PresenceModule, ThemeModule)
    GUI.AnimationsEnabled = true
    local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "ShortNameHub"; ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local success = pcall(function()
        ScreenGui.Parent = gethui()
    end)
    if not success then
        ScreenGui.Parent = game:GetService("CoreGui")
    end

    local Camera = workspace.CurrentCamera; local Viewport = Camera and Camera.ViewportSize or Vector2.new(1000, 720); local WindowWidth =
    math.max(320, math.min(900, Viewport.X - 24))
    local WindowHeight = math.max(380, math.min(650, Viewport.Y - 24)); local Purple = Color3.fromRGB(145, 75, 255); local Dark = Color3.fromRGB(12,
    12, 17)
    local Panel = Color3.fromRGB(23, 23, 31); local ButtonDark = Color3.fromRGB(31, 31, 42); local White = Color3.fromRGB(240, 240, 248)
    local Grey = Color3.fromRGB(155, 155, 175); local PurpleLight = Color3.fromRGB(185, 135, 255); local Border = Color3.fromRGB(54, 48, 70)
    local FastTween = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function Tween(obj, properties, info)
        if obj and obj.Parent then
            TweenService:Create(obj, info or FastTween, properties):Play()
        end
    end

    local function AddGradient(obj, topColor, bottomColor, rotation)
        local gradient = Instance.new("UIGradient"); gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, topColor),
            ColorSequenceKeypoint.new(1, bottomColor)
        })
        gradient.Rotation = rotation or 90; gradient.Parent = obj
        return gradient
    end

    local function AddHover(button, normalColor, hoverColor)
        button.AutoButtonColor = false
        button:SetAttribute("SNHNormalColor", normalColor)
        button.MouseEnter:Connect(function()
            Tween(button, {
                BackgroundColor3 = hoverColor
            })
            if ThemeModule and type(ThemeModule.ApplyGlow) == "function" then
                ThemeModule.ApplyGlow(button, Purple, true)
            end
        end)
        button.MouseLeave:Connect(function()
            Tween(button, {
                BackgroundColor3 = button:GetAttribute("SNHNormalColor") or normalColor
            })
            if ThemeModule and type(ThemeModule.ApplyGlow) == "function" then
                ThemeModule.ApplyGlow(button, Purple, false)
            end
        end)
    end

    local function Corner(obj, radius)
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or 8); c.Parent = obj
    end

    local function Stroke(obj, color, thickness)
        local s = Instance.new("UIStroke"); s.Color = color or Purple; s.Thickness = thickness or 1
        s.Transparency = 0.18; s.Parent = obj
        return s
    end

    local function Label(parent, text, size, height, color)
        local item = Instance.new("TextLabel"); item.Size = UDim2.new(1, 0, 0, height or 25); item.BackgroundTransparency = 1
        item.Text = text; item.TextColor3 = color or White; item.TextSize = size or 13
        item.Font = Enum.Font.Gotham; item.TextXAlignment = Enum.TextXAlignment.Left; item.Parent = parent
        return item
    end

    -- MAIN WINDOW
    local Frame = Instance.new("Frame"); Frame.Size = UDim2.fromOffset(WindowWidth, WindowHeight); Frame.Position = UDim2.new(0.5, -WindowWidth / 2,
    0.5, -WindowHeight / 2)
    Frame.BackgroundColor3 = Dark; Frame.BorderSizePixel = 0; Frame.ClipsDescendants = true; Frame.Parent = ScreenGui
    local WindowScale = Instance.new("UIScale"); WindowScale.Scale = 1; WindowScale.Parent = Frame
    Corner(Frame, 16); AddGradient(Frame, Color3.fromRGB(19, 18, 27), Dark, 90); Stroke(Frame, Color3.fromRGB(105, 76, 150), 1.25)
    GUI.BackgroundImage = Instance.new("ImageLabel")
    GUI.BackgroundImage.Name = "CustomBackground"
    GUI.BackgroundImage.Size = UDim2.fromScale(1, 1)
    GUI.BackgroundImage.BackgroundTransparency = 1
    GUI.BackgroundImage.ImageTransparency = 0.34
    GUI.BackgroundImage.ScaleType = Enum.ScaleType.Crop
    GUI.BackgroundImage.ZIndex = 0
    GUI.BackgroundImage.Parent = Frame

    local AccentLine = Instance.new("Frame"); AccentLine.Name = "AccentLine"; AccentLine.Size = UDim2.new(1, -28, 0, 2)
    AccentLine.Position = UDim2.fromOffset(14, 48); AccentLine.BackgroundColor3 = Purple; AccentLine.BorderSizePixel = 0
    AccentLine.ZIndex = 3; AccentLine.Parent = Frame; AddGradient(AccentLine, PurpleLight, Purple, 0)
    Corner(AccentLine, 2)

    -- HEADER
    local Header = Instance.new("Frame"); Header.Size = UDim2.new(1, 0, 0, 48); Header.BackgroundColor3 = Dark
    Header.BorderSizePixel = 0; Header.Parent = Frame; Corner(Header, 12)
    AddGradient(Header, Color3.fromRGB(31, 25, 43), Dark, 90); local HeaderTitle = Label(Header, "  SN  SHORTNAME HUB", 15, 48); HeaderTitle.Font =
    Enum.Font.GothamBold
    HeaderTitle.Size = UDim2.new(1, IsCreator and -410 or -336, 0, 25); HeaderTitle.TextTruncate = Enum.TextTruncate.AtEnd; HeaderTitle.Position = UDim2.fromOffset(2, 5); HeaderTitle.TextSize = 15
    local HeaderSubtitle = Label(Header, "CONTROL CENTER  -  v" .. tostring(Config.Version or "1.0.0"), 8, 14, Grey); HeaderSubtitle.Position = UDim2.fromOffset(15, 27)
    HeaderSubtitle.Size = UDim2.new(1, IsCreator and -410 or -336, 0, 13); HeaderSubtitle.TextTruncate = Enum.TextTruncate.AtEnd; HeaderSubtitle.Font = Enum.Font.GothamMedium; HeaderSubtitle.TextTransparency = 0.12

    local MinButton = Instance.new("TextButton"); MinButton.Size = UDim2.fromOffset(28, 30); MinButton.Position = UDim2.new(1, -70, 0, 8)
    MinButton.BackgroundColor3 = ButtonDark; MinButton.Text = "-"; MinButton.TextColor3 = White
    MinButton.TextSize = 17; MinButton.Font = Enum.Font.GothamBold; MinButton.Parent = Header
    MinButton.ZIndex = 5; Corner(MinButton, 8); Stroke(MinButton, Border, 1)
    AddHover(MinButton, ButtonDark, Color3.fromRGB(55, 48, 69))

    local ExitButton = Instance.new("TextButton"); ExitButton.Size = UDim2.fromOffset(28, 30)
    ExitButton.Position = UDim2.new(1, -36, 0, 8); ExitButton.BackgroundColor3 = ButtonDark; ExitButton.Text = "X"
    ExitButton.TextColor3 = Color3.fromRGB(255, 170, 180); ExitButton.TextSize = 21; ExitButton.Font = Enum.Font.Gotham
    ExitButton.Parent = Header; Corner(ExitButton, 8); Stroke(ExitButton, Border, 1)
    AddHover(ExitButton, ButtonDark, Color3.fromRGB(95, 43, 55))

    -- CREATOR-ONLY VIEW SWITCH
    local OwnerViewButton
    if IsCreator then
        OwnerViewButton = Instance.new("TextButton")
        OwnerViewButton.Size = UDim2.fromOffset(62, 28)
        OwnerViewButton.Position = UDim2.new(1, -240, 0, 9)
        OwnerViewButton.BackgroundColor3 = Color3.fromRGB(55, 42, 77)
        OwnerViewButton.Text = "👑 OWNER"
        OwnerViewButton.TextColor3 = White
        OwnerViewButton.TextSize = 9
        OwnerViewButton.Font = Enum.Font.GothamBold
        OwnerViewButton.Parent = Header
        OwnerViewButton.ZIndex = 8
        Corner(OwnerViewButton, 7)
        Stroke(OwnerViewButton, PurpleLight, 1)
        AddHover(OwnerViewButton, Color3.fromRGB(55, 42, 77), Color3.fromRGB(75, 55, 105))
    end

    -- OWNER SETTINGS SHORTCUT: sits immediately left of the owner/users switch.
    local GearButton
    do
        GearButton = Instance.new("TextButton")
        GearButton.Size = UDim2.fromOffset(28, 30)
        GearButton.Position = UDim2.new(1, IsCreator and -274 or -240, 0, 8)
        GearButton.BackgroundColor3 = ButtonDark
        GearButton.Text = "⚙️"
        GearButton.TextColor3 = White
        GearButton.TextSize = 17
        GearButton.Font = Enum.Font.GothamBold
        GearButton.Parent = Header
        GearButton.ZIndex = 8
        Corner(GearButton, 8)
        Stroke(GearButton, Border, 1)
        AddHover(GearButton, ButtonDark, Color3.fromRGB(55, 48, 69))
    end

    -- COMMUNITY SHORTCUTS
    local CrownButton = Instance.new("TextButton")
    CrownButton.Size = UDim2.fromOffset(28, 30)
    CrownButton.Position = UDim2.new(1, IsCreator and -172 or -172, 0, 8)
    CrownButton.BackgroundColor3 = ButtonDark
    CrownButton.Text = "👑"
    CrownButton.TextColor3 = White
    CrownButton.TextSize = 19
    CrownButton.Font = Enum.Font.GothamBold
    CrownButton.Parent = Header
    CrownButton.ZIndex = 8
    Corner(CrownButton, 8)
    Stroke(CrownButton, Color3.fromRGB(155, 120, 65), 1)
    AddHover(CrownButton, ButtonDark, Color3.fromRGB(65, 53, 37))

    local FeedbackButton = Instance.new("TextButton")
    FeedbackButton.Size = UDim2.fromOffset(28, 30)
    FeedbackButton.Position = UDim2.new(1, -138, 0, 8)
    FeedbackButton.BackgroundColor3 = ButtonDark
    FeedbackButton.Text = "💬"
    FeedbackButton.TextColor3 = White
    FeedbackButton.TextSize = 16
    FeedbackButton.Font = Enum.Font.GothamBold
    FeedbackButton.Parent = Header
    FeedbackButton.ZIndex = 8
    Corner(FeedbackButton, 8)
    Stroke(FeedbackButton, Border, 1)
    AddHover(FeedbackButton, ButtonDark, Color3.fromRGB(55, 48, 69))

    local CommunityPanel = Instance.new("Frame")
    CommunityPanel.Size = UDim2.fromOffset(244, 132)
    CommunityPanel.Position = UDim2.new(1, -254, 0, 56)
    CommunityPanel.BackgroundColor3 = Panel
    CommunityPanel.BorderSizePixel = 0
    CommunityPanel.Visible = false
    CommunityPanel.ZIndex = 20
    CommunityPanel.Parent = Frame
    Corner(CommunityPanel, 10)
    Stroke(CommunityPanel, CurrentAccent and CurrentAccent.Light or PurpleLight, 1.2)
    local CommunityTitle = Label(CommunityPanel, "  CONTRIBUTORS", 13, 28, PurpleLight)
    CommunityTitle.Font = Enum.Font.GothamBold
    CommunityTitle.Position = UDim2.fromOffset(8, 4)
    CommunityTitle.ZIndex = 21
    local CreatorLine = Label(CommunityPanel, "  " .. (LocalPlayer and LocalPlayer.Name or "Creator") .. "  -  CREATOR", 11, 28, White)
    CreatorLine.Position = UDim2.fromOffset(8, 36)
    CreatorLine.ZIndex = 21
    local CommunityNote = Label(CommunityPanel, "  More contributors will be listed here as they join.", 9, 38, Grey)
    CommunityNote.Position = UDim2.fromOffset(8, 68)
    CommunityNote.TextWrapped = true
    CommunityNote.ZIndex = 21
    local CommunityClose = Instance.new("TextButton")
    CommunityClose.Size = UDim2.fromOffset(24, 24)
    CommunityClose.Position = UDim2.new(1, -29, 0, 4)
    CommunityClose.BackgroundColor3 = ButtonDark
    CommunityClose.Text = "❌"
    CommunityClose.TextColor3 = White
    CommunityClose.TextSize = 17
    CommunityClose.Parent = CommunityPanel
    CommunityClose.ZIndex = 22
    Corner(CommunityClose, 6)
    CommunityClose.Activated:Connect(function()
        CommunityPanel.Visible = false
    end)

    local FeedbackPanel = Instance.new("Frame")
    FeedbackPanel.Size = UDim2.fromOffset(244, 226)
    FeedbackPanel.Position = UDim2.new(1, -254, 0, 56)
    FeedbackPanel.BackgroundColor3 = Panel
    FeedbackPanel.BorderSizePixel = 0
    FeedbackPanel.Visible = false
    FeedbackPanel.ZIndex = 20
    FeedbackPanel.Parent = Frame
    Corner(FeedbackPanel, 10)
    Stroke(FeedbackPanel, PurpleLight, 1.2)
    local FeedbackTitle = Label(FeedbackPanel, "  SEND FEEDBACK", 13, 28, PurpleLight)
    FeedbackTitle.Font = Enum.Font.GothamBold
    FeedbackTitle.Position = UDim2.fromOffset(8, 4)
    FeedbackTitle.ZIndex = 21
    local FeedbackClose = Instance.new("TextButton")
    FeedbackClose.Size = UDim2.fromOffset(24, 24)
    FeedbackClose.Position = UDim2.new(1, -29, 0, 4)
    FeedbackClose.BackgroundColor3 = ButtonDark
    FeedbackClose.Text = "❌"
    FeedbackClose.TextColor3 = White
    FeedbackClose.TextSize = 17
    FeedbackClose.Parent = FeedbackPanel
    FeedbackClose.ZIndex = 22
    Corner(FeedbackClose, 6)
    local FeedbackBox = Instance.new("TextBox")
    FeedbackBox.Size = UDim2.new(1, -20, 0, 112)
    FeedbackBox.Position = UDim2.fromOffset(10, 38)
    FeedbackBox.BackgroundColor3 = ButtonDark
    FeedbackBox.TextColor3 = White
    FeedbackBox.PlaceholderColor3 = Grey
    FeedbackBox.PlaceholderText = "Share a feature idea or report..."
    FeedbackBox.Text = ""
    FeedbackBox.TextSize = 11
    FeedbackBox.Font = Enum.Font.Gotham
    FeedbackBox.TextWrapped = true
    FeedbackBox.TextXAlignment = Enum.TextXAlignment.Left
    FeedbackBox.TextYAlignment = Enum.TextYAlignment.Top
    FeedbackBox.MultiLine = true
    FeedbackBox.ClearTextOnFocus = false
    FeedbackBox.Parent = FeedbackPanel
    FeedbackBox.ZIndex = 21
    Corner(FeedbackBox, 7)
    local FeedbackStatus = Label(FeedbackPanel, "Ideas go to the private hub feedback inbox.", 9, 26, Grey)
    FeedbackStatus.Position = UDim2.fromOffset(10, 154)
    FeedbackStatus.TextWrapped = true
    FeedbackStatus.ZIndex = 21
    local FeedbackSend = Instance.new("TextButton")
    FeedbackSend.Size = UDim2.new(1, -20, 0, 32)
    FeedbackSend.Position = UDim2.fromOffset(10, 188)
    FeedbackSend.BackgroundColor3 = Purple
    FeedbackSend.Text = "SUBMIT IDEA"
    FeedbackSend.TextColor3 = White
    FeedbackSend.TextSize = 11
    FeedbackSend.Font = Enum.Font.GothamBold
    FeedbackSend.Parent = FeedbackPanel
    FeedbackSend.ZIndex = 21
    Corner(FeedbackSend, 7)
    FeedbackButton.Visible = false
    FeedbackButton.Active = false
    FeedbackClose.Activated:Connect(function()
        FeedbackPanel.Visible = false
    end)
    FeedbackSend.Activated:Connect(function()
        local message = tostring(FeedbackBox.Text or ""):gsub("^%s*(.-)%s*$", "%1")
        if #message < 8 then
            FeedbackStatus.Text = "Please enter a little more detail."
            return
        end
        if #message > 1500 then
            FeedbackStatus.Text = "Please keep feedback under 1,500 characters."
            return
        end
        local requestFunction
        if type(request) == "function" then requestFunction = request
        elseif type(http_request) == "function" then requestFunction = http_request
        elseif syn and type(syn.request) == "function" then requestFunction = syn.request
        elseif http and type(http.request) == "function" then requestFunction = http.request
        elseif fluxus and type(fluxus.request) == "function" then requestFunction = fluxus.request end
        if not requestFunction then
            FeedbackStatus.Text = "This executor has no HTTP request API."
            return
        end
        FeedbackSend.Text = "SENDING..."
        FeedbackSend.Active = false
        task.spawn(function()
            local HttpService = game:GetService("HttpService")
            local ok, response = pcall(function()
                return requestFunction({
                    Url = "https://shortname-report-receive.ryft-amv.workers.dev/feedback",
                    Method = "POST",
                    Timeout = 30,
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = HttpService:JSONEncode({ message = message })
                })
            end)
            local statusCode = type(response) == "table" and (response.StatusCode or response.Status or response.status_code) or nil
            local body = type(response) == "table" and (response.Body or response.body or "") or ""
            local decodedOk, decoded = pcall(function() return HttpService:JSONDecode(body) end)
            if ok and statusCode == 200 and decodedOk and type(decoded) == "table" and decoded.ok == true then
                FeedbackStatus.Text = "Thanks! Your idea was sent."
                FeedbackBox.Text = ""
            else
                FeedbackStatus.Text = "Could not send feedback. Try again later."
            end
            FeedbackSend.Text = "SUBMIT IDEA"
            FeedbackSend.Active = true
        end)
    end)

    -- SIDEBAR
    local SidebarWidth = math.min(166, WindowWidth * 0.28); local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Name = "Sidebar"
    Sidebar.Position = UDim2.fromOffset(14, 62); Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -76)
    Sidebar.BackgroundColor3 = Panel; Sidebar.BackgroundTransparency = 1; Sidebar.BorderSizePixel = 0
    Sidebar.CanvasSize = UDim2.fromOffset(0, 0); Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.None
    Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y; Sidebar.ScrollingEnabled = true
    Sidebar.ScrollBarThickness = 4; Sidebar.ScrollBarImageColor3 = Purple; Sidebar.Active = true
    Sidebar.ClipsDescendants = true; Sidebar.Parent = Frame
    local SideLayout = Instance.new("UIListLayout"); SideLayout.Padding = UDim.new(0, 7)
    SideLayout.SortOrder = Enum.SortOrder.LayoutOrder; SideLayout.Parent = Sidebar
    local SidePadding = Instance.new("UIPadding")
    SidePadding.PaddingTop = UDim.new(0, 9); SidePadding.PaddingLeft = UDim.new(0, 8); SidePadding.PaddingRight = UDim.new(0, 8)
    SidePadding.PaddingBottom = UDim.new(0, 9); SidePadding.Parent = Sidebar
    SideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.fromOffset(0, SideLayout.AbsoluteContentSize.Y + 18)
    end)

    local SidebarSearch = Instance.new("TextBox")
    SidebarSearch.Name = "SidebarSearch"; SidebarSearch.LayoutOrder = 0
    SidebarSearch.Size = UDim2.new(1, 0, 0, 34); SidebarSearch.BackgroundColor3 = ButtonDark
    SidebarSearch.BackgroundTransparency = 0.08; SidebarSearch.BorderSizePixel = 0
    SidebarSearch.Text = ""; SidebarSearch.PlaceholderText = "Search tabs..."
    SidebarSearch.PlaceholderColor3 = Grey; SidebarSearch.TextColor3 = White
    SidebarSearch.TextSize = 10; SidebarSearch.Font = Enum.Font.Gotham
    SidebarSearch.ClearTextOnFocus = false; SidebarSearch.TextXAlignment = Enum.TextXAlignment.Left
    SidebarSearch.Parent = Sidebar; Corner(SidebarSearch, 8); Stroke(SidebarSearch, Border, 1)

    local function MakeNav(text, order)
        local b = Instance.new("TextButton"); b.Name = text; b.LayoutOrder = order
        b.Size = UDim2.new(1, 0, 0, 42); b.BackgroundColor3 = ButtonDark; b.BackgroundTransparency = 1; b.TextColor3 = Grey
        b.Text = text; b:SetAttribute("SNHFullText", text); b:SetAttribute("SNHShortText", text:match("^([^%s]+)") or "-"); b.TextSize = WindowWidth < 380 and 11 or 12; b.Font = Enum.Font.GothamMedium
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Parent = Sidebar; Corner(b, 9)
        local navStroke = Stroke(b, Border, 1)
        navStroke.Transparency = 1
        return b
    end

    local PlayerAdminUI = {}
    GUI.UpdatesNav = MakeNav("📰  Updates", 1)
    if IsCreator then PlayerAdminUI.Nav = MakeNav("👥  Players", 2) end
    local PlayerToolsNav = MakeNav("🛠️  Player Tools", IsCreator and 3 or 2)
    local GameNav = MakeNav("🎮  Noob Incremental", IsCreator and 4 or 3)
    GUI.GuessSlapperNav = game.PlaceId == 106683702021527 and MakeNav("🖐️  Guess the Slapper", IsCreator and 5 or 4) or nil
    local FightNav = MakeNav("⚔️  Fight on a Baseplate", IsCreator and 6 or 5)
    DetectionNav = IsCreator and MakeNav("🧭  Detection & Observation", 7) or nil
    local SoonNav = MakeNav("➕  Coming Soon", IsCreator and 8 or 6)

    local SidebarNavButtons = { GUI.UpdatesNav, PlayerAdminUI.Nav, PlayerToolsNav, GameNav, GUI.GuessSlapperNav, FightNav, DetectionNav, SoonNav }
    local function FilterSidebar(query)
        query = tostring(query or ""):lower():gsub("^%s*(.-)%s*$", "%1")
        for _, nav in ipairs(SidebarNavButtons) do
            if nav then
                local fullText = tostring(nav:GetAttribute("SNHFullText") or nav.Name)
                nav.Visible = query == "" or fullText:lower():find(query, 1, true) ~= nil
            end
        end
    end
    SidebarSearch:GetPropertyChangedSignal("Text"):Connect(function()
        FilterSidebar(SidebarSearch.Text)
    end)

    -- CONTENT AREA
    local Content = Instance.new("Frame"); Content.Position = UDim2.new(0, SidebarWidth + 20, 0, 58); Content.Size = UDim2.new(1, -SidebarWidth - 30,
    1, -68)
    Content.BackgroundColor3 = Panel; Content.BackgroundTransparency = 0.18; Content.BorderSizePixel = 0; Content.Parent = Frame
    Corner(Content, 13); AddGradient(Content, Color3.fromRGB(27, 26, 37), Panel, 90); Stroke(Content, Border, 1)

    GUI.SidebarCollapsed = false
    GUI.SidebarToggle = Instance.new("TextButton")
    GUI.SidebarToggle.Name = "SidebarToggle"
    GUI.SidebarToggle.Size = UDim2.fromOffset(26, 30)
    GUI.SidebarToggle.Position = UDim2.new(1, IsCreator and -342 or -274, 0, 8)
    GUI.SidebarToggle.BackgroundColor3 = ButtonDark
    GUI.SidebarToggle.Text = "☰"
    GUI.SidebarToggle.TextColor3 = White
    GUI.SidebarToggle.TextSize = 15
    GUI.SidebarToggle.Font = Enum.Font.GothamBold
    GUI.SidebarToggle.Parent = Header
    GUI.SidebarToggle.ZIndex = 8
    Corner(GUI.SidebarToggle, 8)
    Stroke(GUI.SidebarToggle, Border, 1)
    GUI.SidebarToggle.Activated:Connect(function()
        GUI.SidebarCollapsed = not GUI.SidebarCollapsed
        SidebarWidth = GUI.SidebarCollapsed and 58 or math.min(166, WindowWidth * 0.28)
        Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -76)
        SidebarSearch.Visible = not GUI.SidebarCollapsed
        if GUI.SidebarCollapsed then
            SidebarSearch.Text = ""
        end
        Content.Position = UDim2.new(0, SidebarWidth + 20, 0, 58)
        Content.Size = UDim2.new(1, -SidebarWidth - 30, 1, -68)
        for _, nav in pairs({ GUI.UpdatesNav, PlayerAdminUI.Nav, PlayerToolsNav, GameNav, GUI.GuessSlapperNav, FightNav, SoonNav }) do
            if nav then
                nav.Text = GUI.SidebarCollapsed and (nav:GetAttribute("SNHShortText") or "-") or (nav:GetAttribute("SNHFullText") or nav.Name)
                nav.TextXAlignment = GUI.SidebarCollapsed and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
                nav.TextSize = GUI.SidebarCollapsed and 16 or (WindowWidth < 380 and 11 or 12)
            end
        end
        GUI.SidebarToggle.Text = GUI.SidebarCollapsed and ">" or "M"
    end)

    local function MakePage(name)
        local page = Instance.new("ScrollingFrame"); page.Name = name; page.Size = UDim2.new(1, -16, 1, -16)
        page.Position = UDim2.fromOffset(8, 8); page.BackgroundTransparency = 1; page.BorderSizePixel = 0
        page.ScrollBarThickness = 5; page.ScrollBarImageColor3 = Purple; page.CanvasSize = UDim2.fromOffset(0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.None; page.ScrollingDirection = Enum.ScrollingDirection.Y
        page.ScrollingEnabled = true; page.Active = true; page.ClipsDescendants = true
        page.Visible = false; page.Parent = Content; local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 11); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = page
        local padding = Instance.new("UIPadding"); padding.PaddingBottom = UDim.new(0, 10); padding.Parent = page

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.fromOffset(
                0,
                layout.AbsoluteContentSize.Y + 15
            )
        end)
        return page
    end

    GUI.UpdatesPage = MakePage("Updates"); local SettingsPage = MakePage("Settings"); PlayerAdminUI.Page = IsCreator and MakePage("Players") or nil
    local PlayerToolsPage = MakePage("PlayerTools")
    local GamePage = MakePage("NoobIncremental")
    GUI.GuessSlapperPage = MakePage("GuessTheSlapper")
    local FightPage = MakePage("FightOnABaseplate"); local DetectionPage = IsCreator and MakePage("Detection") or nil; local SoonPage = MakePage("ComingSoon"); local CurrentPage = nil; local CurrentAccent = { Color = Purple, Light = PurpleLight, Active =
    Color3.fromRGB(55, 42, 77) }

    local function SelectPage(page)
        local pages = { Updates = GUI.UpdatesPage, Settings = SettingsPage, Players = PlayerAdminUI.Page, PlayerTools = PlayerToolsPage, Game = GamePage, GuessSlapper = GUI.GuessSlapperPage, Fight = FightPage, Detection = DetectionPage, Soon = SoonPage }
        for name, pageObject in pairs(pages) do
            if name == page then
                pageObject.Visible = true
                if GUI.AnimationsEnabled then
                    pageObject.Position = UDim2.fromOffset(18, 8)
                    Tween(pageObject, { Position = UDim2.fromOffset(8, 8) }, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
                else
                    pageObject.Position = UDim2.fromOffset(8, 8)
                end
                pageObject.CanvasPosition = Vector2.new(0, 0)
            else
                pageObject.Visible = false
            end
        end

        CurrentPage = page; local activeColor = CurrentAccent.Active

        local function StyleNav(button, active)
            Tween(button, { BackgroundColor3 = active and activeColor or ButtonDark, BackgroundTransparency = active and 0.08 or 1 }); local outline = button:FindFirstChildOfClass("UIStroke")
            if outline then
                Tween(outline, { Color = active and PurpleLight or Border, Transparency = active and 0.08 or 1, Thickness = active and 1.35 or 1 })
            end
            if ThemeModule and type(ThemeModule.ApplyGlow) == "function" then
                ThemeModule.ApplyGlow(button, CurrentAccent.Color, active)
            end
            button.TextColor3 = active
            and Color3.fromRGB(255, 255, 255)
            or Grey
        end

        StyleNav(GUI.UpdatesNav, page == "Updates")
        if PlayerAdminUI.Nav then StyleNav(PlayerAdminUI.Nav, page == "Players") end
        StyleNav(PlayerToolsNav, page == "PlayerTools")
        StyleNav(GameNav, page == "Game")
        if GUI.GuessSlapperNav then StyleNav(GUI.GuessSlapperNav, page == "GuessSlapper") end
        StyleNav(FightNav, page == "Fight"); if DetectionNav then StyleNav(DetectionNav, page == "Detection") end; StyleNav(SoonNav, page == "Soon")
    end

    do
        GUI.GlobalSearchButton = Instance.new("TextButton")
        GUI.GlobalSearchButton.Name = "GlobalSearchButton"
        GUI.GlobalSearchButton.Size = UDim2.fromOffset(26, 30)
        GUI.GlobalSearchButton.Position = UDim2.new(1, IsCreator and -376 or -308, 0, 8)
        GUI.GlobalSearchButton.BackgroundColor3 = ButtonDark
        GUI.GlobalSearchButton.Text = "🔎"
        GUI.GlobalSearchButton.TextColor3 = White
        GUI.GlobalSearchButton.TextSize = 19
        GUI.GlobalSearchButton.Font = Enum.Font.GothamBold
        GUI.GlobalSearchButton.Parent = Header
        GUI.GlobalSearchButton.ZIndex = 8
        Corner(GUI.GlobalSearchButton, 8)
        Stroke(GUI.GlobalSearchButton, Border, 1)

        local searchPanel = Instance.new("Frame")
        searchPanel.Name = "GlobalSearchPanel"
        searchPanel.AnchorPoint = Vector2.new(0.5, 0.5)
        searchPanel.Position = UDim2.fromScale(0.5, 0.5)
        searchPanel.Size = UDim2.fromOffset(math.min(380, WindowWidth - 24), math.min(350, WindowHeight - 24))
        searchPanel.BackgroundColor3 = Panel
        searchPanel.Visible = false
        searchPanel.ZIndex = 70
        searchPanel.Parent = Frame
        Corner(searchPanel, 12)
        Stroke(searchPanel, CurrentAccent.Light, 1.3)

        local searchTitle = Label(searchPanel, "GLOBAL SEARCH", 13, 28, CurrentAccent.Light)
        searchTitle.Position = UDim2.fromOffset(12, 7)
        searchTitle.Font = Enum.Font.GothamBold
        local searchClose = Instance.new("TextButton")
        searchClose.Size = UDim2.fromOffset(26, 26)
        searchClose.Position = UDim2.new(1, -34, 0, 5)
        searchClose.BackgroundColor3 = ButtonDark
        searchClose.Text = "❌"
        searchClose.TextColor3 = White
        searchClose.TextSize = 17
        searchClose.Parent = searchPanel
        searchClose.ZIndex = 71
        Corner(searchClose, 7)
        searchClose.Activated:Connect(function() searchPanel.Visible = false end)

        local searchInput = Instance.new("TextBox")
        searchInput.Size = UDim2.new(1, -20, 0, 36)
        searchInput.Position = UDim2.fromOffset(10, 40)
        searchInput.BackgroundColor3 = ButtonDark
        searchInput.TextColor3 = White
        searchInput.PlaceholderColor3 = Grey
        searchInput.PlaceholderText = "Search pages, settings, features, tools..."
        searchInput.Text = ""
        searchInput.TextSize = 11
        searchInput.Font = Enum.Font.Gotham
        searchInput.ClearTextOnFocus = false
        searchInput.Parent = searchPanel
        searchInput.ZIndex = 71
        Corner(searchInput, 8)
        Stroke(searchInput, Border, 1)

        local results = Instance.new("ScrollingFrame")
        results.Size = UDim2.new(1, -20, 1, -88)
        results.Position = UDim2.fromOffset(10, 82)
        results.BackgroundColor3 = ButtonDark
        results.BorderSizePixel = 0
        results.ScrollBarThickness = 5
        results.CanvasSize = UDim2.fromOffset(0, 0)
        results.AutomaticCanvasSize = Enum.AutomaticSize.None
        results.ScrollingDirection = Enum.ScrollingDirection.Y
        results.ScrollingEnabled = true
        results.Active = true
        results.ZIndex = 71
        results.Parent = searchPanel
        Corner(results, 8)
        local resultsLayout = Instance.new("UIListLayout")
        resultsLayout.Padding = UDim.new(0, 4)
        resultsLayout.Parent = results
        local resultsPadding = Instance.new("UIPadding")
        resultsPadding.PaddingTop = UDim.new(0, 5)
        resultsPadding.PaddingLeft = UDim.new(0, 5)
        resultsPadding.PaddingRight = UDim.new(0, 5)
        resultsPadding.Parent = results
        resultsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            results.CanvasSize = UDim2.fromOffset(0, resultsLayout.AbsoluteContentSize.Y + 12)
        end)

        local function rebuildResults()
            for _, child in ipairs(results:GetChildren()) do
                if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
            end
            local query = tostring(searchInput.Text or ""):lower():gsub("^%s*(.-)%s*$", "%1")
            if query == "" then
                local hint = Label(results, "Type to search across the hub.", 10, 28, Grey)
                hint.ZIndex = 72
                return
            end
            local count = 0
            for _, object in ipairs(Content:GetDescendants()) do
                if count >= 18 then break end
                if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                    local value = tostring(object.Text or "")
                    if object:IsA("TextBox") then value = value .. " " .. tostring(object.PlaceholderText or "") end
                    if value ~= "" and value:lower():find(query, 1, true) then
                        local pageObject = object
                        while pageObject and pageObject.Parent ~= Content do
                            pageObject = pageObject.Parent
                        end
                        if pageObject then
                            local pageKey = pageObject.Name
                            local pageName = ({
                                Updates = "Updates", Settings = "Settings", Players = "Players",
                                PlayerTools = "PlayerTools", NoobIncremental = "Game", GuessTheSlapper = "GuessSlapper",
                                FightOnABaseplate = "Fight", ComingSoon = "Soon"
                            })[pageKey]
                            if pageName then
                                count += 1
                                local resultButton = Instance.new("TextButton")
                                resultButton.Size = UDim2.new(1, 0, 0, 30)
                                resultButton.BackgroundColor3 = Panel
                                resultButton.TextColor3 = White
                                resultButton.TextSize = 10
                                resultButton.Font = Enum.Font.GothamMedium
                                resultButton.TextXAlignment = Enum.TextXAlignment.Left
                                resultButton.Text = "  " .. string.sub(value:gsub("%s+", " "), 1, 54) .. "   -   " .. pageKey
                                resultButton.Parent = results
                                resultButton.ZIndex = 72
                                Corner(resultButton, 6)
                                resultButton.Activated:Connect(function()
                                    SelectPage(pageName)
                                    searchInput:ReleaseFocus()
                                    searchPanel.Visible = false
                                end)
                            end
                        end
                    end
                end
            end
            if count == 0 then
                local empty = Label(results, "No matching pages or features found.", 10, 28, Grey)
                empty.ZIndex = 72
            end
        end
        searchInput:GetPropertyChangedSignal("Text"):Connect(rebuildResults)
        GUI.GlobalSearchButton.Activated:Connect(function()
            searchPanel.Visible = not searchPanel.Visible
            if searchPanel.Visible then
                searchInput:CaptureFocus()
                rebuildResults()
            end
        end)
        GUI.GlobalSearchPanel = searchPanel
    end
    GUI.UpdatesNav.Activated:Connect(function() SelectPage("Updates") end)
    if PlayerAdminUI.Nav then
        PlayerAdminUI.Nav.Activated:Connect(function() SelectPage("Players") end)
    end
    CrownButton.Activated:Connect(function()
        CommunityPanel.Visible = not CommunityPanel.Visible
        FeedbackPanel.Visible = false
    end)
    if GearButton then
        GearButton.Activated:Connect(function()
            CommunityPanel.Visible = false
            FeedbackPanel.Visible = false
            SelectPage("Settings")
        end)
    end
    PlayerToolsNav.Activated:Connect(function()
        SelectPage("PlayerTools")
    end)
    GameNav.Activated:Connect(function()
        SelectPage("Game")
    end)
    if GUI.GuessSlapperNav then
        GUI.GuessSlapperNav.Activated:Connect(function()
            SelectPage("GuessSlapper")
        end)
    end
    FightNav.Activated:Connect(function()
        SelectPage("Fight")
    end)
    if DetectionNav then
        DetectionNav.Activated:Connect(function()
            if OwnerViewEnabled then SelectPage("Detection") end
        end)
    end
    SoonNav.Activated:Connect(function()
        SelectPage("Soon")
    end)

    -- SETTINGS
    Label(SettingsPage, "SETTINGS", 17, 30).Font = Enum.Font.GothamBold; Label(SettingsPage, "Personalize your hub experience.", 12, 23, Grey)
    do
        local searchBox = Instance.new("TextBox")
        searchBox.Name = "SettingsSearch"
        searchBox.Size = UDim2.new(1, 0, 0, 34)
        searchBox.BackgroundColor3 = ButtonDark
        searchBox.TextColor3 = White
        searchBox.PlaceholderColor3 = Grey
        searchBox.PlaceholderText = "Search settings..."
        searchBox.Text = ""
        searchBox.TextSize = 11
        searchBox.Font = Enum.Font.Gotham
        searchBox.ClearTextOnFocus = false
        searchBox.Parent = SettingsPage
        Corner(searchBox, 8)
        Stroke(searchBox, Border, 1)
        local function matchesSearch(object, query)
            if query == "" then return true end
            local function checkText(item)
                if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then
                    local content = tostring(item.Text or "")
                    if item:IsA("TextBox") then content = content .. " " .. tostring(item.PlaceholderText or "") end
                    if content:lower():find(query, 1, true) then return true end
                end
                return false
            end
            if checkText(object) then return true end
            for _, descendant in ipairs(object:GetDescendants()) do
                if checkText(descendant) then return true end
            end
            return false
        end
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local query = tostring(searchBox.Text or ""):lower():gsub("^%s*(.-)%s*$", "%1")
            for _, child in ipairs(SettingsPage:GetChildren()) do
                if child:IsA("GuiObject") and child ~= searchBox then
                    child.Visible = matchesSearch(child, query)
                end
            end
        end)
    end
    Label(SettingsPage, "APPEARANCE", 13, 25, PurpleLight).Font = Enum.Font.GothamBold; Label(SettingsPage, "Accent color", 11, 19, Grey)

    local AccentPresets = {
        { Name = "Purple", Color = Color3.fromRGB(145, 75, 255), Light = Color3.fromRGB(185, 135, 255), Active = Color3.fromRGB(55, 42, 77) },
        { Name = "Blue", Color = Color3.fromRGB(65, 145, 255), Light = Color3.fromRGB(135, 195, 255), Active = Color3.fromRGB(35, 57, 85) },
        { Name = "Red", Color = Color3.fromRGB(235, 75, 95), Light = Color3.fromRGB(255, 145, 155), Active = Color3.fromRGB(82, 39, 48) },
        { Name = "Green", Color = Color3.fromRGB(55, 190, 125), Light = Color3.fromRGB(125, 235, 175), Active = Color3.fromRGB(35, 72, 55) },
        { Name = "Cyan", Color = Color3.fromRGB(35, 190, 205), Light = Color3.fromRGB(120, 235, 240), Active = Color3.fromRGB(32, 70, 78) }
    }

    local function IsAccentColor(c)
        return c == Purple
        or c == PurpleLight
        or c == CurrentAccent.Active
        or c == CurrentAccent.Light
        or c == CurrentAccent.Color
        or c == Color3.fromRGB(75, 50, 115)
        or c == Color3.fromRGB(100, 65, 160)
        or c == Color3.fromRGB(75, 55, 115)
        or c == Color3.fromRGB(94, 68, 137)
    end

    -- Always derive theme surfaces from the original palette, never the last selected accent.
    local AccentBaseDark = Color3.fromRGB(12, 12, 17)
    local AccentBasePanel = Color3.fromRGB(23, 23, 31)
    local AccentBaseButton = Color3.fromRGB(31, 31, 42)
    local AccentBaseBorder = Color3.fromRGB(54, 48, 70)

    local function ApplyAccent(preset)
        local oldAccent = CurrentAccent
        local oldDark, oldPanel, oldButton, oldBorder = Dark, Panel, ButtonDark, Border
        local palette = ThemeModule and type(ThemeModule.Build) == "function"
            and ThemeModule.Build(preset.Color) or nil
        local nextDark = palette and palette.Dark or AccentBaseDark:Lerp(preset.Color, 0.14)
        local nextPanel = palette and palette.Panel or AccentBasePanel:Lerp(preset.Color, 0.19)
        local nextButton = palette and palette.Button or AccentBaseButton:Lerp(preset.Color, 0.24)
        local nextBorder = palette and palette.Border or AccentBaseBorder:Lerp(preset.Color, 0.45)
        if palette then
            preset.Light = palette.Light
            preset.Active = palette.Active
        end
        for _, obj in ipairs(ScreenGui:GetDescendants()) do
            if obj:IsA("GuiObject") then
                local bg = obj.BackgroundColor3
                if bg == oldDark then
                    obj.BackgroundColor3 = nextDark
                elseif bg == oldPanel then
                    obj.BackgroundColor3 = nextPanel
                elseif bg == oldButton then
                    obj.BackgroundColor3 = nextButton
                elseif bg == oldAccent.Active or bg == Color3.fromRGB(75, 50, 115) or bg == Color3.fromRGB(100, 65, 160) then
                    obj.BackgroundColor3 = preset.Active
                end
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    if obj.TextColor3 == Purple or obj.TextColor3 == PurpleLight or obj.TextColor3 == oldAccent.Light then
                        obj.TextColor3 = preset.Light
                    end
                end
                if obj:IsA("ScrollingFrame") and obj.ScrollBarImageColor3 == oldAccent.Color then
                    obj.ScrollBarImageColor3 = preset.Color
                end
            elseif obj:IsA("UIStroke") then
                if IsAccentColor(obj.Color) then
                    obj.Color = preset.Light
                elseif obj.Color == oldBorder then
                    obj.Color = nextBorder
                end
            elseif obj:IsA("UIGradient") then
                if obj.Parent == AccentLine then
                    obj.Color = ColorSequence.new(preset.Light, preset.Color)
                elseif obj.Parent == Frame then
                    obj.Color = ColorSequence.new(AccentBaseDark:Lerp(preset.Color, 0.12), nextDark)
                elseif obj.Parent == Header or obj.Parent == Sidebar or obj.Parent == Content then
                    obj.Color = ColorSequence.new(nextPanel, nextDark)
                end
            end
        end
        Dark = nextDark
        Panel = nextPanel
        ButtonDark = nextButton
        Border = nextBorder
        Purple = preset.Color
        PurpleLight = preset.Light
        CurrentAccent = preset
        for _, nav in pairs({ GUI.UpdatesNav, PlayerAdminUI.Nav, PlayerToolsNav, GameNav, GUI.GuessSlapperNav, FightNav, SoonNav }) do
            if nav then
            local active = (CurrentPage == "Updates" and nav == GUI.UpdatesNav)
                or (CurrentPage == "Players" and nav == PlayerAdminUI.Nav)
                or (CurrentPage == "PlayerTools" and nav == PlayerToolsNav)
                or (CurrentPage == "Game" and nav == GameNav)
                or (CurrentPage == "GuessSlapper" and nav == GUI.GuessSlapperNav)
                or (CurrentPage == "Fight" and nav == FightNav)
                or (CurrentPage == "Soon" and nav == SoonNav)
            nav.BackgroundColor3 = active and preset.Active or nextButton
            nav.BackgroundTransparency = active and 0.08 or 1
            local stroke = nav:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = active and preset.Light or nextBorder
                stroke.Transparency = active and 0.08 or 1
            end
            end
        end
    end

    local ColorRow = Instance.new("Frame"); ColorRow.Size = UDim2.new(1, 0, 0, 34); ColorRow.BackgroundTransparency = 1
    ColorRow.Parent = SettingsPage; local ColorLayout = Instance.new("UIListLayout"); ColorLayout.FillDirection = Enum.FillDirection.Horizontal
    ColorLayout.Padding = UDim.new(0, 5); ColorLayout.Parent = ColorRow

    for _, preset in ipairs(AccentPresets) do
        local b = Instance.new("TextButton"); b.Size = UDim2.new(0.2, -4, 1, 0); b.BackgroundColor3 = preset.Color
        b.Text = preset.Name; b.TextColor3 = Color3.new(1, 1, 1); b.TextSize = 9
        b.Font = Enum.Font.GothamBold; b.Parent = ColorRow; Corner(b, 7)
        Stroke(b, preset.Light, 1); AddHover(b, preset.Color, preset.Light)
        b.Activated:Connect(function()
            ApplyAccent(preset)
        end)
    end
    do
        local customAccentBox = Instance.new("TextBox")
        customAccentBox.Size = UDim2.new(1, 0, 0, 34)
        customAccentBox.BackgroundColor3 = ButtonDark
        customAccentBox.TextColor3 = White
        customAccentBox.PlaceholderColor3 = Grey
        customAccentBox.PlaceholderText = "Custom accent hex (example: #8B5CF6)"
        customAccentBox.Text = ""
        customAccentBox.TextSize = 11
        customAccentBox.Font = Enum.Font.Gotham
        customAccentBox.ClearTextOnFocus = false
        customAccentBox.Parent = SettingsPage
        Corner(customAccentBox, 8)
        Stroke(customAccentBox, Border, 1)
        local applyCustomAccent = Instance.new("TextButton")
        applyCustomAccent.Size = UDim2.new(1, 0, 0, 32)
        applyCustomAccent.BackgroundColor3 = ButtonDark
        applyCustomAccent.TextColor3 = White
        applyCustomAccent.Text = "APPLY CUSTOM ACCENT"
        applyCustomAccent.TextSize = 10
        applyCustomAccent.Font = Enum.Font.GothamBold
        applyCustomAccent.Parent = SettingsPage
        Corner(applyCustomAccent, 8)
        Stroke(applyCustomAccent, Border, 1)
        applyCustomAccent.Activated:Connect(function()
            local hex = tostring(customAccentBox.Text or ""):gsub("#", ""):gsub("%s+", "")
            local red, green, blue = hex:match("^(%x%x)(%x%x)(%x%x)$")
            if not red then
                applyCustomAccent.Text = "ENTER HEX LIKE #8B5CF6"
                return
            end
            local color = Color3.fromRGB(tonumber(red, 16), tonumber(green, 16), tonumber(blue, 16))
            ApplyAccent({
                Name = "Custom",
                Color = color,
                Light = color:Lerp(Color3.new(1, 1, 1), 0.28),
                Active = ButtonDark:Lerp(color, 0.62)
            })
            applyCustomAccent.Text = "CUSTOM ACCENT APPLIED"
        end)
    end

    Label(SettingsPage, "Background style", 11, 19, Grey)
    local SurfacePresets = {
        { Name = "MIDNIGHT", Dark = Color3.fromRGB(12, 12, 17), Panel = Color3.fromRGB(23, 23, 31), Button = Color3.fromRGB(31, 31, 42), Border = Color3.fromRGB(54, 48, 70), Top = Color3.fromRGB(19, 18, 27) },
        { Name = "BLACKOUT", Dark = Color3.fromRGB(5, 5, 8), Panel = Color3.fromRGB(14, 14, 19), Button = Color3.fromRGB(23, 23, 30), Border = Color3.fromRGB(43, 43, 55), Top = Color3.fromRGB(10, 10, 15) },
        { Name = "SLATE", Dark = Color3.fromRGB(18, 22, 32), Panel = Color3.fromRGB(29, 35, 49), Button = Color3.fromRGB(39, 47, 64), Border = Color3.fromRGB(65, 76, 98), Top = Color3.fromRGB(29, 34, 48) }
    }
    local SurfaceRow = Instance.new("Frame")
    SurfaceRow.Size = UDim2.new(1, 0, 0, 32)
    SurfaceRow.BackgroundTransparency = 1
    SurfaceRow.Parent = SettingsPage
    local SurfaceLayout = Instance.new("UIListLayout")
    SurfaceLayout.FillDirection = Enum.FillDirection.Horizontal
    SurfaceLayout.Padding = UDim.new(0, 5)
    SurfaceLayout.Parent = SurfaceRow

    local ActiveSurfacePreset = SurfacePresets[1]
    local function ApplySurfaceTheme(preset)
        local oldDark, oldPanel, oldButton, oldBorder = Dark, Panel, ButtonDark, Border
        for _, obj in ipairs(ScreenGui:GetDescendants()) do
            if obj:IsA("GuiObject") then
                if obj.BackgroundColor3 == oldDark then
                    obj.BackgroundColor3 = preset.Dark
                elseif obj.BackgroundColor3 == oldPanel then
                    obj.BackgroundColor3 = preset.Panel
                elseif obj.BackgroundColor3 == oldButton then
                    obj.BackgroundColor3 = preset.Button
                end
                if obj:IsA("TextButton") and obj:GetAttribute("SNHNormalColor") == oldButton then
                    obj:SetAttribute("SNHNormalColor", preset.Button)
                end
            elseif obj:IsA("UIStroke") and obj.Color == oldBorder then
                obj.Color = preset.Border
            elseif obj:IsA("UIGradient") then
                if obj.Parent == Frame then
                    obj.Color = ColorSequence.new(preset.Top, preset.Dark)
                elseif obj.Parent == Header then
                    obj.Color = ColorSequence.new(preset.Panel, preset.Dark)
                end
            end
        end
        Dark, Panel, ButtonDark, Border = preset.Dark, preset.Panel, preset.Button, preset.Border
        ActiveSurfacePreset = preset
    end

    for _, preset in ipairs(SurfacePresets) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1 / 3, -4, 1, 0)
        b.BackgroundColor3 = preset.Button
        b.Text = preset.Name
        b.TextColor3 = White
        b.TextSize = 9
        b.Font = Enum.Font.GothamBold
        b.Parent = SurfaceRow
        Corner(b, 7)
        Stroke(b, preset.Border, 1)
        AddHover(b, preset.Button, preset.Panel)
        b.Activated:Connect(function()
            ApplySurfaceTheme(preset)
            for _, sibling in ipairs(SurfaceRow:GetChildren()) do
                if sibling:IsA("TextButton") then
                    local stroke = sibling:FindFirstChildOfClass("UIStroke")
                    if stroke then
                        stroke.Color = sibling == b and CurrentAccent.Light or Border
                        stroke.Thickness = sibling == b and 1.5 or 1
                    end
                end
            end
        end)
    end

    Label(SettingsPage, "WINDOW SCALE", 11, 19, Grey)
    GUI.ScaleSlider, GUI.SetScaleSlider = GUI.CreateSlider(SettingsPage, "Interface size", 0.72, 1.1, 1, Purple, function(value)
        WindowScale.Scale = value
    end, function(value) return string.format("%.0f%%", value * 100) end)

    Label(SettingsPage, "WINDOW TRANSPARENCY", 11, 19, Grey)
    GUI.TransparencySlider, GUI.SetTransparencySlider = GUI.CreateSlider(SettingsPage, "Surface transparency", 0, 0.6, 0.12, Purple, function(value)
        Frame.BackgroundTransparency = value
        Header.BackgroundTransparency = math.min(0.7, value * 0.55)
        Content.BackgroundTransparency = math.min(0.72, 0.18 + value * 0.55)
        GUI.BackgroundImage.ImageTransparency = math.clamp(0.34 + value * 0.45, 0, 0.88)
    end, function(value) return string.format("%.0f%%", value * 100) end)

    Label(SettingsPage, "CUSTOM BACKGROUND", 11, 19, Grey)
    GUI.BackgroundUrlBox = Instance.new("TextBox")
    GUI.BackgroundUrlBox.Size = UDim2.new(1, 0, 0, 34)
    GUI.BackgroundUrlBox.BackgroundColor3 = ButtonDark
    GUI.BackgroundUrlBox.TextColor3 = White
    GUI.BackgroundUrlBox.PlaceholderColor3 = Grey
    GUI.BackgroundUrlBox.PlaceholderText = "Roblox image asset ID or asset URL"
    GUI.BackgroundUrlBox.Text = ""
    GUI.BackgroundUrlBox.TextSize = 11
    GUI.BackgroundUrlBox.Font = Enum.Font.Gotham
    GUI.BackgroundUrlBox.ClearTextOnFocus = false
    GUI.BackgroundUrlBox.Parent = SettingsPage
    Corner(GUI.BackgroundUrlBox, 8)
    Stroke(GUI.BackgroundUrlBox, Border, 1)
    Label(SettingsPage, "Roblox asset IDs and Roblox asset URLs work best.", 9, 18, Grey)
    GUI.BackgroundApply = Instance.new("TextButton")
    GUI.BackgroundApply.Size = UDim2.new(1, 0, 0, 34)
    GUI.BackgroundApply.BackgroundColor3 = ButtonDark
    GUI.BackgroundApply.TextColor3 = White
    GUI.BackgroundApply.Text = "APPLY BACKGROUND"
    GUI.BackgroundApply.TextSize = 10
    GUI.BackgroundApply.Font = Enum.Font.GothamBold
    GUI.BackgroundApply.Parent = SettingsPage
    Corner(GUI.BackgroundApply, 8)
    Stroke(GUI.BackgroundApply, Border, 1)
    GUI.BackgroundApply.Activated:Connect(function()
        local value = tostring(GUI.BackgroundUrlBox.Text or ""):gsub("^%s*(.-)%s*$", "%1")
        if value:match("^%d+$") then value = "rbxassetid://" .. value end
        local assetId = value:match("[?&]id=(%d+)")
        if assetId then value = "rbxassetid://" .. assetId end
        if value ~= "" and not value:match("^rbxassetid://%d+$") then
            GUI.BackgroundApply.Text = "USE A ROBLOX IMAGE ASSET"
            return
        end
        GUI.BackgroundImage.Image = value
        GUI.BackgroundApply.Text = value == "" and "BACKGROUND CLEARED" or "BACKGROUND APPLIED"
    end)

    do
        GUI.AnimationsToggle = Instance.new("TextButton")
        GUI.AnimationsToggle.Size = UDim2.new(1, 0, 0, 38)
        GUI.AnimationsToggle.BackgroundColor3 = ButtonDark
        GUI.AnimationsToggle.TextColor3 = White
        GUI.AnimationsToggle.TextSize = 11
        GUI.AnimationsToggle.Font = Enum.Font.GothamBold
        GUI.AnimationsToggle.Parent = SettingsPage
        Corner(GUI.AnimationsToggle, 9)
        Stroke(GUI.AnimationsToggle, Border, 1)
        local function updateAnimationText()
            GUI.AnimationsToggle.Text = "PAGE ANIMATIONS: " .. (GUI.AnimationsEnabled and "ON" or "OFF")
        end
        updateAnimationText()
        GUI.AnimationsToggle.Activated:Connect(function()
            GUI.AnimationsEnabled = not GUI.AnimationsEnabled
            updateAnimationText()
        end)
    end
    Label(SettingsPage, "Changes apply instantly and reset when the hub is reloaded.", 10, 30, Grey); Label(SettingsPage, "GENERAL", 13, 25,
    PurpleLight).Font = Enum.Font.GothamBold
    local PausedDisabled = true

    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(false)
    end)

    local PauseButton = Instance.new("TextButton"); PauseButton.Size = UDim2.new(1, 0, 0, 48); PauseButton.BackgroundColor3 = ButtonDark
    PauseButton.TextColor3 = White; PauseButton.TextSize = 12; PauseButton.Font = Enum.Font.GothamBold
    PauseButton.Parent = SettingsPage; Corner(PauseButton, 9); Stroke(PauseButton, Border, 1)
    AddHover(PauseButton, ButtonDark, Color3.fromRGB(48, 40, 63))

    local function UpdatePauseButton()
        PauseButton.Text = "Gameplay Paused Notification: "
        .. (PausedDisabled and "OFF" or "ON")
    end

    UpdatePauseButton()
    PauseButton.Activated:Connect(function()
        PausedDisabled = not PausedDisabled
        local ok, err = pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not PausedDisabled)
        end)
        UpdatePauseButton()
        if not ok then
            Label(
                SettingsPage,
                "Could not change setting: " .. tostring(err),
                10,
                35,
                Color3.fromRGB(255, 130, 130)
            )
        end
    end)

    Label(SettingsPage, "When OFF, Roblox's gameplay-paused notification is disabled.", 11, 42, Grey)


    local RefreshHubButton = Instance.new("TextButton")
    RefreshHubButton.Size = UDim2.fromOffset(28, 30)
    RefreshHubButton.Position = UDim2.new(1, -104, 0, 8)
    RefreshHubButton.BackgroundColor3 = ButtonDark
    RefreshHubButton.TextColor3 = White
    RefreshHubButton.TextSize = 18
    RefreshHubButton.Font = Enum.Font.GothamBold
    RefreshHubButton.Text = "🔄"
    RefreshHubButton.Parent = Header
    RefreshHubButton.ZIndex = 8
    RefreshHubButton.AutoButtonColor = false
    RefreshHubButton:SetAttribute("SNHTooltip", "Refresh entire hub")
    Corner(RefreshHubButton, 8)
    Stroke(RefreshHubButton, CurrentAccent.Light, 1.2)
    AddHover(RefreshHubButton, ButtonDark, Color3.fromRGB(55, 48, 69))

    local RefreshBusy = false
    RefreshHubButton.Activated:Connect(function()
        if RefreshBusy then
            return
        end
        local refreshAction = RefreshCallback
        if type(refreshAction) ~= "function" then
            -- Fallback for older Main.lua loaders that did not pass the callback.
            refreshAction = function()
                local source = game:HttpGet("https://raw.githubusercontent.com/zexy1zexy-sketch/ShortName-Hub/refs/heads/main/Main.lua")
                local chunk = loadstring(source)
                if type(chunk) ~= "function" then
                    return false, "Could not compile the latest Main.lua."
                end
                chunk()
                return true
            end
        end

        RefreshBusy = true
        RefreshHubButton.Text = "..."
        RefreshHubButton.Active = false
        task.spawn(function()
            local ok, result, detail = pcall(refreshAction)
            if not ok or result == false then
                RefreshBusy = false
                RefreshHubButton.Active = true
                RefreshHubButton.Text = "!"
                warn("ShortName Hub refresh failed: " .. tostring(ok and detail or result))
                task.wait(2)
                if RefreshHubButton.Parent then
                    RefreshHubButton.Text = "🔄"
                end
            end
        end)
    end)

    -- NOOB INCREMENTAL
    Label(GamePage, "NOOB INCREMENTAL", 17, 30).Font = Enum.Font.GothamBold; Label(GamePage, "Tap a folder to show or hide its features.", 12, 22,
    Grey)
    local Status = Label(GamePage, "STATUS: READY", 12, 28, Color3.fromRGB(170, 210, 255)); Status.Font = Enum.Font.GothamBold

    local function SetStatus(text)
        Status.Text = "STATUS: " .. tostring(text)
    end

    -- FOLDER SYSTEM
    local function MakeFolder(name, parent, visible)
        local Folder = Instance.new("Frame"); Folder.Name = name:gsub("%W", "") .. "Folder"; Folder.Size = UDim2.new(1, 0, 0, 38)
        Folder.Visible = visible ~= false or OwnerViewEnabled
        if visible == false then table.insert(OwnerOnlyFolders, Folder) end
        Folder.BackgroundColor3 = ButtonDark; Folder.BorderSizePixel = 0; Folder.ClipsDescendants = true
        Folder.Parent = parent or GamePage; Corner(Folder, 10); Stroke(Folder, Border, 1)
        AddGradient(Folder, Color3.fromRGB(34, 32, 46), ButtonDark, 90); local HeaderButton = Instance.new("TextButton"); HeaderButton.Size =
        UDim2.new(1, 0, 0, 38)
        local FolderIcons = {
            ["HALLOWEEN EVENT"] = "🎃",
            ["THANKSGIVING EVENT"] = "🦃",
            ["EVENT SCANNER"] = "🔎",
            ["FIGHT ON A BASEPLATE"] = "⚔️",
            ["PLAYER TOOLS"] = "🛠️",
            ["DETECTORS"] = "🧭",
            ["DETECTION & OBSERVATION"] = "🧭",
            ["GAME OBJECT SCANNER"] = "🎮",
            ["COMBAT SYSTEM FINDER"] = "🛡️",
            ["COMBAT STRUCTURE FINDER"] = "🏗️",
            ["NPC & TELEPORT"] = "🧍",
            ["REMOTES"] = "📡",
            ["HOUSE TELEPORT"] = "🏠",
            ["COMBAT HUD & ASSET TOOLS"] = "🎯",
            ["WEAPON MOVEMENT OBSERVER"] = "👁️"
        }
        local FolderIcon = FolderIcons[name] or "F"
        HeaderButton.BackgroundTransparency = 1; HeaderButton.Text = FolderIcon .. "  " .. name .. "     +"; HeaderButton.TextColor3 = White
        HeaderButton.TextSize = 12; HeaderButton.Font = Enum.Font.GothamBold; HeaderButton.TextXAlignment = Enum.TextXAlignment.Left
        HeaderButton.AutoButtonColor = false; HeaderButton.TextColor3 = Color3.fromRGB(235, 228, 250); HeaderButton.Parent = Folder
        local FolderContent = Instance.new("Frame"); FolderContent.Position = UDim2.fromOffset(8, 43); FolderContent.Size = UDim2.new(1, -16, 0, 0)
        FolderContent.BackgroundTransparency = 1; FolderContent.Visible = false; FolderContent.Parent = Folder
        local FolderLayout = Instance.new("UIListLayout"); FolderLayout.Padding = UDim.new(0, 7); FolderLayout.SortOrder = Enum.SortOrder.LayoutOrder
        FolderLayout.Parent = FolderContent; local FolderPadding = Instance.new("UIPadding"); FolderPadding.PaddingBottom = UDim.new(0, 8)
        FolderPadding.Parent = FolderContent; local Open = false

        local function UpdateSize()
            local contentHeight = FolderLayout.AbsoluteContentSize.Y + 8
            Tween(FolderContent, { Size = UDim2.new(1, -16, 0, Open and contentHeight or 0) }, TweenInfo.new(0.2, Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out))
            Tween(Folder, { Size = UDim2.new(1, 0, 0, Open and (43 + contentHeight) or 38) }, TweenInfo.new(0.2, Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out))
        end

        HeaderButton.Activated:Connect(function()
            Open = not Open
            FolderContent.Visible = Open
            HeaderButton.Text = FolderIcon .. "  "
            .. name
            .. (Open and "     -" or "     +")
            UpdateSize()
        end)

        FolderLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if Open then
                UpdateSize()
            end
        end)
        return FolderContent
    end

    if OwnerViewButton then
        OwnerViewButton.Activated:Connect(function()
            if not IsCreator then return end
            OwnerViewEnabled = not OwnerViewEnabled
            OwnerViewButton.Text = OwnerViewEnabled and "OWNER VIEW" or "USERS VIEW"
            OwnerViewButton.BackgroundColor3 = OwnerViewEnabled and Color3.fromRGB(55, 42, 77) or ButtonDark
            for _, folder in ipairs(OwnerOnlyFolders) do
                if folder and folder.Parent then folder.Visible = OwnerViewEnabled end
            end
            -- The Players page is creator-only too; hide both its navigation
            -- button and page whenever Users View is active.
            if PlayerAdminUI.Nav and PlayerAdminUI.Nav.Parent then
                PlayerAdminUI.Nav.Visible = OwnerViewEnabled
            end
            if DetectionNav and DetectionNav.Parent then
                DetectionNav.Visible = OwnerViewEnabled
            end
            if PlayerAdminUI.Page and PlayerAdminUI.Page.Parent then
                PlayerAdminUI.Page.Visible = OwnerViewEnabled and CurrentPage == "Players"
            end
            if DetectionPage and DetectionPage.Parent then
                DetectionPage.Visible = OwnerViewEnabled and CurrentPage == "Detection"
            end
            if not OwnerViewEnabled then
                if CurrentPage == "Players" or CurrentPage == "Detection" then
                    SelectPage("Updates")
                end
                CommunityPanel.Visible = false
                FeedbackPanel.Visible = false
            end
        end)
    end

    -- INPUT BOXES
    local function MakeBox(parent, label, value, callback)
        Label(parent, label, 11, 20, Grey); local box = Instance.new("TextBox"); box.Size = UDim2.new(1, 0, 0, 34)
        box.BackgroundColor3 = ButtonDark; box.TextColor3 = White; box.PlaceholderColor3 = Grey
        box.Text = tostring(value); box.TextSize = 13; box.Font = Enum.Font.Gotham
        box.ClearTextOnFocus = false; box.Parent = parent; Corner(box, 8)
        Stroke(box, Border, 1); box.TextXAlignment = Enum.TextXAlignment.Left
        box.FocusLost:Connect(function()
            callback(box.Text)
        end)
        return box
    end

    -- BUTTONS
    local function MakeButton(parent, text, callback, color)
        local b = Instance.new("TextButton"); b.Size = UDim2.new(1, 0, 0, 42); b.BackgroundColor3 = color or Color3.fromRGB(75, 55, 115)
        b.TextColor3 = White; b.Text = text; b.TextSize = 12
        b.Font = Enum.Font.GothamBold; b.Parent = parent; Corner(b, 10)
        Stroke(b, Border, 1); AddHover(b, color or Color3.fromRGB(75, 55, 115), Color3.fromRGB(94, 68, 137)); b.Activated:Connect(callback)
        return b
    end

    -- GUESS THE SLAPPER: live player cards and manual, clearly-labelled observations.
    if GUI.GuessSlapperNav then
        Label(GUI.GuessSlapperPage, "GUESS THE SLAPPER", 17, 30).Font = Enum.Font.GothamBold
        Label(GUI.GuessSlapperPage, "Live server roster. Select a player to mark, inspect, or record your guess.", 10, 30, Grey).TextWrapped = true

        local PlayersService = game:GetService("Players")
        local markedSuspects = {}
        local playerCards = {}
        local rosterStatus = Label(GUI.GuessSlapperPage, "PLAYERS: LOADING...", 11, 24, Color3.fromRGB(170, 210, 255))
        rosterStatus.Font = Enum.Font.GothamBold
        local guessStatus = Label(GUI.GuessSlapperPage, "SLAPPER GUESS: None recorded", 10, 34, Grey)
        guessStatus.TextWrapped = true
        local detailStatus = Label(GUI.GuessSlapperPage, "Select VIEW DETAILS on a player card to inspect their visible character status.", 10, 38, Grey)
        detailStatus.TextWrapped = true

        local rosterFrame = Instance.new("Frame")
        rosterFrame.Name = "LivePlayerCards"
        rosterFrame.Size = UDim2.new(1, 0, 0, 0)
        rosterFrame.AutomaticSize = Enum.AutomaticSize.Y
        rosterFrame.BackgroundTransparency = 1
        rosterFrame.Parent = GUI.GuessSlapperPage
        local rosterLayout = Instance.new("UIListLayout")
        rosterLayout.Padding = UDim.new(0, 8)
        rosterLayout.SortOrder = Enum.SortOrder.Name
        rosterLayout.Parent = rosterFrame

        local refreshRoster
        local function clearCards()
            for _, card in pairs(playerCards) do
                if card and card.Parent then card:Destroy() end
            end
            table.clear(playerCards)
        end

        local function makePlayerCard(player)
            local card = Instance.new("Frame")
            card.Name = string.format("Player_%09d", player.UserId)
            card.Size = UDim2.new(1, 0, 0, 108)
            card.BackgroundColor3 = ButtonDark
            card.BorderSizePixel = 0
            card.Parent = rosterFrame
            Corner(card, 9)
            Stroke(card, markedSuspects[player.UserId] and Color3.fromRGB(235, 170, 95) or Border, 1)

            local nameLabel = Instance.new("TextLabel")
            nameLabel.BackgroundTransparency = 1
            nameLabel.Position = UDim2.fromOffset(10, 7)
            nameLabel.Size = UDim2.new(1, -20, 0, 20)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 12
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextColor3 = White
            nameLabel.Text = player.DisplayName
            nameLabel.Parent = card

            local userLabel = Instance.new("TextLabel")
            userLabel.BackgroundTransparency = 1
            userLabel.Position = UDim2.fromOffset(10, 28)
            userLabel.Size = UDim2.new(1, -20, 0, 17)
            userLabel.Font = Enum.Font.Gotham
            userLabel.TextSize = 10
            userLabel.TextXAlignment = Enum.TextXAlignment.Left
            userLabel.TextColor3 = Grey
            userLabel.Text = "@" .. player.Name .. (player == PlayersService.LocalPlayer and "  •  YOU" or "")
            userLabel.Parent = card

            local function smallButton(text, x, width, color, callback)
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(width, -6, 0, 28)
                button.Position = UDim2.new(x, 3, 0, 68)
                button.BackgroundColor3 = color
                button.Text = text
                button.TextColor3 = White
                button.TextSize = 9
                button.Font = Enum.Font.GothamBold
                button.Parent = card
                Corner(button, 6)
                Stroke(button, Border, 1)
                button.Activated:Connect(callback)
                return button
            end

            smallButton(markedSuspects[player.UserId] and "UNMARK" or "SUSPECT", 0, 0.34, Color3.fromRGB(105, 78, 45), function()
                if markedSuspects[player.UserId] then
                    markedSuspects[player.UserId] = nil
                else
                    markedSuspects[player.UserId] = true
                end
                refreshRoster()
            end)
            smallButton("GUESS SLAPPER", 0.34, 0.38, Color3.fromRGB(80, 65, 125), function()
                guessStatus.Text = "YOUR GUESS: " .. player.DisplayName .. " (@" .. player.Name .. ") — NOT VERIFIED"
                guessStatus.TextColor3 = Color3.fromRGB(235, 190, 115)
            end)
            smallButton("VIEW DETAILS", 0.72, 0.28, Color3.fromRGB(55, 85, 120), function()
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local tool = character and character:FindFirstChildOfClass("Tool")
                local details = "PLAYER: " .. player.DisplayName .. " (@" .. player.Name .. ")"
                details = details .. "\nHEALTH: " .. (humanoid and string.format("%.0f / %.0f", humanoid.Health, humanoid.MaxHealth) or "Unavailable")
                details = details .. "\nCHARACTER: " .. (character and "Spawned" or "Not spawned")
                details = details .. "\nEQUIPPED TOOL: " .. (tool and tool.Name or "None visible")
                if root then
                    details = details .. "\nPOSITION: " .. tostring(math.floor(root.Position.X)) .. ", " .. tostring(math.floor(root.Position.Y)) .. ", " .. tostring(math.floor(root.Position.Z))
                end
                detailStatus.Text = details
            end)
            playerCards[player.UserId] = card
        end

        refreshRoster = function()
            clearCards()
            local currentPlayers = PlayersService:GetPlayers()
            table.sort(currentPlayers, function(a, b)
                return a.DisplayName:lower() < b.DisplayName:lower()
            end)
            rosterStatus.Text = "PLAYERS IN SERVER: " .. tostring(#currentPlayers)
            for _, player in ipairs(currentPlayers) do
                makePlayerCard(player)
            end
            if #currentPlayers == 0 then
                rosterStatus.Text = "PLAYERS IN SERVER: 0"
            end
        end

        MakeButton(GUI.GuessSlapperPage, "REFRESH PLAYER CARDS", refreshRoster, Color3.fromRGB(65, 90, 125))
        local identificationTitle = Label(GUI.GuessSlapperPage, "SLAPPER IDENTIFICATION", 13, 25, PurpleLight)
        identificationTitle.Font = Enum.Font.GothamBold
        local identificationInfo = Label(GUI.GuessSlapperPage, "The detector watches client-visible impact signals, then checks nearby players for recent replicated slap-like animations and equipped tools. Results are evidence-based estimates, not server-confirmed attacker IDs.", 10, 58, Grey)
        identificationInfo.TextWrapped = true
        identificationInfo.Size = UDim2.new(1, 0, 0, 58)

        local detectorStatus = Label(GUI.GuessSlapperPage, "DETECTOR: STOPPED", 11, 24, Color3.fromRGB(235, 175, 125))
        detectorStatus.Font = Enum.Font.GothamBold
        local detectorSummary = Label(GUI.GuessSlapperPage, "Waiting to start. Health loss and sudden knockback are monitored as possible impact signals.", 10, 38, Grey)
        detectorSummary.TextWrapped = true
        local lastDetection = Label(GUI.GuessSlapperPage, "LAST RESULT: None", 11, 44, White)
        lastDetection.TextWrapped = true
        local historyLabel = Label(GUI.GuessSlapperPage, "SLAP HISTORY: No events recorded", 10, 110, Grey)
        historyLabel.TextWrapped = true
        historyLabel.TextYAlignment = Enum.TextYAlignment.Top

        local detectorRunning = false
        local detectorConnections = {}
        local characterConnections = {}
        local recentActions = {}
        local detectorHistory = {}
        local lastRootVelocity = {}
        local detectorVictimCooldown = {}
        local function disconnectList(list)
            for _, connection in ipairs(list) do
                pcall(function() connection:Disconnect() end)
            end
            table.clear(list)
        end
        local function recordAction(player, kind)
            recentActions[player.UserId] = { time = os.clock(), kind = kind }
        end
        local function renderHistory()
            if #detectorHistory == 0 then
                historyLabel.Text = "SLAP HISTORY: No events recorded"
                return
            end
            local lines = { "SLAP HISTORY (newest first):" }
            for i = #detectorHistory, math.max(1, #detectorHistory - 5), -1 do
                local item = detectorHistory[i]
                table.insert(lines, os.date("%I:%M:%S %p", item.time) .. " | " .. item.result)
            end
            historyLabel.Text = table.concat(lines, "\n")
        end
        local function detectImpact(victim, signal, severity)
            if not detectorRunning or victim == PlayersService.LocalPlayer then return end
            local now = os.clock()
            if now - (detectorVictimCooldown[victim.UserId] or 0) < 1.1 then return end
            detectorVictimCooldown[victim.UserId] = now

            local victimRoot = victim.Character and victim.Character:FindFirstChild("HumanoidRootPart")
            local victimPosition
            if victimRoot then pcall(function() victimPosition = victimRoot.Position end) end
            local ranked = {}
            for _, candidate in ipairs(PlayersService:GetPlayers()) do
                if candidate ~= victim and candidate.Character then
                    local action = recentActions[candidate.UserId]
                    local candidateRoot = candidate.Character:FindFirstChild("HumanoidRootPart")
                    local distance
                    if victimPosition and candidateRoot then
                        pcall(function() distance = (candidateRoot.Position - victimPosition).Magnitude end)
                    end
                    if action and now - action.time <= 1.6 and distance and distance <= 22 then
                        local score = 45
                        local age = now - action.time
                        score = score + math.max(0, 30 - age * 20)
                        score = score + math.max(0, 25 - distance)
                        local equipped = candidate.Character:FindFirstChildOfClass("Tool")
                        if equipped then score = score + 8 end
                        table.insert(ranked, { player = candidate, score = math.floor(score), distance = distance, action = action.kind, age = age })
                    end
                end
            end
            table.sort(ranked, function(a, b) return a.score > b.score end)

            local result
            local confidence = "UNKNOWN"
            local color = Color3.fromRGB(235, 175, 125)
            if ranked[1] then
                local best = ranked[1]
                local separated = not ranked[2] or best.score - ranked[2].score >= 12
                if best.score >= 65 and separated then
                    confidence = "LIKELY"
                    color = Color3.fromRGB(235, 195, 115)
                end
                result = best.player.DisplayName .. " (@" .. best.player.Name .. ") — " .. confidence
                    .. " | " .. best.action .. " " .. string.format("%.1fs ago", best.age)
                    .. " | " .. string.format("%.1f studs", best.distance)
            else
                result = "No nearby player had a recent matching action — UNKNOWN"
            end
            local entry = {
                time = os.time(),
                result = victim.DisplayName .. " was impacted (" .. signal .. "). Candidate: " .. result,
                victim = victim.Name,
                signal = signal
            }
            table.insert(detectorHistory, entry)
            while #detectorHistory > 12 do table.remove(detectorHistory, 1) end
            lastDetection.Text = "LAST RESULT: " .. entry.result
            lastDetection.TextColor3 = color
            detectorSummary.Text = "Impact signal: " .. signal .. " | Victim: " .. victim.DisplayName .. " | Candidates are ranked by recent animation, proximity, and visible tool state."
            renderHistory()
        end
        local function bindCharacter(player, character)
            if not detectorRunning or not character then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
            if not humanoid or not detectorRunning then return end
            local previousHealth = humanoid.Health
            table.insert(detectorConnections, humanoid.HealthChanged:Connect(function(health)
                if health < previousHealth - 0.5 then
                    detectImpact(player, "health drop -" .. string.format("%.1f", previousHealth - health), previousHealth - health)
                end
                previousHealth = health
            end))
            table.insert(detectorConnections, humanoid.StateChanged:Connect(function(_, newState)
                if newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.Physics then
                    detectImpact(player, "ragdoll/physics state", 1)
                end
            end))
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                table.insert(detectorConnections, animator.AnimationPlayed:Connect(function(track)
                    if not detectorRunning or player == PlayersService.LocalPlayer then return end
                    local animationId = "unknown"
                    pcall(function() animationId = track.Animation and track.Animation.AnimationId or "unknown" end)
                    recordAction(player, "replicated animation " .. tostring(animationId))
                end))
            end
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                local lastVelocity = root.AssemblyLinearVelocity
                lastRootVelocity[player.UserId] = lastVelocity
                table.insert(detectorConnections, root:GetPropertyChangedSignal("AssemblyLinearVelocity"):Connect(function()
                    if not detectorRunning then return end
                    local current = root.AssemblyLinearVelocity
                    local delta = (current - (lastRootVelocity[player.UserId] or current)).Magnitude
                    lastRootVelocity[player.UserId] = current
                    if delta >= 38 then
                        detectImpact(player, "sudden knockback velocity change", delta)
                    end
                end))
            end
        end
        local function stopSlapDetector()
            detectorRunning = false
            disconnectList(detectorConnections)
            disconnectList(characterConnections)
            table.clear(recentActions)
            table.clear(lastRootVelocity)
            detectorStatus.Text = "DETECTOR: STOPPED"
            detectorStatus.TextColor3 = Color3.fromRGB(235, 175, 125)
        end
        local detectorButton
        detectorButton = MakeButton(GUI.GuessSlapperPage, "START SLAP DETECTOR", function()
            if detectorRunning then
                stopSlapDetector()
                detectorButton.Text = "START SLAP DETECTOR"
                return
            end
            detectorRunning = true
            detectorStatus.Text = "DETECTOR: LISTENING"
            detectorStatus.TextColor3 = Color3.fromRGB(130, 220, 165)
            detectorSummary.Text = "Listening for health drops, ragdoll/physics transitions, knockback spikes, and replicated player animations."
            detectorButton.Text = "STOP SLAP DETECTOR"

            for _, player in ipairs(PlayersService:GetPlayers()) do
                if player.Character then bindCharacter(player, player.Character) end
                table.insert(characterConnections, player.CharacterAdded:Connect(function(character)
                    task.defer(function() bindCharacter(player, character) end)
                end))
            end
            table.insert(characterConnections, PlayersService.PlayerAdded:Connect(function(player)
                table.insert(characterConnections, player.CharacterAdded:Connect(function(character)
                    task.defer(function() bindCharacter(player, character) end)
                end))
                if player.Character then bindCharacter(player, player.Character) end
            end))
            table.insert(characterConnections, PlayersService.PlayerRemoving:Connect(function(player)
                recentActions[player.UserId] = nil
                lastRootVelocity[player.UserId] = nil
            end))
        end, Color3.fromRGB(65, 105, 145))
        MakeButton(GUI.GuessSlapperPage, "CLEAR SLAP HISTORY", function()
            table.clear(detectorHistory)
            lastDetection.Text = "LAST RESULT: None"
            lastDetection.TextColor3 = White
            renderHistory()
        end, Color3.fromRGB(75, 75, 95))
        local detectorDisclaimer = Label(GUI.GuessSlapperPage, "LIMITATION: Roblox client replication may hide the real attacker. A health/physics event only confirms a possible impact; nearby animation correlation is a LIKELY candidate, never a server-verified identity.", 9, 52, Grey)
        detectorDisclaimer.TextWrapped = true
        detectorDisclaimer.Size = UDim2.new(1, 0, 0, 52)
        GUI.StopSlapDetector = stopSlapDetector

        local observationContent = MakeFolder("ROUND OBSERVATIONS", GUI.GuessSlapperPage)
        local observationBoxValue = ""
        local observationBox = MakeBox(observationContent, "WHAT HAPPENED THIS ROUND?", "", function(value)
            observationBoxValue = tostring(value or "")
        end)
        local observationLog = Label(observationContent, "No observations saved.", 10, 54, Grey)
        observationLog.TextWrapped = true
        MakeButton(observationContent, "SAVE OBSERVATION", function()
            local entry = tostring(observationBoxValue or ""):gsub("^%s*(.-)%s*$", "%1")
            if entry == "" then observationLog.Text = "Enter an observation first."; return end
            observationLog.Text = os.date("%I:%M %p") .. " — " .. entry
            observationBoxValue = ""
            observationBox.Text = ""
        end, Color3.fromRGB(65, 90, 125))

        refreshRoster()
        PlayersService.PlayerAdded:Connect(refreshRoster)
        PlayersService.PlayerRemoving:Connect(function(player)
            markedSuspects[player.UserId] = nil
            task.defer(refreshRoster)
        end)
        task.spawn(function()
            while ScreenGui.Parent do
                task.wait(5)
                if GUI.GuessSlapperPage.Visible then refreshRoster() end
            end
        end)
    end


        -- AUTOMATIC ACTIVE STATUS: reports each user after the hub loads.
    do
        local PresenceStatus = Label(SettingsPage, "ACTIVE STATUS: AUTOMATIC", 10, 22, Color3.fromRGB(130, 210, 165))
        Label(SettingsPage, "When ShortName Hub loads, your Roblox username, display name, and current experience are shared with the hub's community roster. Updates repeat while the hub is open.", 10, 42, Grey).TextWrapped = true
        task.spawn(function()
            while ScreenGui.Parent do
                if PresenceModule and type(PresenceModule.Report) == "function" then
                    local ok, sent, detail = pcall(function() return PresenceModule.Report() end)
                    if not ok or not sent then
                        PresenceStatus.Text = "ACTIVE STATUS: " .. tostring(ok and detail or sent)
                        PresenceStatus.TextColor3 = Color3.fromRGB(235, 175, 125)
                    else
                        PresenceStatus.Text = "ACTIVE STATUS: ONLINE"
                        PresenceStatus.TextColor3 = Color3.fromRGB(130, 210, 165)
                    end
                else
                    PresenceStatus.Text = "ACTIVE STATUS: MODULE UNAVAILABLE"
                    PresenceStatus.TextColor3 = Color3.fromRGB(235, 175, 125)
                end
                task.wait(45)
            end
        end)
    end

    -- CREATOR-ONLY PLAYER ROSTER. The owner admin key is entered locally and is never saved.
    if PlayerAdminUI.Page then
        task.spawn(function()
            Label(PlayerAdminUI.Page, "COMMUNITY PLAYERS", 16, 28).Font = Enum.Font.GothamBold
            Label(PlayerAdminUI.Page, "Users who opted in to presence sharing. Online status expires after 90 seconds without a heartbeat.", 10, 38, Grey).TextWrapped = true
            local AdminKey = ""
            MakeBox(PlayerAdminUI.Page, "OWNER ADMIN KEY (Cloudflare UPLOAD_KEY)", "", function(value) AdminKey = value end)
            local RosterStatus = Label(PlayerAdminUI.Page, "ROSTER: ENTER ADMIN KEY, THEN REFRESH", 10, 24, Grey)
            local function ClearRosterRows()
                for _, child in ipairs(PlayerAdminUI.Page:GetChildren()) do
                    if child.Name == "PresencePlayerRow" then child:Destroy() end
                end
            end
            local function RefreshRoster()
                if not PresenceModule or type(PresenceModule.GetPlayers) ~= "function" then
                    RosterStatus.Text = "ROSTER: PRESENCE MODULE UNAVAILABLE"
                    return
                end
                if AdminKey == "" then
                    RosterStatus.Text = "ROSTER: ENTER OWNER ADMIN KEY"
                    return
                end
                RosterStatus.Text = "ROSTER: LOADING..."
                local ok, sent, result = pcall(function() return PresenceModule.GetPlayers(AdminKey) end)
                if not ok or not sent then
                    RosterStatus.Text = "ROSTER: " .. tostring(ok and result or sent)
                    return
                end
                ClearRosterRows()
                local list = type(result) == "table" and result.players or {}
                RosterStatus.Text = "ROSTER: " .. tostring(#list) .. " REGISTERED USERS"
                for _, playerData in ipairs(list) do
                    local row = Instance.new("Frame")
                    row.Name = "PresencePlayerRow"
                    row.Size = UDim2.new(1, 0, 0, 76)
                    row.BackgroundColor3 = ButtonDark
                    row.BorderSizePixel = 0
                    row.Parent = PlayerAdminUI.Page
                    Corner(row, 8)
                    Stroke(row, Border, 1)
                    local online = playerData.online == true
                    local seenText = online and ("ONLINE - " .. tostring(playerData.gameName or "Unknown game")) or ("OFFLINE - LAST SEEN " .. (tonumber(playerData.lastSeen) and os.date("%b %d %I:%M %p", playerData.lastSeen / 1000) or "UNKNOWN"))
                    local details = Instance.new("TextLabel")
                    details.BackgroundTransparency = 1
                    details.Position = UDim2.fromOffset(8, 5)
                    details.Size = UDim2.new(1, -184, 1, -10)
                    details.TextXAlignment = Enum.TextXAlignment.Left
                    details.TextYAlignment = Enum.TextYAlignment.Center
                    details.TextWrapped = true
                    details.Font = Enum.Font.Gotham
                    details.TextSize = 10
                    details.TextColor3 = online and Color3.fromRGB(130, 230, 165) or Grey
                    details.Text = tostring(playerData.displayName or playerData.username) .. "  (@" .. tostring(playerData.username) .. ")\n" .. seenText .. "\nRANK: " .. tostring(playerData.rank or "Member")
                    details.Parent = row
                    local rankOptions = { { "MEM", "Member", 0 }, { "PREM", "Premium", 1 }, { "STAFF", "Staff", 2 } }
                    for _, option in ipairs(rankOptions) do
                        local selectedRank = option[2]
                        local button = Instance.new("TextButton")
                        button.Size = UDim2.fromOffset(52, 25)
                        button.Position = UDim2.new(1, -176 + option[3] * 58, 0, 25)
                        button.BackgroundColor3 = playerData.rank == selectedRank and CurrentAccent.Active or Color3.fromRGB(48, 45, 60)
                        button.Text = option[1]
                        button.TextColor3 = White
                        button.TextSize = 9
                        button.Font = Enum.Font.GothamBold
                        button.Parent = row
                        Corner(button, 6)
                        button.Activated:Connect(function()
                            local saved, response, message = pcall(function() return PresenceModule.SetRank(AdminKey, playerData.userId, selectedRank) end)
                            if saved and response then
                                RosterStatus.Text = "UPDATED RANK: " .. tostring(playerData.username) .. " -> " .. selectedRank
                                RefreshRoster()
                            else
                                RosterStatus.Text = "RANK UPDATE FAILED: " .. tostring(saved and message or response)
                            end
                        end)
                    end
                end
            end
            MakeButton(PlayerAdminUI.Page, "REFRESH PLAYER ROSTER", RefreshRoster, Color3.fromRGB(55, 85, 125))
            task.spawn(function()
                while ScreenGui.Parent do
                    task.wait(60)
                    if PlayerAdminUI.Page.Visible and AdminKey ~= "" then RefreshRoster() end
                end
            end)
        end)
    end

    -- HALLOWEEN EVENT FOLDER
    local HalloweenFolder = MakeFolder("HALLOWEEN EVENT")

    -- THANKSGIVING EVENT FOLDER
    -- Kept separate from Halloween so event features stay organized.
    local ThanksgivingFolder = MakeFolder("THANKSGIVING EVENT")
    local ThanksgivingScannerFolder = MakeFolder("EVENT SCANNER", ThanksgivingFolder, false)

    Label(ThanksgivingScannerFolder, "THANKSGIVING EVENT SCANNER", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(
        ThanksgivingScannerFolder,
        "Scans locally replicated game objects and visible UI for Thanksgiving-related names and text.",
        10,
        38,
        Grey
    )

    local ScannerStatus = Label(ThanksgivingScannerFolder, "SCANNER: READY", 11, 24, Color3.fromRGB(170, 210, 255))
    ScannerStatus.Font = Enum.Font.GothamBold

    local ScannerCount = Label(ThanksgivingScannerFolder, "DISCOVERIES: 0", 10, 22, Grey)

    local function UpdateScannerDisplay(status, count)
        if status ~= nil then
            ScannerStatus.Text = "SCANNER: " .. tostring(status)
        end

        if count ~= nil then
            ScannerCount.Text = "DISCOVERIES: " .. tostring(count)
        elseif ThanksgivingScanner and type(ThanksgivingScanner.GetCount) == "function" then
            local ok, result = pcall(function()
                return ThanksgivingScanner:GetCount()
            end)
            if ok then
                ScannerCount.Text = "DISCOVERIES: " .. tostring(result)
            end
        end
    end

    local UploadKey = ""
    MakeBox(ThanksgivingScannerFolder, "CLOUDFLARE UPLOAD KEY", "", function(value)
        UploadKey = value
    end)

    MakeButton(ThanksgivingScannerFolder, "UPLOAD REPORT", function()
        if not ThanksgivingScanner or type(ThanksgivingScanner.UploadReport) ~= "function" then
            UpdateScannerDisplay("UPLOAD MODULE NOT LOADED", nil)
            return
        end

        if UploadKey == "" then
            UpdateScannerDisplay("ENTER UPLOAD KEY FIRST", nil)
            return
        end

        UpdateScannerDisplay("UPLOADING REPORT...", nil)

        task.spawn(function()
            local ok, success, message = pcall(function()
                return ThanksgivingScanner:UploadReport(UploadKey)
            end)

            if not ok then
                UpdateScannerDisplay("UPLOAD ERROR: " .. tostring(success), nil)
            elseif success then
                UpdateScannerDisplay(message or "UPLOADED TO GITHUB", nil)

            else
                UpdateScannerDisplay("UPLOAD FAILED: " .. tostring(message), nil)
            end
        end)
    end, Color3.fromRGB(45, 105, 145))

    MakeButton(ThanksgivingScannerFolder, "START SCAN", function()
        if not ThanksgivingScanner then
            UpdateScannerDisplay("MODULE NOT LOADED", 0)
            return
        end

        local ok, result = pcall(function()
            return ThanksgivingScanner:Start(function(status, count)
                UpdateScannerDisplay(status, count)
            end)
        end)

        if ok then
            UpdateScannerDisplay(type(result) == "string" and result or "SCANNING", nil)

        else
            UpdateScannerDisplay("ERROR: " .. tostring(result), nil)
        end
    end, Color3.fromRGB(45, 115, 75))

    MakeButton(ThanksgivingScannerFolder, "STOP SCAN", function()
        if ThanksgivingScanner and type(ThanksgivingScanner.Stop) == "function" then
            local ok, err = pcall(function()
                ThanksgivingScanner:Stop()
            end)
            UpdateScannerDisplay(ok and "STOPPED" or ("ERROR: " .. tostring(err)), nil)

        else
            UpdateScannerDisplay("MODULE NOT LOADED", nil)
        end
    end, Color3.fromRGB(125, 75, 55))

    MakeButton(ThanksgivingScannerFolder, "COPY REPORT", function()
        if not ThanksgivingScanner or type(ThanksgivingScanner.GetReport) ~= "function" then
            UpdateScannerDisplay("MODULE NOT LOADED", nil)
            return
        end

        local ok, report = pcall(function()
            return ThanksgivingScanner:GetReport()
        end)

        if not ok then
            UpdateScannerDisplay("REPORT ERROR", nil)
            return
        end

        local copied = false
        if type(setclipboard) == "function" then
            copied = pcall(function()
                setclipboard(report)
            end)
        end
        if not copied and type(toclipboard) == "function" then
            copied = pcall(function()
                toclipboard(report)
            end)
        end

        UpdateScannerDisplay(copied and "REPORT COPIED" or "CLIPBOARD UNAVAILABLE", nil)
    end)

    MakeButton(ThanksgivingScannerFolder, "CLEAR REPORT", function()
        if ThanksgivingScanner and type(ThanksgivingScanner.Clear) == "function" then
            local ok, err = pcall(function()
                ThanksgivingScanner:Clear()
            end)
            if ok then
                UpdateScannerDisplay("REPORT CLEARED", 0)
            else
                UpdateScannerDisplay("ERROR: " .. tostring(err), nil)
            end
        else
            UpdateScannerDisplay("MODULE NOT LOADED", nil)
        end
    end, Color3.fromRGB(85, 75, 105))

    -- FIGHT ON A BASEPLATE FOLDER
    -- Kept separate from the other game folders.
    local FightFolder = MakeFolder("FIGHT ON A BASEPLATE", FightPage)

    do
    -- PLAYER TOOLS: camera-based player tracking (does not move the local character).
    local PlayerToolsFolder = MakeFolder("PLAYER TOOLS", PlayerToolsPage)
    Label(PlayerToolsFolder, "PLAYER TRACKER", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(PlayerToolsFolder, "Enter a player name to spectate their character. Your own character is not teleported or attached.", 10, 38, Grey)

    local PlayerTrackerName = ""
    local AutoTeleportSpeed = 16
    local AutoTeleportSpeedStatus = Label(PlayerToolsFolder, "FOLLOW SPEED: 16 STUDS/SEC", 10, 22, Grey)
    MakeBox(PlayerToolsFolder, "FOLLOW SPEED (0.1-100 STUDS/SEC)", "16", function(value)
        local parsed = tonumber(value)
        if not parsed or parsed ~= parsed or parsed == math.huge or parsed == -math.huge then
            AutoTeleportSpeedStatus.Text = "FOLLOW SPEED: ENTER A NUMBER"
            return
        end
        AutoTeleportSpeed = math.clamp(parsed, 0.1, 100)
        AutoTeleportSpeedStatus.Text = "FOLLOW SPEED: " .. string.format("%.1f", AutoTeleportSpeed) .. " STUDS/SEC"
    end)
    local PlayerTrackerTarget
    local PlayerTrackerCharacterConnection
    local PlayerTrackerRemovingConnection
    local PlayerTrackerActive = false
    local PlayerTrackerStatus = Label(PlayerToolsFolder, "TRACKER: READY", 10, 22, Grey)

    local function RestorePlayerTrackerCamera()
        local camera = workspace.CurrentCamera
        local character = LocalPlayer and LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if camera and humanoid then
            camera.CameraType = Enum.CameraType.Custom
            camera.CameraSubject = humanoid
        end
    end

    local function StopPlayerTracker()
        PlayerTrackerActive = false
        if PlayerTrackerCharacterConnection then
            PlayerTrackerCharacterConnection:Disconnect()
            PlayerTrackerCharacterConnection = nil
        end
        if PlayerTrackerRemovingConnection then
            PlayerTrackerRemovingConnection:Disconnect()
            PlayerTrackerRemovingConnection = nil
        end
        PlayerTrackerTarget = nil
        RestorePlayerTrackerCamera()
        if PlayerTrackerStatus and PlayerTrackerStatus.Parent then
            PlayerTrackerStatus.Text = "TRACKER: STOPPED"
        end
    end

    MakeBox(PlayerToolsFolder, "PLAYER NAME (PARTIAL IS OK)", "", function(value)
        PlayerTrackerName = tostring(value or ""):gsub("^%s*(.-)%s*$", "%1")
    end)

    local function FindPlayerFromPartialName(input)
        local query = tostring(input or ""):lower():gsub("^%s*(.-)%s*$", "%1")
        if query == "" then return nil, "ENTER PART OF A PLAYER NAME" end

        local exactMatch, prefixMatch, containsMatch
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local username = player.Name:lower()
                local displayName = player.DisplayName:lower()

                if username == query or displayName == query then
                    exactMatch = player
                    break
                elseif not prefixMatch and (username:sub(1, #query) == query or displayName:sub(1, #query) == query) then
                    prefixMatch = player
                elseif not containsMatch and (username:find(query, 1, true) or displayName:find(query, 1, true)) then
                    containsMatch = player
                end
            end
        end

        return exactMatch or prefixMatch or containsMatch, nil
    end

    MakeButton(PlayerToolsFolder, "START PLAYER TRACKER", function()
        local target, findError = FindPlayerFromPartialName(PlayerTrackerName)
        if not target then
            PlayerTrackerStatus.Text = "TRACKER: " .. (findError or "PLAYER NOT FOUND")
            return
        end

        StopPlayerTracker()
        PlayerTrackerActive = true
        PlayerTrackerTarget = target
        local function SetCameraTarget(character)
            if not PlayerTrackerActive or PlayerTrackerTarget ~= target then return end
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid and workspace.CurrentCamera then
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                workspace.CurrentCamera.CameraSubject = humanoid
                PlayerTrackerStatus.Text = "TRACKER: SPECTATING " .. target.Name
            else
                PlayerTrackerStatus.Text = "TRACKER: WAITING FOR TARGET"
            end
        end
        if target.Character then SetCameraTarget(target.Character) end
        PlayerTrackerCharacterConnection = target.CharacterAdded:Connect(SetCameraTarget)
        PlayerTrackerRemovingConnection = Players.PlayerRemoving:Connect(function(leaving)
            if leaving == target then
                StopPlayerTracker()
                PlayerTrackerStatus.Text = "TRACKER: TARGET LEFT"
            end
        end)
    end, Color3.fromRGB(45, 105, 145))

    MakeButton(PlayerToolsFolder, "STOP PLAYER TRACKER", StopPlayerTracker, Color3.fromRGB(85, 65, 95))

    -- AUTO TELEPORT TARGET DETECTOR: resolves a player by partial username/display name.
    local TeleportTargetStatus = Label(PlayerToolsFolder, "AUTO TELEPORT: NO TARGET SELECTED", 10, 22, Grey)
    local SelectedTeleportTarget = nil

    local function DetectTeleportTarget()
        local target, findError = FindPlayerFromPartialName(PlayerTrackerName)
        if not target then
            SelectedTeleportTarget = nil
            TeleportTargetStatus.Text = "AUTO TELEPORT: " .. (findError or "PLAYER NOT FOUND")
            return nil
        end

        SelectedTeleportTarget = target
        TeleportTargetStatus.Text = "TARGET DETECTED: " .. target.Name .. " (@" .. target.DisplayName .. ")"
        return target
    end

    MakeButton(PlayerToolsFolder, "DETECT TELEPORT TARGET", DetectTeleportTarget, Color3.fromRGB(45, 105, 75))
    MakeButton(PlayerToolsFolder, "CLEAR TELEPORT TARGET", function()
        SelectedTeleportTarget = nil
        TeleportTargetStatus.Text = "AUTO TELEPORT: TARGET CLEARED"
    end, Color3.fromRGB(85, 65, 95))

    local TeleportTargetRemovingConnection = Players.PlayerRemoving:Connect(function(leaving)
        if SelectedTeleportTarget == leaving then
            SelectedTeleportTarget = nil
            TeleportTargetStatus.Text = "AUTO TELEPORT: TARGET LEFT"
        end
    end)

    -- AUTO RESET: affects only the local player's own character.
    Label(PlayerToolsFolder, "AUTO RESET", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(PlayerToolsFolder, "Automatically resets your own character at the chosen interval.", 10, 32, Grey)
    local AutoResetInterval = 5
    local AutoResetEnabled = false
    local AutoResetToken = 0
    local AutoResetStatus = Label(PlayerToolsFolder, "AUTO RESET: OFF", 10, 22, Grey)

    MakeBox(PlayerToolsFolder, "RESET INTERVAL (SECONDS, 1-60)", "5", function(value)
        local parsed = tonumber(value)
        if not parsed then
            AutoResetStatus.Text = "AUTO RESET: ENTER A NUMBER"
            return
        end
        AutoResetInterval = math.clamp(parsed, 1, 60)
        AutoResetStatus.Text = "AUTO RESET INTERVAL: " .. string.format("%.1f", AutoResetInterval) .. " SEC"
    end)

    local AutoResetButton
    local function StopAutoReset()
        AutoResetEnabled = false
        AutoResetToken += 1
        if AutoResetButton and AutoResetButton.Parent then
            AutoResetButton.Text = "AUTO RESET: OFF"
        end
        if AutoResetStatus and AutoResetStatus.Parent then
            AutoResetStatus.Text = "AUTO RESET: OFF"
        end
    end

    AutoResetButton = MakeButton(PlayerToolsFolder, "AUTO RESET: OFF", function()
        AutoResetEnabled = not AutoResetEnabled
        AutoResetToken += 1
        local token = AutoResetToken
        if not AutoResetEnabled then
            StopAutoReset()
            return
        end
        AutoResetButton.Text = "AUTO RESET: ON"
        AutoResetStatus.Text = "AUTO RESET: RUNNING"
        task.spawn(function()
            while AutoResetEnabled and AutoResetToken == token and ScreenGui.Parent do
                task.wait(AutoResetInterval)
                if not AutoResetEnabled or AutoResetToken ~= token or not ScreenGui.Parent then break end
                local character = LocalPlayer and LocalPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    humanoid.Health = 0
                end
            end
        end)
    end, Color3.fromRGB(45, 105, 75))

    ScreenGui.Destroying:Connect(function()
        StopAutoReset()
        StopPlayerTracker()
        if TeleportTargetRemovingConnection then
            TeleportTargetRemovingConnection:Disconnect()
            TeleportTargetRemovingConnection = nil
        end
    end)
    end

    if DetectionPage then
        Label(DetectionPage, "DETECTION & OBSERVATION", 17, 30).Font = Enum.Font.GothamBold
        Label(DetectionPage, "Owner-only tools for scanning game objects, inspecting combat structures, and recording observations.", 11, 34, Grey)
    end
    local FightDetectorsFolder = MakeFolder("DETECTION & OBSERVATION", DetectionPage or FightPage, false)

    -- GAME DETECTOR: detects locally and only uploads after an explicit owner action.
    local GameDetectorFolder = MakeFolder("GAME DETECTOR", FightDetectorsFolder)
    Label(GameDetectorFolder, "CURRENT EXPERIENCE", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(GameDetectorFolder, "Detects the experience you are currently playing. Nothing is uploaded unless you press UPLOAD GAME REPORT.", 10, 42, Grey).TextWrapped = true
    local GameDetectorStatus = Label(GameDetectorFolder, "DETECTOR: READY", 10, 22, Color3.fromRGB(170, 210, 255))
    GameDetectorStatus.Font = Enum.Font.GothamBold
    local GameDetectorName = Label(GameDetectorFolder, "GAME: --", 11, 24, White)
    local GameDetectorPlace = Label(GameDetectorFolder, "PLACE ID: --", 10, 22, Grey)
    local GameDetectorUniverse = Label(GameDetectorFolder, "UNIVERSE ID: --", 10, 22, Grey)
    local GameDetectorReport = ""
    local function RefreshGameDetection()
        local ok, details = pcall(function()
            local detectedName = tostring(game.Name or "Unknown Experience")
            local placeId = tonumber(game.PlaceId) or 0
            if placeId > 0 then
                pcall(function()
                    local info = game:GetService("MarketplaceService"):GetProductInfo(placeId)
                    if info and type(info.Name) == "string" and info.Name ~= "" then
                        detectedName = info.Name
                    end
                end)
            end
            return {
                name = detectedName,
                placeId = placeId,
                universeId = tonumber(game.GameId) or 0,
                detectedAt = os.date("!%Y-%m-%d %H:%M:%S UTC")
            }
        end)
        if not ok or not details then
            GameDetectorStatus.Text = "DETECTOR: COULD NOT READ GAME INFO"
            return
        end
        GameDetectorReport = table.concat({
            "SHORTNAME HUB GAME REPORT",
            "Detected: " .. details.detectedAt,
            "Game: " .. details.name,
            "PlaceId: " .. tostring(details.placeId),
            "UniverseId: " .. tostring(details.universeId),
            "Source: Roblox client game metadata",
            "Note: This report was manually approved for upload."
        }, "\n")
        GameDetectorName.Text = "GAME: " .. details.name
        GameDetectorPlace.Text = "PLACE ID: " .. tostring(details.placeId)
        GameDetectorUniverse.Text = "UNIVERSE ID: " .. tostring(details.universeId)
        GameDetectorStatus.Text = "DETECTOR: REPORT READY - NOT UPLOADED"
    end
    local GameDetectorKey = ""
    MakeBox(GameDetectorFolder, "CLOUDFLARE UPLOAD KEY (ONLY NEEDED TO UPLOAD)", "", function(value)
        GameDetectorKey = tostring(value or "")
    end)
    MakeButton(GameDetectorFolder, "DETECT CURRENT GAME", RefreshGameDetection, Color3.fromRGB(55, 95, 145))
    MakeButton(GameDetectorFolder, "COPY GAME REPORT", function()
        if GameDetectorReport == "" then RefreshGameDetection() end
        local copyFn = setclipboard or toclipboard
        if type(copyFn) == "function" then
            local copied = pcall(copyFn, GameDetectorReport)
            GameDetectorStatus.Text = copied and "DETECTOR: REPORT COPIED" or "DETECTOR: CLIPBOARD FAILED"
        else
            GameDetectorStatus.Text = "DETECTOR: CLIPBOARD UNAVAILABLE"
        end
    end, Color3.fromRGB(65, 75, 105))
    MakeButton(GameDetectorFolder, "UPLOAD GAME REPORT", function()
        if GameDetectorReport == "" then RefreshGameDetection() end
        if GameDetectorKey == "" then
            GameDetectorStatus.Text = "DETECTOR: ENTER UPLOAD KEY FIRST"
            return
        end
        local requestFunction
        if type(request) == "function" then requestFunction = request
        elseif type(http_request) == "function" then requestFunction = http_request
        elseif syn and type(syn.request) == "function" then requestFunction = syn.request
        elseif http and type(http.request) == "function" then requestFunction = http.request
        elseif fluxus and type(fluxus.request) == "function" then requestFunction = fluxus.request end
        if not requestFunction then
            GameDetectorStatus.Text = "DETECTOR: EXECUTOR HTTP API UNAVAILABLE"
            return
        end
        GameDetectorStatus.Text = "DETECTOR: UPLOADING APPROVED REPORT..."
        task.spawn(function()
            local HttpService = game:GetService("HttpService")
            local sent, response = pcall(function()
                return requestFunction({
                    Url = "https://shortname-report-receive.ryft-amv.workers.dev/game-report",
                    Method = "POST",
                    Timeout = 30,
                    Headers = { ["Content-Type"] = "application/json", ["x-upload-key"] = GameDetectorKey },
                    Body = HttpService:JSONEncode({ report = GameDetectorReport })
                })
            end)
            local code = type(response) == "table" and (response.StatusCode or response.Status or response.status_code) or nil
            local body = type(response) == "table" and (response.Body or response.body or "") or ""
            local decodedOk, decoded = pcall(function() return HttpService:JSONDecode(body) end)
            if sent and code == 200 and decodedOk and type(decoded) == "table" and decoded.ok == true then
                GameDetectorStatus.Text = "DETECTOR: UPLOAD CONFIRMED - SAVED TO GITHUB"
            else
                GameDetectorStatus.Text = "DETECTOR: UPLOAD FAILED (HTTP " .. tostring(code) .. ")"
            end
        end)
    end, Color3.fromRGB(45, 105, 75))
    RefreshGameDetection()

    if ThanksgivingScannerFolder and ThanksgivingScannerFolder.Parent then
        ThanksgivingScannerFolder.Parent.Parent = FightDetectorsFolder
    end
    local FightScannerFolder = MakeFolder("GAME OBJECT SCANNER", FightDetectorsFolder, false)

    Label(FightScannerFolder, "GAME OBJECT SCANNER", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(
        FightScannerFolder,
        "Scans locally replicated game objects and visible UI for combat-related names and text.",
        10,
        38,
        Grey
    )

    local ScannerStatus = Label(FightScannerFolder, "SCANNER: READY", 11, 24, Color3.fromRGB(170, 210, 255))
    ScannerStatus.Font = Enum.Font.GothamBold

    local ScannerCount = Label(FightScannerFolder, "DISCOVERIES: 0", 10, 22, Grey)

    local function UpdateScannerDisplay(status, count)
        if status ~= nil then
            ScannerStatus.Text = "SCANNER: " .. tostring(status)
        end

        if count ~= nil then
            ScannerCount.Text = "DISCOVERIES: " .. tostring(count)
        elseif FightScanner and type(FightScanner.GetCount) == "function" then
            local ok, result = pcall(function()
                return FightScanner:GetCount()
            end)
            if ok then
                ScannerCount.Text = "DISCOVERIES: " .. tostring(result)
            end
        end
    end

    local UploadKey = ""
    MakeBox(FightScannerFolder, "CLOUDFLARE UPLOAD KEY", "", function(value)
        UploadKey = value
    end)

    MakeButton(FightScannerFolder, "UPLOAD REPORT", function()
        if not FightScanner or type(FightScanner.UploadReport) ~= "function" then
            UpdateScannerDisplay("UPLOAD MODULE NOT LOADED", nil)
            return
        end

        if UploadKey == "" then
            UpdateScannerDisplay("ENTER UPLOAD KEY FIRST", nil)
            return
        end

        UpdateScannerDisplay("UPLOADING REPORT...", nil)

        task.spawn(function()
            local ok, success, message = pcall(function()
                return FightScanner:UploadReport(UploadKey)
            end)

            if not ok then
                UpdateScannerDisplay("UPLOAD ERROR: " .. tostring(success), nil)
            elseif success then
                UpdateScannerDisplay(message or "UPLOADED TO GITHUB", nil)

            else
                UpdateScannerDisplay("UPLOAD FAILED: " .. tostring(message), nil)
            end
        end)
    end, Color3.fromRGB(45, 105, 145))

    MakeButton(FightScannerFolder, "START SCAN", function()
        if not FightScanner then
            UpdateScannerDisplay("MODULE NOT LOADED", 0)
            return
        end

        local ok, result = pcall(function()
            return FightScanner:Start(function(status, count)
                UpdateScannerDisplay(status, count)
            end)
        end)

        if ok then
            UpdateScannerDisplay(type(result) == "string" and result or "SCANNING", nil)

        else
            UpdateScannerDisplay("ERROR: " .. tostring(result), nil)
        end
    end, Color3.fromRGB(45, 115, 75))

    MakeButton(FightScannerFolder, "STOP SCAN", function()
        if FightScanner and type(FightScanner.Stop) == "function" then
            local ok, err = pcall(function()
                FightScanner:Stop()
            end)
            UpdateScannerDisplay(ok and "STOPPED" or ("ERROR: " .. tostring(err)), nil)

        else
            UpdateScannerDisplay("MODULE NOT LOADED", nil)
        end
    end, Color3.fromRGB(125, 75, 55))

    MakeButton(FightScannerFolder, "COPY REPORT", function()
        if not FightScanner or type(FightScanner.GetReport) ~= "function" then
            UpdateScannerDisplay("MODULE NOT LOADED", nil)
            return
        end

        local ok, report = pcall(function()
            return FightScanner:GetReport()
        end)

        if not ok then
            UpdateScannerDisplay("REPORT ERROR", nil)
            return
        end

        local copied = false
        if type(setclipboard) == "function" then
            copied = pcall(function()
                setclipboard(report)
            end)
        end
        if not copied and type(toclipboard) == "function" then
            copied = pcall(function()
                toclipboard(report)
            end)
        end

        UpdateScannerDisplay(copied and "REPORT COPIED" or "CLIPBOARD UNAVAILABLE", nil)
    end)

    MakeButton(FightScannerFolder, "CLEAR REPORT", function()
        if FightScanner and type(FightScanner.Clear) == "function" then
            local ok, err = pcall(function()
                FightScanner:Clear()
            end)
            if ok then
                UpdateScannerDisplay("REPORT CLEARED", 0)
            else
                UpdateScannerDisplay("ERROR: " .. tostring(err), nil)
            end
        else
            UpdateScannerDisplay("MODULE NOT LOADED", nil)
        end
    end, Color3.fromRGB(85, 75, 105))


    -- READ-ONLY COMBAT SYSTEM INSPECTOR
    local FightInspectorFolder = MakeFolder("COMBAT SYSTEM FINDER", FightDetectorsFolder, false)
    Label(FightInspectorFolder, "COMBAT SYSTEM FINDER", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(
        FightInspectorFolder,
        "Inspects selected combat-related instances, their classes, paths, and child structure. It never calls remotes or reads script source.",
        10,
        48,
        Grey
    )
    local InspectorStatus = Label(FightInspectorFolder, "INSPECTOR: READY", 11, 24, Color3.fromRGB(170, 210, 255))
    InspectorStatus.Font = Enum.Font.GothamBold
    local InspectorCount = Label(FightInspectorFolder, "OBJECTS INSPECTED: 0", 10, 22, Grey)

    local function UpdateInspectorDisplay(status, count)
        if status ~= nil then
            InspectorStatus.Text = "INSPECTOR: " .. tostring(status)
        end
        if count ~= nil then
            InspectorCount.Text = "OBJECTS INSPECTED: " .. tostring(count)
        elseif FightInspector and type(FightInspector.GetCount) == "function" then
            local ok, result = pcall(function() return FightInspector:GetCount() end)
            if ok then InspectorCount.Text = "OBJECTS INSPECTED: " .. tostring(result) end
        end
    end

    MakeButton(FightInspectorFolder, "INSPECT COMBAT SYSTEMS", function()
        if not FightInspector or type(FightInspector.Inspect) ~= "function" then
            UpdateInspectorDisplay("MODULE NOT LOADED", nil)
            return
        end
        UpdateInspectorDisplay("INSPECTING...", 0)
        task.spawn(function()
            local ok, success, count = pcall(function()
                return FightInspector:Inspect(function(status, total)
                    UpdateInspectorDisplay(status, total)
                end)
            end)
            if not ok then
                UpdateInspectorDisplay("ERROR: " .. tostring(success), nil)
            elseif success then
                UpdateInspectorDisplay("INSPECTION COMPLETE", count or 0)
            else
                UpdateInspectorDisplay("INSPECTION FAILED", nil)
            end
        end)
    end, Color3.fromRGB(45, 115, 75))

    MakeButton(FightInspectorFolder, "COPY INSPECTION REPORT", function()
        if not FightInspector or type(FightInspector.GetReport) ~= "function" then
            UpdateInspectorDisplay("MODULE NOT LOADED", nil)
            return
        end
        local ok, report = pcall(function() return FightInspector:GetReport() end)
        if not ok then
            UpdateInspectorDisplay("REPORT ERROR", nil)
            return
        end
        local copied = false
        if type(setclipboard) == "function" then
            copied = pcall(function() setclipboard(report) end)
        end
        if not copied and type(toclipboard) == "function" then
            copied = pcall(function() toclipboard(report) end)
        end
        UpdateInspectorDisplay(copied and "REPORT COPIED" or "CLIPBOARD UNAVAILABLE", nil)
    end)

    MakeButton(FightInspectorFolder, "CLEAR INSPECTION", function()
        if FightInspector and type(FightInspector.Clear) == "function" then
            local ok = pcall(function() FightInspector:Clear() end)
            UpdateInspectorDisplay(ok and "CLEARED" or "CLEAR FAILED", 0)
        else
            UpdateInspectorDisplay("MODULE NOT LOADED", nil)
        end
    end, Color3.fromRGB(85, 75, 105))

    -- PASSIVE COMBAT STRUCTURE SCANNER
    local FightStructureFolder = MakeFolder("COMBAT STRUCTURE FINDER", FightDetectorsFolder, false)
    Label(FightStructureFolder, "COMBAT STRUCTURE FINDER", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(
        FightStructureFolder,
        "Inventories client-visible combat-related objects and RemoteEvent/RemoteFunction names and paths. It never invokes them or reads script source.",
        10,
        50,
        Grey
    )
    local StructureStatus = Label(FightStructureFolder, "STRUCTURE SCANNER: READY", 11, 24, Color3.fromRGB(170, 210, 255))
    StructureStatus.Font = Enum.Font.GothamBold
    local StructureCount = Label(FightStructureFolder, "DISCOVERIES: 0", 10, 22, Grey)

    local function UpdateStructureDisplay(status, count)
        if status ~= nil then
            StructureStatus.Text = "STRUCTURE SCANNER: " .. tostring(status)
        end
        if count ~= nil then
            StructureCount.Text = "DISCOVERIES: " .. tostring(count)
        elseif FightStructureScanner and type(FightStructureScanner.GetCount) == "function" then
            local ok, result = pcall(function() return FightStructureScanner:GetCount() end)
            if ok then StructureCount.Text = "DISCOVERIES: " .. tostring(result) end
        end
    end

    local StructureUploadKey = ""
    MakeBox(FightStructureFolder, "CLOUDFLARE UPLOAD KEY", "", function(value)
        StructureUploadKey = value
    end)

    MakeButton(FightStructureFolder, "UPLOAD STRUCTURE REPORT", function()
        if not FightStructureScanner or type(FightStructureScanner.UploadReport) ~= "function" then
            UpdateStructureDisplay("UPLOAD MODULE NOT LOADED", nil)
            return
        end
        if StructureUploadKey == "" then
            UpdateStructureDisplay("ENTER UPLOAD KEY FIRST", nil)
            return
        end
        UpdateStructureDisplay("UPLOADING REPORT...", nil)
        task.spawn(function()
            local ok, success, message = pcall(function()
                return FightStructureScanner:UploadReport(StructureUploadKey)
            end)
            if not ok then
                UpdateStructureDisplay("UPLOAD ERROR: " .. tostring(success), nil)
            elseif success then
                UpdateStructureDisplay(message or "UPLOADED TO GITHUB", nil)
            else
                UpdateStructureDisplay("UPLOAD FAILED: " .. tostring(message), nil)
            end
        end)
    end, Color3.fromRGB(45, 105, 145))

    MakeButton(FightStructureFolder, "START STRUCTURE SCAN", function()
        if not FightStructureScanner or type(FightStructureScanner.Start) ~= "function" then
            UpdateStructureDisplay("MODULE NOT LOADED", nil)
            return
        end
        UpdateStructureDisplay("STARTING...", 0)
        local ok, result = pcall(function()
            return FightStructureScanner:Start(function(status, count)
                UpdateStructureDisplay(status, count)
            end)
        end)
        if not ok then
            UpdateStructureDisplay("ERROR: " .. tostring(result), nil)
        else
            UpdateStructureDisplay(type(result) == "string" and result or "SCANNING", nil)
        end
    end, Color3.fromRGB(45, 115, 75))

    MakeButton(FightStructureFolder, "STOP STRUCTURE SCAN", function()
        if FightStructureScanner and type(FightStructureScanner.Stop) == "function" then
            local ok = pcall(function() FightStructureScanner:Stop() end)
            UpdateStructureDisplay(ok and "STOPPED" or "STOP FAILED", nil)
        else
            UpdateStructureDisplay("MODULE NOT LOADED", nil)
        end
    end, Color3.fromRGB(125, 75, 55))

    MakeButton(FightStructureFolder, "COPY STRUCTURE REPORT", function()
        if not FightStructureScanner or type(FightStructureScanner.GetReport) ~= "function" then
            UpdateStructureDisplay("MODULE NOT LOADED", nil)
            return
        end
        local ok, report = pcall(function() return FightStructureScanner:GetReport() end)
        if not ok then
            UpdateStructureDisplay("REPORT ERROR", nil)
            return
        end
        local copied = false
        if type(setclipboard) == "function" then
            copied = pcall(function() setclipboard(report) end)
        end
        if not copied and type(toclipboard) == "function" then
            copied = pcall(function() toclipboard(report) end)
        end
        UpdateStructureDisplay(copied and "REPORT COPIED" or "CLIPBOARD UNAVAILABLE", nil)
    end)

    MakeButton(FightStructureFolder, "CLEAR STRUCTURE REPORT", function()
        if FightStructureScanner and type(FightStructureScanner.Clear) == "function" then
            local ok = pcall(function() FightStructureScanner:Clear() end)
            UpdateStructureDisplay(ok and "CLEARED" or "CLEAR FAILED", 0)
        else
            UpdateStructureDisplay("MODULE NOT LOADED", nil)
        end
    end, Color3.fromRGB(85, 75, 105))

    -- PLAYER UTILITIES (SETTINGS TAB)
    local UtilityFolder = SettingsPage

    Label(UtilityFolder, "PLAYER UTILITIES", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(UtilityFolder, "DIAGNOSTICS", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    MakeButton(UtilityFolder, "OPEN STARTUP ERROR CONSOLE", function()
        local sharedEnv = _G
        if type(getgenv) == "function" then
            local ok, env = pcall(getgenv)
            if ok and type(env) == "table" then
                sharedEnv = env
            end
        end
        local showConsole = sharedEnv.__SHORTNAME_SHOW_DIAGNOSTICS
        if type(showConsole) == "function" then
            showConsole()
        else
            SetStatus("DIAGNOSTIC CONSOLE IS NOT AVAILABLE")
        end
    end, Color3.fromRGB(85, 75, 125))
    Label(UtilityFolder, "Convenience tools for your current session.", 10, 22, Grey)

    local LocalPlayer = Players.LocalPlayer
    local TeleportService = game:GetService("TeleportService")
    local AntiAfkConnection = nil
    local HubToggleConnection = nil
    local PerformanceConnection = nil

    local AntiAfkButton
    AntiAfkButton = MakeButton(UtilityFolder, "ANTI-AFK: OFF", function()
        if AntiAfkConnection then
            AntiAfkConnection:Disconnect()
            AntiAfkConnection = nil
            AntiAfkButton.Text = "ANTI-AFK: OFF"
            SetStatus("ANTI-AFK DISABLED")
            return
        end

        if not LocalPlayer then
            SetStatus("PLAYER NOT AVAILABLE")
            return
        end

        AntiAfkConnection = LocalPlayer.Idled:Connect(function()
            local VirtualUser = game:GetService("VirtualUser")
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end)
        AntiAfkButton.Text = "ANTI-AFK: ON"
        SetStatus("ANTI-AFK ENABLED")
    end, Color3.fromRGB(45, 115, 75))

    MakeButton(UtilityFolder, "REJOIN CURRENT SERVER", function()
        SetStatus("REJOINING SERVER...")
        task.spawn(function()
            local ok, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end)
            if not ok then
                SetStatus("REJOIN FAILED: " .. tostring(err))
            end
        end)
    end)

    MakeButton(UtilityFolder, "SERVER HOP", function()
        SetStatus("REQUESTING ANOTHER SERVER...")
        task.spawn(function()
            local ok, err = pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
            if not ok then
                SetStatus("SERVER HOP FAILED: " .. tostring(err))
            end
        end)
    end, Color3.fromRGB(75, 85, 145))

    local FPSBoostEnabled = false
    local FPSOriginals = {}
    local function SaveProperty(object, property)
        local ok, value = pcall(function()
            return object[property]
        end)
        if ok then
            FPSOriginals[object] = FPSOriginals[object] or {}
            if FPSOriginals[object][property] == nil then
                FPSOriginals[object][property] = value
            end
        end
    end

    local function ApplyFPSBoost()
        table.clear(FPSOriginals)
        for _, object in ipairs(game:GetDescendants()) do
            if object:IsA("BasePart") then
                SaveProperty(object, "Material")
                SaveProperty(object, "Reflectance")
                SaveProperty(object, "CastShadow")
                pcall(function()
                    object.Material = Enum.Material.Plastic
                    object.Reflectance = 0
                    object.CastShadow = false
                end)
            elseif object:IsA("Decal") or object:IsA("Texture") then
                SaveProperty(object, "Transparency")
                pcall(function()
                    object.Transparency = 1
                end)
            elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") then
                SaveProperty(object, "Enabled")
                pcall(function()
                    object.Enabled = false
                end)
            elseif object:IsA("PostEffect") then
                SaveProperty(object, "Enabled")
                pcall(function()
                    object.Enabled = false
                end)
            end
        end
        local Lighting = game:GetService("Lighting")
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                SaveProperty(effect, "Enabled")
                pcall(function()
                    effect.Enabled = false
                end)
            end
        end
    end

    local function RestoreFPSSettings()
        for object, properties in pairs(FPSOriginals) do
            if object and object.Parent then
                for property, value in pairs(properties) do
                    pcall(function()
                        object[property] = value
                    end)
                end
            end
        end
        table.clear(FPSOriginals)
    end

    ScreenGui.Destroying:Connect(function()
        if AntiAfkConnection then
            AntiAfkConnection:Disconnect()
            AntiAfkConnection = nil
        end
        if FPSBoostEnabled then
            RestoreFPSSettings()
            FPSBoostEnabled = false
        end
        if HubToggleConnection then
            HubToggleConnection:Disconnect()
            HubToggleConnection = nil
        end
        if PerformanceConnection then
            PerformanceConnection:Disconnect()
            PerformanceConnection = nil
        end
    end)

    local FPSButton
    FPSButton = MakeButton(UtilityFolder, "FPS BOOST: OFF", function()
        FPSBoostEnabled = not FPSBoostEnabled
        if FPSBoostEnabled then
            ApplyFPSBoost()
            FPSButton.Text = "FPS BOOST: ON"
            SetStatus("LOW GRAPHICS ENABLED")
        else
            RestoreFPSSettings()
            FPSButton.Text = "FPS BOOST: OFF"
            SetStatus("GRAPHICS RESTORED")
        end
    end, Color3.fromRGB(100, 85, 145))

    Label(UtilityFolder, "LIVE PLAYER INFO", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    local PlayerInfoLabel = Label(UtilityFolder, "Loading player information...", 10, 76, White)
    PlayerInfoLabel.TextWrapped = true
    PlayerInfoLabel.TextYAlignment = Enum.TextYAlignment.Top

    task.spawn(function()
        while ScreenGui.Parent and PlayerInfoLabel.Parent do
            local Character = LocalPlayer and LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            local Root = Character and Character:FindFirstChild("HumanoidRootPart")
            local PositionText = "Unavailable"
            if Root then
                local p = Root.Position
                PositionText = string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
            end
            local HealthText = Humanoid and string.format("%.0f / %.0f", Humanoid.Health, Humanoid.MaxHealth) or "Unavailable"
            local SpeedText = Humanoid and string.format("%.1f", Humanoid.WalkSpeed) or "Unavailable"
            PlayerInfoLabel.Text = string.format(
                "NAME: %s\nHEALTH: %s\nWALK SPEED: %s\nPOSITION: %s",
                LocalPlayer and LocalPlayer.Name or "Unavailable",
                HealthText,
                SpeedText,
                PositionText
            )
            task.wait(0.5)
        end
    end)

    -- SHORTNAME HUB EXTRAS: searchable roster, notifications, HUD, keybinds and profiles.
    local HubExtras = {}
    do
    local HttpService = game:GetService("HttpService")
    HubExtras.HubToggleKey = Enum.KeyCode.RightControl
    HubExtras.QuickMenuKey = Enum.KeyCode.RightAlt
    HubExtras.SessionStartedAt = os.clock()
    local SelectedDirectoryPlayer = nil

    local Toast = Instance.new("TextLabel")
    Toast.Name = "ShortNameNotification"
    Toast.Size = UDim2.fromOffset(280, 38)
    Toast.Position = UDim2.new(1, -294, 0, 58)
    Toast.BackgroundColor3 = ButtonDark
    Toast.TextColor3 = White
    Toast.TextSize = 11
    Toast.Font = Enum.Font.GothamBold
    Toast.TextWrapped = true
    Toast.Visible = false
    Toast.ZIndex = 80
    Toast.Parent = Frame
    Corner(Toast, 9)
    Stroke(Toast, PurpleLight, 1.2)
    local ToastToken = 0
    HubExtras.NotificationHistory = {}
    local function Notify(message, duration)
        ToastToken += 1
        local token = ToastToken
        local entry = os.date("%H:%M:%S") .. "  " .. tostring(message)
        table.insert(HubExtras.NotificationHistory, entry)
        while #HubExtras.NotificationHistory > 30 do
            table.remove(HubExtras.NotificationHistory, 1)
        end
        Toast.Text = tostring(message)
        Toast.Visible = true
        if HubExtras.NotificationHistoryText then
            HubExtras.NotificationHistoryText.Text = table.concat(HubExtras.NotificationHistory, "\n")
            HubExtras.NotificationHistoryScroll.CanvasSize = UDim2.fromOffset(0, HubExtras.NotificationHistoryText.AbsoluteSize.Y + 8)
        end
        task.delay(duration or 2.5, function()
            if Toast.Parent and ToastToken == token then Toast.Visible = false end
        end)
    end

    Label(SettingsPage, "PLAYER DIRECTORY", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(SettingsPage, "Live roster. Select a player to copy their username; no character movement.", 10, 32, Grey)
    local DirectorySearch = MakeBox(SettingsPage, "FILTER PLAYERS", "", function() end)
    local DirectoryStatus = Label(SettingsPage, "PLAYERS: --", 10, 20, Grey)
    local DirectoryList = Instance.new("ScrollingFrame")
    DirectoryList.Size = UDim2.new(1, 0, 0, 145)
    DirectoryList.BackgroundColor3 = ButtonDark
    DirectoryList.BorderSizePixel = 0
    DirectoryList.ScrollBarThickness = 5
    DirectoryList.CanvasSize = UDim2.fromOffset(0, 0)
    DirectoryList.AutomaticCanvasSize = Enum.AutomaticSize.None
    DirectoryList.ScrollingDirection = Enum.ScrollingDirection.Y
    DirectoryList.ScrollingEnabled = true
    DirectoryList.Active = true
    DirectoryList.Parent = SettingsPage
    Corner(DirectoryList, 8)
    local DirectoryLayout = Instance.new("UIListLayout")
    DirectoryLayout.Padding = UDim.new(0, 4)
    DirectoryLayout.Parent = DirectoryList
    local DirectoryPadding = Instance.new("UIPadding")
    DirectoryPadding.PaddingTop = UDim.new(0, 5)
    DirectoryPadding.PaddingLeft = UDim.new(0, 5)
    DirectoryPadding.PaddingRight = UDim.new(0, 5)
    DirectoryPadding.Parent = DirectoryList
    DirectoryLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        DirectoryList.CanvasSize = UDim2.fromOffset(0, DirectoryLayout.AbsoluteContentSize.Y + 10)
    end)
    local function RefreshDirectory()
        for _, child in ipairs(DirectoryList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local query = tostring(DirectorySearch.Text or ""):lower()
        local count = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local matches = query == "" or player.Name:lower():find(query, 1, true) or player.DisplayName:lower():find(query, 1, true)
                if matches then
                    count += 1
                    local row = Instance.new("TextButton")
                    row.Size = UDim2.new(1, -2, 0, 30)
                    row.BackgroundColor3 = Panel
                    row.TextColor3 = White
                    row.TextSize = 10
                    row.Font = Enum.Font.Gotham
                    row.TextXAlignment = Enum.TextXAlignment.Left
                    row.Text = "  " .. player.DisplayName .. "  (@" .. player.Name .. ")"
                    row.Parent = DirectoryList
                    Corner(row, 6)
                    row.Activated:Connect(function()
                        SelectedDirectoryPlayer = player
                        local copied = false
                        if type(setclipboard) == "function" then copied = pcall(setclipboard, player.Name) end
                        if not copied and type(toclipboard) == "function" then copied = pcall(toclipboard, player.Name) end
                        DirectoryStatus.Text = "SELECTED: @" .. player.Name .. (copied and " - COPIED" or "")
                        Notify("Selected @" .. player.Name)
                    end)
                end
            end
        end
        DirectoryStatus.Text = "PLAYERS: " .. tostring(count) .. (SelectedDirectoryPlayer and SelectedDirectoryPlayer.Parent and "  |  @" .. SelectedDirectoryPlayer.Name or "")
    end
    DirectorySearch.FocusLost:Connect(RefreshDirectory)
    MakeButton(SettingsPage, "REFRESH PLAYER DIRECTORY", RefreshDirectory)
    local DirectoryAddedConnection = Players.PlayerAdded:Connect(RefreshDirectory)
    local DirectoryRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        if SelectedDirectoryPlayer == player then SelectedDirectoryPlayer = nil end
        RefreshDirectory()
    end)
    ScreenGui.Destroying:Connect(function()
        if DirectoryAddedConnection then DirectoryAddedConnection:Disconnect() end
        if DirectoryRemovingConnection then DirectoryRemovingConnection:Disconnect() end
    end)
    RefreshDirectory()

    Label(SettingsPage, "PERFORMANCE HUD", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    HubExtras.PerformanceHudEnabled = false
    HubExtras.PerformanceHud = Instance.new("TextLabel")
    HubExtras.PerformanceHud.Name = "ShortNamePerformanceHUD"
    HubExtras.PerformanceHud.Size = UDim2.fromOffset(255, 28)
    HubExtras.PerformanceHud.Position = UDim2.new(1, -265, 0, 12)
    HubExtras.PerformanceHud.BackgroundColor3 = Dark
    HubExtras.PerformanceHud.TextColor3 = White
    HubExtras.PerformanceHud.TextSize = 10
    HubExtras.PerformanceHud.Font = Enum.Font.GothamBold
    HubExtras.PerformanceHud.Visible = false
    HubExtras.PerformanceHud.ZIndex = 90
    HubExtras.PerformanceHud.Parent = ScreenGui
    Corner(HubExtras.PerformanceHud, 7)
    Stroke(HubExtras.PerformanceHud, PurpleLight, 1)
    local HudButton
    HudButton = MakeButton(SettingsPage, "PERFORMANCE HUD: OFF", function()
        HubExtras.PerformanceHudEnabled = not HubExtras.PerformanceHudEnabled
        HubExtras.PerformanceHud.Visible = HubExtras.PerformanceHudEnabled
        HudButton.Text = HubExtras.PerformanceHudEnabled and "PERFORMANCE HUD: ON" or "PERFORMANCE HUD: OFF"
        Notify(HubExtras.PerformanceHudEnabled and "Performance HUD enabled" or "Performance HUD disabled")
    end)

    Label(SettingsPage, "CUSTOM KEYBIND", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(SettingsPage, "Change the key used to hide and restore the hub.", 10, 22, Grey)
    local KeybindBox
    KeybindBox = MakeBox(SettingsPage, "HUB TOGGLE KEY (EXAMPLE: F6, INSERT, RIGHTCONTROL)", "RightControl", function(value)
        local keyName = tostring(value or ""):gsub("%s+", "")
        local key = Enum.KeyCode[keyName]
        if key and key ~= Enum.KeyCode.Unknown and key ~= HubExtras.QuickMenuKey then
            HubExtras.HubToggleKey = key
            Notify("Toggle key: " .. key.Name)
        else
            KeybindBox.Text = HubExtras.HubToggleKey.Name
            Notify("Invalid key name")
        end
    end)

    local QuickKeyBox
    QuickKeyBox = MakeBox(SettingsPage, "QUICK MENU KEY (EXAMPLE: F7, RIGHTALT)", "RightAlt", function(value)
        local keyName = tostring(value or ""):gsub("%s+", "")
        local key = Enum.KeyCode[keyName]
        if key and key ~= Enum.KeyCode.Unknown and key ~= HubExtras.HubToggleKey then
            HubExtras.QuickMenuKey = key
            Notify("Quick menu key: " .. key.Name)
        else
            QuickKeyBox.Text = HubExtras.QuickMenuKey.Name
            Notify("Invalid or conflicting quick menu key")
        end
    end)

    Label(SettingsPage, "SAVED PROFILE", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(SettingsPage, "One local profile slot remembers your latest appearance and keybind configuration.", 10, 32, Grey)
    local ProfileStatus = Label(SettingsPage, "PROFILE: READY", 10, 20, Grey)
    local function ProfilePath()
        return "ShortNameHub/default.json"
    end
    local function HasProfileFileAPI()
        return type(makefolder) == "function" and type(writefile) == "function"
            and type(readfile) == "function" and type(isfile) == "function"
    end
    MakeButton(SettingsPage, "SAVE LATEST PROFILE", function()
        if not HasProfileFileAPI() then ProfileStatus.Text = "PROFILE: FILE API UNAVAILABLE" return end
        local path = ProfilePath()
        if not path then ProfileStatus.Text = "PROFILE: INVALID NAME" return end
        pcall(makefolder, "ShortNameHub")
        local payload = {
            accent = CurrentAccent.Name or "Purple",
            accentColor = {
                math.floor(CurrentAccent.Color.R * 255 + 0.5),
                math.floor(CurrentAccent.Color.G * 255 + 0.5),
                math.floor(CurrentAccent.Color.B * 255 + 0.5)
            },
            surface = ActiveSurfacePreset and ActiveSurfacePreset.Name or "MIDNIGHT",
            scale = WindowScale.Scale,
            transparency = Frame.BackgroundTransparency,
            background = GUI.BackgroundImage.Image,
            animations = GUI.AnimationsEnabled,
            toggleKey = HubExtras.HubToggleKey.Name,
            quickMenuKey = HubExtras.QuickMenuKey.Name
        }
        local ok, err = pcall(function() writefile(path, HttpService:JSONEncode(payload)) end)
        ProfileStatus.Text = ok and ("PROFILE: SAVED " .. path) or ("PROFILE: SAVE FAILED " .. tostring(err))
        if ok then Notify("Profile saved") end
    end)
    MakeButton(SettingsPage, "LOAD LATEST PROFILE", function()
        if not HasProfileFileAPI() then ProfileStatus.Text = "PROFILE: FILE API UNAVAILABLE" return end
        local path = ProfilePath(ProfileNameBox.Text)
        if not path or not isfile(path) then ProfileStatus.Text = "PROFILE: NOT FOUND" return end
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if not ok or type(data) ~= "table" then ProfileStatus.Text = "PROFILE: INVALID FILE" return end
        for _, preset in ipairs(AccentPresets) do
            if preset.Name == data.accent then ApplyAccent(preset) break end
        end
        if type(data.accentColor) == "table" and #data.accentColor == 3 then
            local red = math.clamp(tonumber(data.accentColor[1]) or 145, 0, 255)
            local green = math.clamp(tonumber(data.accentColor[2]) or 75, 0, 255)
            local blue = math.clamp(tonumber(data.accentColor[3]) or 255, 0, 255)
            local color = Color3.fromRGB(red, green, blue)
            ApplyAccent({
                Name = data.accent or "Custom",
                Color = color,
                Light = color:Lerp(Color3.new(1, 1, 1), 0.28),
                Active = ButtonDark:Lerp(color, 0.62)
            })
        end
        for _, preset in ipairs(SurfacePresets) do
            if preset.Name == data.surface then ApplySurfaceTheme(preset) ActiveSurfacePreset = preset break end
        end
        if type(data.scale) == "number" then
            WindowScale.Scale = math.clamp(data.scale, 0.72, 1.1)
            GUI.SetScaleSlider(WindowScale.Scale)
        end
        if type(data.transparency) == "number" then
            local amount = math.clamp(data.transparency, 0, 0.6)
            GUI.SetTransparencySlider(amount)
            Frame.BackgroundTransparency = amount
            Header.BackgroundTransparency = math.min(0.7, amount * 0.55)
            Content.BackgroundTransparency = math.min(0.72, 0.18 + amount * 0.55)
            GUI.BackgroundImage.ImageTransparency = math.clamp(0.34 + amount * 0.45, 0, 0.88)
        end
        if type(data.background) == "string" then
            GUI.BackgroundImage.Image = data.background
            GUI.BackgroundUrlBox.Text = data.background
        end
        if type(data.animations) == "boolean" then
            GUI.AnimationsEnabled = data.animations
            GUI.AnimationsToggle.Text = "PAGE ANIMATIONS: " .. (GUI.AnimationsEnabled and "ON" or "OFF")
        end
        if type(data.toggleKey) == "string" and Enum.KeyCode[data.toggleKey] then
            HubExtras.HubToggleKey = Enum.KeyCode[data.toggleKey]
            KeybindBox.Text = HubExtras.HubToggleKey.Name
        end
        if type(data.quickMenuKey) == "string" and Enum.KeyCode[data.quickMenuKey] and Enum.KeyCode[data.quickMenuKey] ~= HubExtras.HubToggleKey then
            HubExtras.QuickMenuKey = Enum.KeyCode[data.quickMenuKey]
            QuickKeyBox.Text = HubExtras.QuickMenuKey.Name
        end
        ProfileStatus.Text = "PROFILE: LOADED " .. path
        Notify("Profile loaded")
    end)

    -- A compact menu in the header gives one-click access to common pages and HUD.
    local QuickMenuButton = Instance.new("TextButton")
    QuickMenuButton.Name = "QuickMenuButton"
    QuickMenuButton.Size = UDim2.fromOffset(30, 30)
    QuickMenuButton.Position = UDim2.new(1, IsCreator and -308 or -206, 0, 8)
    QuickMenuButton.BackgroundColor3 = ButtonDark
    QuickMenuButton.Text = "📋"
    QuickMenuButton.TextColor3 = White
    QuickMenuButton.TextSize = 15
    QuickMenuButton.Font = Enum.Font.GothamBold
    QuickMenuButton.Parent = Header
    QuickMenuButton.ZIndex = 8
    Corner(QuickMenuButton, 8)
    Stroke(QuickMenuButton, Border, 1)
    HubExtras.QuickMenuPanel = Instance.new("Frame")
    HubExtras.QuickMenuPanel.Size = UDim2.fromOffset(184, 244)
    HubExtras.QuickMenuPanel.Position = UDim2.new(1, IsCreator and -316 or -214, 0, 44)
    HubExtras.QuickMenuPanel.BackgroundColor3 = Panel
    HubExtras.QuickMenuPanel.Visible = false
    HubExtras.QuickMenuPanel.ZIndex = 40
    HubExtras.QuickMenuPanel.Parent = Frame
    Corner(HubExtras.QuickMenuPanel, 9)
    Stroke(HubExtras.QuickMenuPanel, PurpleLight, 1)
    HubExtras.NotificationHistoryPanel = Instance.new("Frame")
    HubExtras.NotificationHistoryPanel.Name = "NotificationHistory"
    HubExtras.NotificationHistoryPanel.Size = UDim2.fromOffset(260, 230)
    HubExtras.NotificationHistoryPanel.Position = UDim2.new(1, -270, 0, 48)
    HubExtras.NotificationHistoryPanel.BackgroundColor3 = Panel
    HubExtras.NotificationHistoryPanel.Visible = false
    HubExtras.NotificationHistoryPanel.ZIndex = 60
    HubExtras.NotificationHistoryPanel.Parent = Frame
    Corner(HubExtras.NotificationHistoryPanel, 10)
    Stroke(HubExtras.NotificationHistoryPanel, CurrentAccent.Light, 1.2)
    local historyTitle = Label(HubExtras.NotificationHistoryPanel, "NOTIFICATION HISTORY", 11, 28, CurrentAccent.Light)
    historyTitle.Position = UDim2.fromOffset(10, 4)
    historyTitle.Font = Enum.Font.GothamBold
    local historyClose = Instance.new("TextButton")
    historyClose.Size = UDim2.fromOffset(24, 24)
    historyClose.Position = UDim2.new(1, -29, 0, 4)
    historyClose.BackgroundColor3 = ButtonDark
    historyClose.Text = "❌"
    historyClose.TextColor3 = White
    historyClose.TextSize = 16
    historyClose.Parent = HubExtras.NotificationHistoryPanel
    historyClose.ZIndex = 61
    Corner(historyClose, 6)
    historyClose.Activated:Connect(function() HubExtras.NotificationHistoryPanel.Visible = false end)
    HubExtras.NotificationHistoryScroll = Instance.new("ScrollingFrame")
    HubExtras.NotificationHistoryScroll.Size = UDim2.new(1, -16, 1, -40)
    HubExtras.NotificationHistoryScroll.Position = UDim2.fromOffset(8, 34)
    HubExtras.NotificationHistoryScroll.BackgroundColor3 = ButtonDark
    HubExtras.NotificationHistoryScroll.BorderSizePixel = 0
    HubExtras.NotificationHistoryScroll.ScrollBarThickness = 5
    HubExtras.NotificationHistoryScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
    HubExtras.NotificationHistoryScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    HubExtras.NotificationHistoryScroll.ScrollingEnabled = true
    HubExtras.NotificationHistoryScroll.Active = true
    HubExtras.NotificationHistoryScroll.CanvasSize = UDim2.fromOffset(0, 0)
    HubExtras.NotificationHistoryScroll.ZIndex = 60
    HubExtras.NotificationHistoryScroll.Parent = HubExtras.NotificationHistoryPanel
    Corner(HubExtras.NotificationHistoryScroll, 7)
    HubExtras.NotificationHistoryText = Instance.new("TextLabel")
    HubExtras.NotificationHistoryText.Size = UDim2.new(1, -12, 0, 0)
    HubExtras.NotificationHistoryText.AutomaticSize = Enum.AutomaticSize.Y
    HubExtras.NotificationHistoryText.Position = UDim2.fromOffset(6, 4)
    HubExtras.NotificationHistoryText.BackgroundTransparency = 1
    HubExtras.NotificationHistoryText.TextColor3 = White
    HubExtras.NotificationHistoryText.TextSize = 10
    HubExtras.NotificationHistoryText.Font = Enum.Font.Gotham
    HubExtras.NotificationHistoryText.TextXAlignment = Enum.TextXAlignment.Left
    HubExtras.NotificationHistoryText.TextYAlignment = Enum.TextYAlignment.Top
    HubExtras.NotificationHistoryText.TextWrapped = true
    HubExtras.NotificationHistoryText.Text = "No notifications yet."
    HubExtras.NotificationHistoryText.ZIndex = 61
    HubExtras.NotificationHistoryText.Parent = HubExtras.NotificationHistoryScroll

    local QuickLayout = Instance.new("UIListLayout")
    QuickLayout.Padding = UDim.new(0, 5)
    QuickLayout.Parent = HubExtras.QuickMenuPanel
    local QuickPadding = Instance.new("UIPadding")
    QuickPadding.PaddingTop = UDim.new(0, 6)
    QuickPadding.PaddingLeft = UDim.new(0, 6)
    QuickPadding.PaddingRight = UDim.new(0, 6)
    QuickPadding.Parent = HubExtras.QuickMenuPanel
    local function QuickAction(label, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 28)
        b.BackgroundColor3 = ButtonDark
        b.TextColor3 = White
        b.TextSize = 10
        b.Font = Enum.Font.GothamBold
        b.Text = label
        b.Parent = HubExtras.QuickMenuPanel
        b.ZIndex = 41
        Corner(b, 6)
        b.Activated:Connect(callback)
    end
    QuickAction("GLOBAL SEARCH", function()
        HubExtras.QuickMenuPanel.Visible = false
        GUI.GlobalSearchPanel.Visible = true
    end)
    QuickAction("OPEN UPDATES", function() HubExtras.QuickMenuPanel.Visible = false SelectPage("Updates") end)
    QuickAction("OPEN SETTINGS", function() HubExtras.QuickMenuPanel.Visible = false SelectPage("Settings") end)
    QuickAction("NOTIFICATION HISTORY", function()
        HubExtras.QuickMenuPanel.Visible = false
        HubExtras.NotificationHistoryText.Text = #HubExtras.NotificationHistory > 0 and table.concat(HubExtras.NotificationHistory, "\n") or "No notifications yet."
        HubExtras.NotificationHistoryPanel.Visible = not HubExtras.NotificationHistoryPanel.Visible
    end)
    QuickAction("OPEN PLAYER TOOLS", function() HubExtras.QuickMenuPanel.Visible = false SelectPage("PlayerTools") end)
    QuickAction("TOGGLE PERFORMANCE HUD", function()
        HubExtras.PerformanceHudEnabled = not HubExtras.PerformanceHudEnabled
        HubExtras.PerformanceHud.Visible = HubExtras.PerformanceHudEnabled
        HudButton.Text = HubExtras.PerformanceHudEnabled and "PERFORMANCE HUD: ON" or "PERFORMANCE HUD: OFF"
        HubExtras.QuickMenuPanel.Visible = false
        Notify(HubExtras.PerformanceHudEnabled and "Performance HUD enabled" or "Performance HUD disabled")
    end)
    QuickAction("TEST NOTIFICATION", function() HubExtras.QuickMenuPanel.Visible = false Notify("Notifications are working") end)
    QuickMenuButton.Activated:Connect(function()
        HubExtras.QuickMenuPanel.Visible = not HubExtras.QuickMenuPanel.Visible
        CommunityPanel.Visible = false
        FeedbackPanel.Visible = false
    end)

    end -- scoped extras: keep Luau local-register usage below the compiler limit.

    -- SESSION TOOLS: live diagnostics and copy helpers
    Label(UtilityFolder, "SESSION TOOLS", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(UtilityFolder, "Hub toggle: " .. HubExtras.HubToggleKey.Name .. "  |  Quick menu: " .. HubExtras.QuickMenuKey.Name, 10, 20, Grey)
    local PerformanceLabel = Label(UtilityFolder, "FPS: --  |  PING: --  |  MEMORY: -- MB", 10, 24, White)
    PerformanceLabel.TextWrapped = true

    local RunService = game:GetService("RunService")
    local StatsService = game:GetService("Stats")
    local frameCount = 0
    local lastFps = 0
    PerformanceConnection = RunService.RenderStepped:Connect(function()
        frameCount += 1
    end)

    task.spawn(function()
        while ScreenGui.Parent and PerformanceLabel.Parent do
            task.wait(1)
            lastFps = frameCount
            frameCount = 0
            local pingText = "--"
            local memoryText = "--"
            pcall(function()
                local network = StatsService.Network
                local serverStats = network and network.ServerStatsItem
                local ping = serverStats and serverStats["Data Ping"]
                if ping then
                    pingText = ping:GetValueString()
                end
            end)
            pcall(function()
                memoryText = string.format("%.0f", StatsService:GetTotalMemoryUsageMb())
            end)
            if PerformanceLabel.Parent then
                PerformanceLabel.Text = string.format(
                    "FPS: %d  |  PING: %s  |  MEMORY: %s MB",
                    lastFps,
                    tostring(pingText),
                    tostring(memoryText)
                )
            end
            if HubExtras.PerformanceHud and HubExtras.PerformanceHud.Parent and HubExtras.PerformanceHudEnabled then
                local elapsed = math.max(0, math.floor(os.clock() - HubExtras.SessionStartedAt))
                local sessionText = string.format("%02d:%02d:%02d", math.floor(elapsed / 3600), math.floor(elapsed / 60) % 60, elapsed % 60)
                HubExtras.PerformanceHud.Text = string.format("FPS %d  -  PING %s  -  %s", lastFps, tostring(pingText), sessionText)
            end
        end
    end)

    local function CopyText(value)
        if type(setclipboard) == "function" then
            return pcall(setclipboard, value)
        elseif type(toclipboard) == "function" then
            return pcall(toclipboard, value)
        end
        return false
    end

    MakeButton(UtilityFolder, "COPY PLAYER POSITION", function()
        local Character = LocalPlayer and LocalPlayer.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        if not Root then
            SetStatus("CHARACTER POSITION UNAVAILABLE")
            return
        end
        local p = Root.Position
        local value = string.format("%.3f, %.3f, %.3f", p.X, p.Y, p.Z)
        if CopyText(value) then
            SetStatus("POSITION COPIED")
        else
            SetStatus("CLIPBOARD API UNAVAILABLE")
        end
    end)

    MakeButton(UtilityFolder, "COPY SESSION INFO", function()
        local Character = LocalPlayer and LocalPlayer.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        local position = "Unavailable"
        if Root then
            local p = Root.Position
            position = string.format("%.3f, %.3f, %.3f", p.X, p.Y, p.Z)
        end
        local value = string.format(
            "ShortName Hub Session Info\nPlayer: %s\nUserId: %s\nPlaceId: %s\nJobId: %s\nPosition: %s",
            LocalPlayer and LocalPlayer.Name or "Unavailable",
            LocalPlayer and tostring(LocalPlayer.UserId) or "Unavailable",
            tostring(game.PlaceId),
            tostring(game.JobId),
            position
        )
        if CopyText(value) then
            SetStatus("SESSION INFO COPIED")
        else
            SetStatus("CLIPBOARD API UNAVAILABLE")
        end
    end)

    -- NPC & TELEPORT FOLDER
    local TeleportFolder = MakeFolder("NPC & TELEPORT", HalloweenFolder)

    MakeBox(TeleportFolder, "NPC NAME", Config.TargetName, function(value)
        Config.TargetName = value
        Controller.SetTargetName(value)
    end)

    MakeBox(TeleportFolder, "AIR INTERVAL (SECONDS)", Config.AirInterval, function(value)
        Config.AirInterval = math.clamp(
            tonumber(value) or 5,
            1,
            30
        )
    end)

    MakeBox(TeleportFolder, "AIR TIME (SECONDS)", Config.AirTime, function(value)
        Config.AirTime = math.clamp(
            tonumber(value) or 3,
            1,
            30
        )
    end)

    MakeBox(TeleportFolder, "TP HEIGHT (STUDS)", Config.AirHeight, function(value)
        Config.AirHeight = math.clamp(
            tonumber(value) or 100,
            1,
            1000
        )
    end)

    MakeBox(TeleportFolder, "TP SPEED", Config.TeleportsPerSecond, function(value)
        Config.TeleportsPerSecond = math.clamp(
            tonumber(value) or 1,
            0.1,
            100
        )
    end)

    MakeButton(TeleportFolder, "TELEPORT NOW", function()

        Controller.TeleportNow()
    end)

    local AutoButton
    AutoButton = MakeButton(TeleportFolder, "AUTO TP: OFF", function()
        if Controller.IsEnabled() then
            Controller.Stop()
            AutoButton.Text = "AUTO TP: OFF"

        else
            Controller.Start()
            AutoButton.Text = "AUTO TP: ON"

        end
    end, Color3.fromRGB(45, 115, 75))

    -- REMOTES FOLDER
    local ScytheFolder = MakeFolder("REMOTES", HalloweenFolder); Config.ScytheSpeed = math.clamp(tonumber(Config.ScytheSpeed) or 1, 1, 100)

    MakeBox(ScytheFolder, "SCYTHE ROLL SPEED (1-100 CPS)", Config.ScytheSpeed, function(value)
        Config.ScytheSpeed = math.clamp(
            tonumber(value) or 1,
            1,
            100
        )
        Scythe.SetSpeed(Config.ScytheSpeed)

    end)

    Scythe.SetSpeed(Config.ScytheSpeed); local ScytheButton
    ScytheButton = MakeButton(ScytheFolder, "SCYTHE ENCHANT AUTO ROLL: OFF", function()
        if Scythe.IsEnabled() then
            Scythe.Stop()
            ScytheButton.Text = "SCYTHE ENCHANT AUTO ROLL: OFF"
            SetStatus("SCYTHE ROLL STOPPED")

        else
            local ok, message = Scythe.Start()
            if ok then
                ScytheButton.Text = "SCYTHE ENCHANT AUTO ROLL: ON"
                SetStatus("SCYTHE ROLL RUNNING")

            else
                ScytheButton.Text = "SCYTHE ENCHANT AUTO ROLL: OFF"
                SetStatus(message or "SCYTHE ERROR")
            end
        end
    end, Color3.fromRGB(100, 65, 160))

    -- HOUSE TELEPORT FOLDER
    local HouseFolder = MakeFolder("HOUSE TELEPORT", HalloweenFolder)
    local HousePositions = {
        ["1"] = Vector3.new(-14131.423, 1.804, 8644.894),
        ["2"] = Vector3.new(-14126.336, 1.739, 8901.825),
        ["4"] = Vector3.new(-14236.530, 1.687, 8784.609)
    }
    local HouseOrder = {"1", "2", "4"}; local HouseFallHeight = 12; local HouseTeleportDelay = 1
    local HouseAutoEnabled = false; local HouseLoopToken = 0

    local function GetHouseRoot()
        local Player = Players.LocalPlayer
        if not Player then
            return nil
        end
        local Character = Player.Character
        if not Character then
            return nil
        end
        return Character:FindFirstChild("HumanoidRootPart")
    end

    local function TeleportToHouse(houseName)
        local position = HousePositions[houseName]
        if not position then
            SetStatus("INVALID HOUSE")
            return false
        end
        local Root = GetHouseRoot()
        if not Root then
            SetStatus("CHARACTER NOT READY")
            return false
        end
        Root.CFrame = CFrame.new(position.X, position.Y + HouseFallHeight, position.Z); Root.AssemblyLinearVelocity = Vector3.zero; SetStatus("TELEPORTED TO HOUSE "
        .. houseName)

        return true
    end

    -- HOUSE TELEPORT SLIDER
    local function MakeSlider(parent, title, minimum, maximum, initialValue, step, formatValue, callback)
        local Holder = Instance.new("Frame"); Holder.Size = UDim2.new(1, 0, 0, 54); Holder.BackgroundTransparency = 1
        Holder.Parent = parent; local TitleLabel = Label(Holder, title, 11, 19, Grey); TitleLabel.Position = UDim2.fromOffset(0, 0)
        TitleLabel.Size = UDim2.new(1, -65, 0, 19); local ValueLabel = Label(Holder, formatValue(initialValue), 11, 19, PurpleLight);
        ValueLabel.Position = UDim2.new(1, -65, 0, 0)
        ValueLabel.Size = UDim2.fromOffset(65, 19); ValueLabel.TextXAlignment = Enum.TextXAlignment.Right; ValueLabel.Font = Enum.Font.GothamBold

        local Track = Instance.new("Frame"); Track.Size = UDim2.new(1, -12, 0, 7); Track.Position = UDim2.fromOffset(0, 32)
        Track.BackgroundColor3 = Color3.fromRGB(47, 43, 58); Track.BorderSizePixel = 0; Track.Parent = Holder
        Corner(Track, 5); local Fill = Instance.new("Frame"); Fill.Size = UDim2.new(0, 0, 1, 0)
        Fill.BackgroundColor3 = Purple; Fill.BorderSizePixel = 0; Fill.Parent = Track
        Corner(Fill, 5); local Knob = Instance.new("Frame"); Knob.Size = UDim2.fromOffset(14, 14)
        Knob.AnchorPoint = Vector2.new(0.5, 0.5); Knob.Position = UDim2.new(0, 0, 0.5, 0); Knob.BackgroundColor3 = PurpleLight
        Knob.BorderSizePixel = 0; Knob.Parent = Track; Corner(Knob, 20)
        Stroke(Knob, Color3.fromRGB(235, 220, 255), 1); local Dragging = false; local CurrentValue = initialValue

        local function SetSliderValue(value)
            value = math.clamp(value, minimum, maximum); value = math.floor((value - minimum) / step + 0.5) * step + minimum; value =
            math.clamp(value, minimum, maximum)
            CurrentValue = value; local alpha = (value - minimum) / (maximum - minimum); Fill.Size = UDim2.new(alpha, 0, 1, 0)
            Knob.Position = UDim2.new(alpha, 0, 0.5, 0); ValueLabel.Text = formatValue(value); callback(value)
        end

        local function UpdateFromPosition(x)
            local width = Track.AbsoluteSize.X
            if width <= 0 then
                return
            end
            local alpha = math.clamp((x - Track.AbsolutePosition.X) / width, 0, 1); local value = minimum + (maximum - minimum) * alpha;
            SetSliderValue(value)
        end

        local function BeginDrag(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                Dragging = true; UpdateFromPosition(input.Position.X)
            end
        end

        Track.InputBegan:Connect(BeginDrag); Knob.InputBegan:Connect(BeginDrag)

        UIS.InputChanged:Connect(function(input)
            if not Dragging then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            then
                UpdateFromPosition(input.Position.X)
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                Dragging = false
            end
        end)

        local initialAlpha = (initialValue - minimum)
        / (maximum - minimum)
        Fill.Size = UDim2.new(initialAlpha, 0, 1, 0); Knob.Position = UDim2.new(initialAlpha, 0, 0.5, 0)
        return { SetValue = SetSliderValue, GetValue = function()
            return CurrentValue
        end }
    end

    Label(HouseFolder, "TELEPORT TO THE HALLOWEEN EVENT HOUSES", 11, 25, PurpleLight).Font = Enum.Font.GothamBold
    Label(HouseFolder, "Choose a house to teleport to, or enable automatic cycling.", 10, 34, Grey)
    MakeButton(HouseFolder, "TELEPORT TO HOUSE 1", function()
        TeleportToHouse("1")
    end)
    MakeButton(HouseFolder, "TELEPORT TO HOUSE 2", function()
        TeleportToHouse("2")
    end)
    MakeButton(HouseFolder, "TELEPORT TO HOUSE 4", function()
        TeleportToHouse("4")
    end)

    local HouseAutoButton
    HouseAutoButton = MakeButton(HouseFolder, "AUTO TELEPORT: OFF", function()
        if HouseAutoEnabled then
            HouseAutoEnabled = false
            HouseLoopToken = HouseLoopToken + 1
            HouseAutoButton.Text = "AUTO TELEPORT: OFF"
            SetStatus("HOUSE AUTO TELEPORT STOPPED")

        else
            HouseAutoEnabled = true
            HouseLoopToken = HouseLoopToken + 1
            local thisToken = HouseLoopToken
            HouseAutoButton.Text = "AUTO TELEPORT: ON"
            SetStatus("HOUSE AUTO TELEPORT RUNNING")

            task.spawn(function()
                while HouseAutoEnabled
                    and HouseLoopToken == thisToken
                do
                    for _, houseName in ipairs(HouseOrder) do
                        if not HouseAutoEnabled
                            or HouseLoopToken ~= thisToken
                        then
                            break
                        end
                        TeleportToHouse(houseName)
                        task.wait(HouseTeleportDelay)
                    end
                end
            end)
        end
    end, Color3.fromRGB(45, 115, 75))

    MakeSlider(HouseFolder, "TELEPORT SPEED / DELAY", 0.1, 5, HouseTeleportDelay, 0.1, function(value)
        return string.format("%.1f sec", value)
    end, function(value)
        HouseTeleportDelay = value
    end)

    MakeSlider(HouseFolder, "FALL HEIGHT (STUDS)", 1, 50, HouseFallHeight, 1, function(value)
        return tostring(math.floor(value + 0.5)) .. " studs"
    end, function(value)
        HouseFallHeight = math.floor(value + 0.5)
    end)


    -- COMBAT HUD, ASSET RECOGNITION, AND SAFE HITBOX VISUALIZER
    local CombatToolsFolder = MakeFolder("COMBAT HUD & ASSET TOOLS", FightFolder)
    Label(CombatToolsFolder, "COMBAT HUD", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(CombatToolsFolder, "Shows your own live health, movement speed, and equipped tool. Local display only.", 10, 36, Grey)

    local CombatHudEnabled = false
    local CombatHudToken = 0
    local CombatHudLabel
    local function RemoveCombatHud()
        CombatHudEnabled = false
        CombatHudToken += 1
        if CombatHudLabel then
            CombatHudLabel:Destroy()
            CombatHudLabel = nil
        end
    end

    local CombatHudButton
    CombatHudButton = MakeButton(CombatToolsFolder, "TOGGLE COMBAT HUD: OFF", function()
        CombatHudEnabled = not CombatHudEnabled
        CombatHudToken += 1
        local token = CombatHudToken
        if CombatHudEnabled then
            if not CombatHudLabel then
                CombatHudLabel = Instance.new("TextLabel")
                CombatHudLabel.Name = "ShortNameCombatHUD"
                CombatHudLabel.AnchorPoint = Vector2.new(0.5, 0)
                CombatHudLabel.Position = UDim2.new(0.5, 0, 0, 12)
                CombatHudLabel.Size = UDim2.fromOffset(280, 42)
                CombatHudLabel.BackgroundColor3 = Color3.fromRGB(12, 12, 17)
                CombatHudLabel.BackgroundTransparency = 0.16
                CombatHudLabel.BorderSizePixel = 0
                CombatHudLabel.TextColor3 = White
                CombatHudLabel.TextSize = 12
                CombatHudLabel.Font = Enum.Font.GothamBold
                CombatHudLabel.TextWrapped = true
                CombatHudLabel.Parent = ScreenGui
                Corner(CombatHudLabel, 9)
                Stroke(CombatHudLabel, CurrentAccent.Light, 1.2)
            end
            CombatHudButton.Text = "TOGGLE COMBAT HUD: ON"
            task.spawn(function()
                while CombatHudEnabled and CombatHudToken == token and ScreenGui.Parent do
                    local player = Players.LocalPlayer
                    local character = player and player.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    local healthText = "Health: N/A"
                    local speedText = "Speed: N/A"
                    if humanoid then
                        healthText = string.format("HP: %d/%d", math.floor(humanoid.Health + 0.5), math.floor(humanoid.MaxHealth + 0.5))
                        speedText = string.format("Speed: %.1f", humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed)
                    end
                    local toolName = "None"
                    if character then
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then toolName = tool.Name end
                    end
                    if CombatHudLabel and CombatHudLabel.Parent then
                        CombatHudLabel.Text = healthText .. "   |   " .. speedText .. "\nEquipped: " .. toolName
                    end
                    task.wait(0.25)
                end
            end)
        else
            RemoveCombatHud()
            CombatHudButton.Text = "TOGGLE COMBAT HUD: OFF"
        end
    end, Color3.fromRGB(45, 115, 75))

    Label(CombatToolsFolder, "WEAPON / ASSET RECOGNITION", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(CombatToolsFolder, "Lists known replicated weapon and combat asset folders. Does not load or execute assets.", 10, 36, Grey)
    local AssetStatus = Label(CombatToolsFolder, "ASSET CHECK: NOT RUN", 10, 22, Color3.fromRGB(170, 210, 255))
    local AssetResults = Label(CombatToolsFolder, "Known paths: StyleWeapons, SFX, RaycastHitboxV4, Flying, Packet", 10, 58, Grey)
    AssetResults.TextWrapped = true
    MakeButton(CombatToolsFolder, "SCAN COMBAT ASSETS", function()
        local storage = game:GetService("ReplicatedStorage")
        local names = {"StyleWeapons", "SFX", "RaycastHitboxV4", "Flying", "Packet"}
        local found = {}
        for _, name in ipairs(names) do
            local object = storage:FindFirstChild(name)
            if object then
                local count = 0
                pcall(function() count = #object:GetDescendants() end)
                table.insert(found, name .. " (" .. tostring(count) .. ")")
            end
        end
        AssetStatus.Text = "ASSET CHECK: " .. tostring(#found) .. "/" .. tostring(#names) .. " SYSTEMS FOUND"
        AssetResults.Text = #found > 0 and table.concat(found, "  -  ") or "No known combat asset folders found."
    end, Color3.fromRGB(45, 105, 145))

    Label(CombatToolsFolder, "HITBOX / WEAPON ATTACHMENT VISUALIZER", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(CombatToolsFolder, "Shows named hitbox parts in Workspace and attachment points on your equipped weapon. Attachment markers show origins, not the full raycast hitbox volume.", 10, 48, Grey)
    local HitboxEnabled = false
    local HitboxAdornments = {}
    local HitboxTemplatePreview
    local HitboxPreviewConnection
    local HitboxStatus = Label(CombatToolsFolder, "VISUALIZER: READY", 10, 22, Color3.fromRGB(170, 210, 255))
    local function ClearHitboxVisuals()
        if HitboxPreviewConnection then
            HitboxPreviewConnection:Disconnect()
            HitboxPreviewConnection = nil
        end
        for object, adornment in pairs(HitboxAdornments) do
            pcall(function() adornment:Destroy() end)
            HitboxAdornments[object] = nil
        end
        if HitboxTemplatePreview then
            pcall(function() HitboxTemplatePreview:Destroy() end)
            HitboxTemplatePreview = nil
        end
    end
    local HitboxButton
    HitboxButton = MakeButton(CombatToolsFolder, "HITBOX VISUALIZER: OFF", function()
        HitboxEnabled = not HitboxEnabled
        ClearHitboxVisuals()
        if HitboxEnabled then
            local count = 0
            local function AddPartBox(part)
                if HitboxAdornments[part] then return end
                local adornment = Instance.new("BoxHandleAdornment")
                adornment.Name = "ShortNameHitboxVisual"
                adornment.Adornee = part
                adornment.Size = part.Size
                adornment.Color3 = Color3.fromRGB(255, 75, 95)
                adornment.Transparency = 0.68
                adornment.AlwaysOnTop = true
                adornment.ZIndex = 5
                adornment.Parent = workspace
                HitboxAdornments[part] = adornment
                count += 1
            end
            local function AddAttachmentMarker(attachment)
                if HitboxAdornments[attachment] then return end
                local parentPart = attachment.Parent
                if not parentPart or not parentPart:IsA("BasePart") then return end
                local marker = Instance.new("SphereHandleAdornment")
                marker.Name = "ShortNameWeaponAttachmentMarker"
                marker.Adornee = parentPart
                marker.CFrame = attachment.CFrame
                marker.Radius = 0.2
                marker.Color3 = Color3.fromRGB(255, 190, 65)
                marker.Transparency = 0.18
                marker.AlwaysOnTop = true
                marker.ZIndex = 6
                marker.Parent = workspace
                HitboxAdornments[attachment] = marker
                count += 1
            end

            for _, object in ipairs(workspace:GetDescendants()) do
                if object:IsA("BasePart") then
                    local lowerName = string.lower(object.Name)
                    if string.find(lowerName, "hitbox", 1, true)
                        or string.find(lowerName, "hurtbox", 1, true)
                        or string.find(lowerName, "damagebox", 1, true)
                    then
                        AddPartBox(object)
                    end
                end
            end

            local player = Players.LocalPlayer
            local character = player and player.Character
            local equippedTool = character and character:FindFirstChildOfClass("Tool")
            if equippedTool then
                for _, object in ipairs(equippedTool:GetDescendants()) do
                    if object:IsA("Attachment") then
                        AddAttachmentMarker(object)
                    elseif object:IsA("BasePart") then
                        local lowerName = string.lower(object.Name)
                        if string.find(lowerName, "hit", 1, true)
                            or string.find(lowerName, "hurt", 1, true)
                            or string.find(lowerName, "damage", 1, true)
                        then
                            AddPartBox(object)
                        end
                    end
                end
            end

            -- The scan report found the game's hitbox template in ReplicatedStorage,
            -- not Workspace. Show a clearly-labeled local preview when no live parts exist.
            if count == 0 then
                local storage = game:GetService("ReplicatedStorage")
                local flying = storage:FindFirstChild("Flying")
                local assets = flying and flying:FindFirstChild("Assets")
                local template = assets and assets:FindFirstChild("Hitbox")
                local playerRoot = character and character:FindFirstChild("HumanoidRootPart")
                if template and template:IsA("BasePart") and playerRoot then
                    local preview = template:Clone()
                    preview.Name = "ShortNameHitboxTemplatePreview"
                    for _, child in ipairs(preview:GetChildren()) do
                        child:Destroy()
                    end
                    preview.Anchored = true
                    preview.CanCollide = false
                    preview.CanTouch = false
                    preview.CanQuery = false
                    preview.Material = Enum.Material.Neon
                    preview.Color = Color3.fromRGB(255, 75, 95)
                    preview.Transparency = 0.55
                    preview.CFrame = playerRoot.CFrame * CFrame.new(0, 0, -3)
                    preview.Parent = workspace
                    HitboxTemplatePreview = preview
                    -- Keep the local template preview attached to the character's current
                    -- position, including after respawns or movement while the toggle is on.
                    HitboxPreviewConnection = RunService.RenderStepped:Connect(function()
                        if not HitboxEnabled or not HitboxTemplatePreview or not HitboxTemplatePreview.Parent then
                            return
                        end
                        local currentCharacter = player.Character
                        local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
                        if currentRoot then
                            HitboxTemplatePreview.CFrame = currentRoot.CFrame * CFrame.new(0, 0, -3)
                        end
                    end)
                    count = 1
                    HitboxStatus.Text = "TEMPLATE PREVIEW ONLY - NOT A LIVE HITBOX"
                else
                    HitboxStatus.Text = "NO LIVE HITBOX PARTS OR AVAILABLE TEMPLATE PREVIEW"
                end
            else
                HitboxStatus.Text = tostring(count) .. " LOCAL VISUAL MARKERS SHOWN"
            end
            HitboxButton.Text = "HITBOX VISUALIZER: ON (" .. tostring(count) .. ")"
        else
            HitboxButton.Text = "HITBOX VISUALIZER: OFF"
            HitboxStatus.Text = "VISUALIZER: READY"
        end
    end, Color3.fromRGB(45, 115, 75))

    -- Keep the observer's many working locals in their own function so they
    -- do not consume the main GUI builder's 200-local register budget.
    local StopAttackObserver
    local function BuildObserverTools()
    -- PASSIVE ATTACK OBSERVER: watches new combat-named objects AND samples
    -- existing weapon/hitbox parts for movement. Read-only: no remotes or edits.
    -- Isolate observer locals to keep the GUI builder below Luau register limits.
    do
    local ObserverFolder = MakeFolder("WEAPON MOVEMENT OBSERVER", FightDetectorsFolder, false)
    Label(ObserverFolder, "WEAPON MOVEMENT OBSERVER", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(ObserverFolder, "Tracks new combat objects plus movement of existing weapon/hitbox parts. Start before a fight. Read-only; no remotes are called and no game objects are changed.", 10, 48, Grey)
    local ObserverRunning = false
    local ObserverConnection
    local ObserverSampleConnection
    local ObserverRecords = {}
    local ObserverSeen = {}
    local ObserverTracked = {}
    local ObserverLastSample = 0
    local ObserverStatus = Label(ObserverFolder, "OBSERVER: OFF - NO DATA", 10, 24, Color3.fromRGB(170, 210, 255))
    local ObserverOutput = Label(ObserverFolder, "Start the observer before combat, exchange a few attacks, then stop and upload the report.", 9, 48, Grey)
    ObserverOutput.TextWrapped = true
    ObserverOutput.TextYAlignment = Enum.TextYAlignment.Top

    local ObserverTerms = {"hitbox", "hurtbox", "damage", "attack", "swing", "slash", "projectile", "bullet", "strike", "hit", "weapon", "trail"}
    local function ObserverMatch(object)
        local lowerName = string.lower(tostring(object.Name))
        for _, term in ipairs(ObserverTerms) do
            if string.find(lowerName, term, 1, true) then
                return term
            end
        end
        return nil
    end

    local function AddObserverRecord(className, name, details)
        if #ObserverRecords >= 160 then return end
        table.insert(ObserverRecords, {
            className = tostring(className),
            name = tostring(name),
            details = tostring(details)
        })
        ObserverStatus.Text = "OBSERVER: " .. tostring(#ObserverRecords) .. " EVENTS RECORDED"
    end

    local function TrackObserverObject(object, source)
        if not ObserverRunning or not object or ObserverTracked[object] then return end
        if not object:IsA("BasePart") then return end
        local matched = ObserverMatch(object)
        if not matched then return end
        local ok, position, path, className, name = pcall(function()
            return object.Position, object:GetFullName(), object.ClassName, object.Name
        end)
        if not ok then return end
        ObserverTracked[object] = {
            lastPosition = position,
            lastTime = os.clock(),
            maxSpeed = 0,
            maxDelta = 0,
            movementEvents = 0,
            burstEvents = 0,
            outlierJumps = 0,
            path = path,
            matched = matched,
            className = className,
            name = name,
            source = source
        }
        if not ObserverSeen[object] then
            ObserverSeen[object] = true
            AddObserverRecord(className, name, "tracked part | match=" .. matched .. " | source=" .. source .. " | position="
                .. string.format("%.1f,%.1f,%.1f", position.X, position.Y, position.Z) .. " | path=" .. path)
        end
    end

    StopAttackObserver = function()
        ObserverRunning = false
        if ObserverConnection then
            ObserverConnection:Disconnect()
            ObserverConnection = nil
        end
        if ObserverSampleConnection then
            ObserverSampleConnection:Disconnect()
            ObserverSampleConnection = nil
        end
    end
    GUI.StopAttackObserver = StopAttackObserver

    local function BuildObserverReport()
        local report = {
            "SHORTNAME HUB - PASSIVE ATTACK OBSERVER",
            "Mode: Workspace DescendantAdded + read-only sampling of existing/new combat-named BaseParts; no remotes invoked; no game objects modified.",
            "Captured events: " .. tostring(#ObserverRecords),
            "Tracked moving parts: " .. tostring((function()
                local count = 0
                for _ in pairs(ObserverTracked) do count = count + 1 end
                return count
            end)()),
            "----------------------------------------"
        }
        for index, entry in ipairs(ObserverRecords) do
            table.insert(report, string.format("%d. [%s] %s | %s", index, entry.className, entry.name, entry.details))
        end
        local movementCount = 0
        for object, data in pairs(ObserverTracked) do
            if data.movementEvents > 0 or data.outlierJumps > 0 then
                movementCount = movementCount + 1
                table.insert(report, string.format(
                    "MOVEMENT %d. [%s] %s | normalChanges=%d | possibleBursts=%d | filteredMaxDelta=%.2f studs | filteredMaxSpeed=%.1f studs/s | ignoredLargeJumps=%d | match=%s | path=%s",
                    movementCount, data.className, data.name, data.movementEvents,
                    data.burstEvents, data.maxDelta, data.maxSpeed, data.outlierJumps, data.matched, data.path
                ))
            end
        end
        if #ObserverRecords == 0 then
            table.insert(report, "No matching combat objects were observed.")
        end
        if movementCount == 0 then
            table.insert(report, "No measurable movement changes were detected on tracked combat-named parts.")
        end
        return table.concat(report, "\n")
    end

    local ObserverButton
    ObserverButton = MakeButton(ObserverFolder, "START ATTACK OBSERVER", function()
        if ObserverRunning then
            StopAttackObserver()
            local moving = 0
            for _, data in pairs(ObserverTracked) do
                if data.movementEvents > 0 then moving = moving + 1 end
            end
            ObserverButton.Text = "START ATTACK OBSERVER"
            ObserverStatus.Text = "OBSERVER: STOPPED - " .. tostring(#ObserverRecords) .. " EVENTS / " .. tostring(moving) .. " MOVING"
            ObserverOutput.Text = "Captured " .. tostring(#ObserverRecords) .. " events and detected movement on " .. tostring(moving) .. " tracked parts. Upload or copy the report."
            return
        end

        ObserverRecords = {}
        ObserverSeen = {}
        ObserverTracked = {}
        ObserverLastSample = 0
        ObserverRunning = true
        ObserverButton.Text = "STOP ATTACK OBSERVER"
        ObserverStatus.Text = "OBSERVER: LISTENING - FIGHT NOW"
        ObserverOutput.Text = "Scanning existing combat parts and listening for new ones..."

        -- Include parts that already exist before the observer starts.
        local scanned = 0
        for _, object in ipairs(workspace:GetDescendants()) do
            if scanned >= 12000 then break end
            scanned = scanned + 1
            if object:IsA("BasePart") then
                TrackObserverObject(object, "present-at-start")
            end
        end

        -- Record newly replicated named objects, including trails and attachments.
        ObserverConnection = workspace.DescendantAdded:Connect(function(object)
            if not ObserverRunning or #ObserverRecords >= 160 then return end
            local ok, name, className = pcall(function()
                return object.Name, object.ClassName
            end)
            if not ok then return end
            local matched = ObserverMatch(object)
            if not matched then return end
            local allowedClass = object:IsA("BasePart") or object:IsA("Attachment")
                or object:IsA("Trail") or object:IsA("Beam")
                or object:IsA("ParticleEmitter") or object:IsA("Model")
            if not allowedClass then return end
            local path = ""
            local details = "match=" .. matched .. " | source=DescendantAdded"
            pcall(function()
                path = object:GetFullName()
                if object:IsA("BasePart") then
                    details = details .. string.format(" | size=%.2f,%.2f,%.2f | position=%.1f,%.1f,%.1f",
                        object.Size.X, object.Size.Y, object.Size.Z,
                        object.Position.X, object.Position.Y, object.Position.Z)
                elseif object:IsA("Attachment") then
                    local parent = object.Parent
                    details = details .. " | parent=" .. (parent and parent.Name or "none")
                end
            end)
            if not ObserverSeen[object] then
                ObserverSeen[object] = true
                AddObserverRecord(className, name, details .. " | path=" .. path)
            end
            if object:IsA("BasePart") then
                TrackObserverObject(object, "newly-added")
            end
        end)

        -- Sample position periodically rather than every frame to keep overhead low.
        local RunService = game:GetService("RunService")
        ObserverSampleConnection = RunService.Heartbeat:Connect(function()
            if not ObserverRunning then return end
            local now = os.clock()
            if now - ObserverLastSample < 0.08 then return end
            ObserverLastSample = now
            for object, data in pairs(ObserverTracked) do
                if object and object.Parent then
                    local ok, position = pcall(function() return object.Position end)
                    if ok then
                        local delta = (position - data.lastPosition).Magnitude
                        local elapsed = math.max(now - data.lastTime, 0.001)
                        if delta >= 25 then
                            -- Large discontinuities are logged separately; they may be
                            -- teleports or replication corrections, not attack motion.
                            data.outlierJumps = data.outlierJumps + 1
                        elseif delta >= 0.18 then
                            data.movementEvents = data.movementEvents + 1
                            data.maxDelta = math.max(data.maxDelta, delta)
                            data.maxSpeed = math.max(data.maxSpeed, delta / elapsed)
                            if delta >= 0.75 then
                                data.burstEvents = data.burstEvents + 1
                            end
                        end
                        data.lastPosition = position
                        data.lastTime = now
                    end
                end
            end
        end)
    end, Color3.fromRGB(45, 105, 145))

    MakeButton(ObserverFolder, "COPY ATTACK OBSERVER REPORT", function()
        local report = BuildObserverReport()
        local copied = false
        if type(setclipboard) == "function" then
            copied = pcall(function() setclipboard(report) end)
        end
        if not copied and type(toclipboard) == "function" then
            copied = pcall(function() toclipboard(report) end)
        end
        ObserverStatus.Text = copied and "OBSERVER REPORT COPIED" or "CLIPBOARD UNAVAILABLE"
        ObserverOutput.Text = copied and "Report copied. Paste it into this chat." or "Clipboard API unavailable in this executor."
    end, Color3.fromRGB(45, 105, 145))

    local ObserverUploadKey = ""
    MakeBox(ObserverFolder, "CLOUDFLARE UPLOAD KEY", "", function(value)
        ObserverUploadKey = value
    end)
    MakeButton(ObserverFolder, "UPLOAD ATTACK OBSERVER REPORT", function()
        if ObserverUploadKey == "" then
            ObserverStatus.Text = "ENTER UPLOAD KEY FIRST"
            return
        end
        ObserverStatus.Text = "UPLOADING OBSERVER REPORT..."
        task.spawn(function()
            local requestFunction
            if type(request) == "function" then
                requestFunction = request
            elseif type(http_request) == "function" then
                requestFunction = http_request
            elseif syn and type(syn.request) == "function" then
                requestFunction = syn.request
            elseif http and type(http.request) == "function" then
                requestFunction = http.request
            elseif fluxus and type(fluxus.request) == "function" then
                requestFunction = fluxus.request
            end
            if not requestFunction then
                ObserverStatus.Text = "HTTP REQUEST API UNAVAILABLE"
                return
            end
            local HttpService = game:GetService("HttpService")
            local payload = HttpService:JSONEncode({ report = BuildObserverReport() })
            local ok, response = pcall(function()
                return requestFunction({
                    Url = "https://shortname-report-receive.ryft-amv.workers.dev/upload",
                    Method = "POST",
                    Timeout = 45,
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["x-upload-key"] = ObserverUploadKey
                    },
                    Body = payload
                })
            end)
            if not ok or type(response) ~= "table" then
                ObserverStatus.Text = "UPLOAD REQUEST FAILED"
                ObserverOutput.Text = tostring(response)
                return
            end
            local statusCode = response.StatusCode or response.Status or response.status_code
            local responseBody = response.Body or response.body or ""
            if statusCode ~= 200 then
                ObserverStatus.Text = "UPLOAD FAILED: HTTP " .. tostring(statusCode)
                ObserverOutput.Text = tostring(responseBody)
                return
            end
            local decodedOk, decoded = pcall(function()
                return HttpService:JSONDecode(responseBody)
            end)
            if decodedOk and type(decoded) == "table" and decoded.ok == true and decoded.github == "saved" then
                ObserverStatus.Text = "OBSERVER REPORT UPLOADED TO GITHUB"
                ObserverOutput.Text = "Upload confirmed by the report receiver."
            else
                ObserverStatus.Text = "SERVER DID NOT CONFIRM GITHUB SAVE"
                ObserverOutput.Text = tostring(responseBody)
            end
        end)
    end, Color3.fromRGB(45, 105, 145))

    end
    BuildObserverTools()

    end

    ScreenGui.Destroying:Connect(function()
        if GUI.StopSlapDetector then pcall(GUI.StopSlapDetector) end
        if GUI.StopSlapDetector then pcall(GUI.StopSlapDetector) end
        RemoveCombatHud()
        HitboxEnabled = false
        ClearHitboxVisuals()
        if GUI.StopAttackObserver then GUI.StopAttackObserver() end
    end)

    -- COMING SOON PAGE
    Label(SoonPage, "COMING SOON", 17, 30).Font = Enum.Font.GothamBold; Label(SoonPage, "More features are being worked on.", 12, 25, Grey); local
    SoonCard = Instance.new("Frame")
    SoonCard.Size = UDim2.new(1, 0, 0, 75); SoonCard.BackgroundColor3 = ButtonDark; SoonCard.BorderSizePixel = 0
    SoonCard.Parent = SoonPage; Corner(SoonCard, 10); Stroke(SoonCard, Border, 1)
    AddGradient(SoonCard, Color3.fromRGB(36, 31, 49), ButtonDark, 90); local SoonText = Label(SoonCard, "Stay tuned for future updates!", 12, 75,
    White)
    SoonText.TextXAlignment = Enum.TextXAlignment.Center

    -- Put the working feedback form directly on the Coming Soon page.
    FeedbackPanel.Parent = SoonPage
    FeedbackPanel.Position = UDim2.new(0, 0, 0, 0)
    FeedbackPanel.Size = UDim2.new(1, 0, 0, 226)
    SoonCard.LayoutOrder = 1
    FeedbackPanel.LayoutOrder = 2
    FeedbackPanel.Position = UDim2.new(0, 0, 0, 0)
    FeedbackPanel.BackgroundColor3 = ButtonDark
    FeedbackPanel.Visible = true
    FeedbackPanel.ZIndex = 2
    FeedbackTitle.Text = "  SEND FEEDBACK"
    FeedbackStatus.Text = "Share an idea or report a problem. Your message goes to the private hub feedback inbox."
    FeedbackStatus.Size = UDim2.new(1, -20, 0, 30)
    FeedbackStatus.TextSize = 9
    FeedbackBox.ZIndex = 6
    FeedbackSend.ZIndex = 6
    FeedbackClose.Visible = false

    -- MINIMIZE BUBBLE
    local Bubble = Instance.new("TextButton"); Bubble.Name = "ShortNameBubble"; Bubble.Size = UDim2.fromOffset(55, 55)
    Bubble.Position = UDim2.new(0, 15, 0.5, -27); Bubble.BackgroundColor3 = Dark; Bubble.Text = "SN"
    Bubble.TextColor3 = White; Bubble.TextSize = 17; Bubble.Font = Enum.Font.GothamBold
    Bubble.Visible = false; Bubble.Parent = ScreenGui; Corner(Bubble, 50)
    AddGradient(Bubble, Color3.fromRGB(42, 31, 62), Dark, 90); Stroke(Bubble, PurpleLight, 2); AddHover(Bubble, Dark, Color3.fromRGB(43, 33, 61))
    local Minimized = false

    MinButton.Activated:Connect(function()
        if Minimized then
            return
        end
        Minimized = true
        Tween(
            WindowScale,
            {
                Scale = 0.78
            },
            TweenInfo.new(
                0.2,
                Enum.EasingStyle.Back,
                Enum.EasingDirection.In
            )
        )
        task.delay(0.16, function()
            if ScreenGui.Parent and Minimized then
                Frame.Visible = false
                Bubble.Visible = true
                Bubble.Size = UDim2.fromOffset(42, 42)
                Tween(
                    Bubble,
                    {
                        Size = UDim2.fromOffset(55, 55)
                    },
                    TweenInfo.new(
                        0.24,
                        Enum.EasingStyle.Back,
                        Enum.EasingDirection.Out
                    )
                )
            end
        end)
    end)

    Bubble.Activated:Connect(function()
        Minimized = false
        Bubble.Visible = false
        Frame.Visible = true
        WindowScale.Scale = 0.78
        Tween(
            WindowScale,
            {
                Scale = 1
            },
            TweenInfo.new(
                0.28,
                Enum.EasingStyle.Back,
                Enum.EasingDirection.Out
            )
        )
    end)

    -- The configured hub toggle key minimizes/restores the hub without stealing
    -- keyboard input while a text field is focused.
    HubToggleConnection = UIS.InputBegan:Connect(function(input, processed)
        if processed or UIS:GetFocusedTextBox() then
            return
        end
        if input.KeyCode == HubExtras.HubToggleKey then
            if Minimized then
                Minimized = false
                Bubble.Visible = false
                Frame.Visible = true
                WindowScale.Scale = 1
            else
                Minimized = true
                Frame.Visible = false
                Bubble.Visible = true
            end
        elseif input.KeyCode == Enum.KeyCode.K
            and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then
            GUI.GlobalSearchPanel.Visible = not GUI.GlobalSearchPanel.Visible
        elseif input.KeyCode == HubExtras.QuickMenuKey then
            HubExtras.QuickMenuPanel.Visible = not HubExtras.QuickMenuPanel.Visible
        end
    end)

    -- WINDOW DRAGGING: keep state on HubExtras to avoid exhausting
    -- the parent function's Luau local-register budget.
    HubExtras.WindowDragState = {
        Dragging = false,
        DragInput = nil,
        DragStart = nil,
        StartPosition = nil
    }

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            HubExtras.WindowDragState.Dragging = true
            HubExtras.WindowDragState.DragStart = input.Position
            HubExtras.WindowDragState.StartPosition = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    HubExtras.WindowDragState.Dragging = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        then
            HubExtras.WindowDragState.DragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == HubExtras.WindowDragState.DragInput
            and HubExtras.WindowDragState.Dragging
        then
            Frame.Position = UDim2.new(
                HubExtras.WindowDragState.StartPosition.X.Scale,
                HubExtras.WindowDragState.StartPosition.X.Offset
                    + (input.Position - HubExtras.WindowDragState.DragStart).X,
                HubExtras.WindowDragState.StartPosition.Y.Scale,
                HubExtras.WindowDragState.StartPosition.Y.Offset
                    + (input.Position - HubExtras.WindowDragState.DragStart).Y
            )
        end
    end)

    -- BUBBLE DRAGGING: isolate locals in a separate callback scope.
    task.spawn(function()
    local BubbleDragging = false; local BubbleInput; local BubbleStart
    local BubblePosition

    Bubble.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            BubbleDragging = true
            BubbleInput = input
            BubbleStart = input.Position
            BubblePosition = Bubble.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    BubbleDragging = false
                end
            end)
        end
    end)

    Bubble.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        then
            BubbleInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == BubbleInput and BubbleDragging then
            local delta = input.Position - BubbleStart
            Bubble.Position = UDim2.new(
                BubblePosition.X.Scale,
                BubblePosition.X.Offset + delta.X,
                BubblePosition.Y.Scale,
                BubblePosition.Y.Offset + delta.Y
            )
        end
    end)
    end)

    -- EXIT
    ExitButton.Activated:Connect(function()
        pcall(function()
            Controller.Stop()
        end)
        pcall(function()
            Scythe.Stop()
        end)
        pcall(function()
            if ThanksgivingScanner and type(ThanksgivingScanner.Stop) == "function" then
                ThanksgivingScanner:Stop()
            end
        end)
        pcall(function()
            if FightScanner and type(FightScanner.Stop) == "function" then
                FightScanner:Stop()
            end
        end)
        pcall(function()
            if FightInspector and type(FightInspector.Clear) == "function" then
                FightInspector:Clear()
            end
        end)
        pcall(function()
            if FightStructureScanner and type(FightStructureScanner.Stop) == "function" then
                FightStructureScanner:Stop()
            end
        end)
        RemoveCombatHud()
        HitboxEnabled = false
        ClearHitboxVisuals()
        HouseAutoEnabled = false
        HouseLoopToken = HouseLoopToken + 1
        ScreenGui:Destroy()
    end)

    BuildUpdatesPage(GUI.UpdatesPage, Config, CurrentAccent, ButtonDark, Border, White, Grey, Label, Corner, Stroke, Tween)
    SelectPage("Updates"); Tween(WindowScale, { Scale = 1 }, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
    if Camera then
        GUI.ViewportConnection = Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if not Frame.Parent then return end
            local newViewport = Camera.ViewportSize
            WindowWidth = math.max(280, math.min(900, newViewport.X - 24))
            WindowHeight = math.max(340, math.min(650, newViewport.Y - 24))
            Frame.Size = UDim2.fromOffset(WindowWidth, WindowHeight)
            Frame.Position = UDim2.new(0.5, -WindowWidth / 2, 0.5, -WindowHeight / 2)
            SidebarWidth = GUI.SidebarCollapsed and 58 or math.min(166, WindowWidth * 0.28)
            Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -76)
            Content.Position = UDim2.new(0, SidebarWidth + 20, 0, 58)
            Content.Size = UDim2.new(1, -SidebarWidth - 30, 1, -68)
        end)
        ScreenGui.Destroying:Connect(function()
            if GUI.ViewportConnection then
                GUI.ViewportConnection:Disconnect()
                GUI.ViewportConnection = nil
            end
        end)
    end
    return { SetStatus = SetStatus, ScreenGui = ScreenGui }
end

return GUI
