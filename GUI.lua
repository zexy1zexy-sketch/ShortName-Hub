local Players = game:GetService("Players"); local UIS = game:GetService("UserInputService"); local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService"); local GUI = {}

function GUI.Create(Config, Controller, Scythe, ThanksgivingScanner, FightScanner, FightInspector, RefreshCallback)
    local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "ShortNameHub"; ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local success = pcall(function()
        ScreenGui.Parent = gethui()
    end)
    if not success then
        ScreenGui.Parent = game:GetService("CoreGui")
    end

    local Camera = workspace.CurrentCamera; local Viewport = Camera and Camera.ViewportSize or Vector2.new(800, 600); local WindowWidth =
    math.max(300, math.min(620, Viewport.X - 20))
    local WindowHeight = math.max(300, math.min(430, Viewport.Y - 40)); local Purple = Color3.fromRGB(145, 75, 255); local Dark = Color3.fromRGB(12,
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
        button.MouseEnter:Connect(function()
            Tween(button, {
                BackgroundColor3 = hoverColor
            })
        end)
        button.MouseLeave:Connect(function()
            Tween(button, {
                BackgroundColor3 = normalColor
            })
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
    Frame.BackgroundColor3 = Dark; Frame.BorderSizePixel = 0; Frame.Parent = ScreenGui
    local WindowScale = Instance.new("UIScale"); WindowScale.Scale = 0.94; WindowScale.Parent = Frame
    Corner(Frame, 14); AddGradient(Frame, Color3.fromRGB(19, 18, 27), Dark, 90); Stroke(Frame, Color3.fromRGB(105, 76, 150), 1.25)

    local AccentLine = Instance.new("Frame"); AccentLine.Name = "AccentLine"; AccentLine.Size = UDim2.new(1, -28, 0, 2)
    AccentLine.Position = UDim2.fromOffset(14, 48); AccentLine.BackgroundColor3 = Purple; AccentLine.BorderSizePixel = 0
    AccentLine.ZIndex = 3; AccentLine.Parent = Frame; AddGradient(AccentLine, PurpleLight, Purple, 0)
    Corner(AccentLine, 2)

    -- HEADER
    local Header = Instance.new("Frame"); Header.Size = UDim2.new(1, 0, 0, 48); Header.BackgroundColor3 = Dark
    Header.BorderSizePixel = 0; Header.Parent = Frame; Corner(Header, 12)
    AddGradient(Header, Color3.fromRGB(31, 25, 43), Dark, 90); local HeaderTitle = Label(Header, "  SHORTNAME HUB", 15, 48); HeaderTitle.Font =
    Enum.Font.GothamBold
    HeaderTitle.Size = UDim2.new(1, -110, 0, 25); HeaderTitle.Position = UDim2.fromOffset(2, 5); HeaderTitle.TextSize = 15
    local HeaderSubtitle = Label(Header, "CONTROL CENTER  •  PREMIUM BUILD", 8, 14, Grey); HeaderSubtitle.Position = UDim2.fromOffset(15, 27)
    HeaderSubtitle.Size = UDim2.new(1, -130, 0, 13); HeaderSubtitle.Font = Enum.Font.GothamMedium; HeaderSubtitle.TextTransparency = 0.12

    local MinButton = Instance.new("TextButton"); MinButton.Size = UDim2.fromOffset(38, 34); MinButton.Position = UDim2.new(1, -88, 0, 7)
    MinButton.BackgroundColor3 = ButtonDark; MinButton.Text = "—"; MinButton.TextColor3 = White
    MinButton.TextSize = 19; MinButton.Font = Enum.Font.GothamBold; MinButton.Parent = Frame
    MinButton.ZIndex = 5; Corner(MinButton, 8); Stroke(MinButton, Border, 1)
    AddHover(MinButton, ButtonDark, Color3.fromRGB(55, 48, 69))

    local ExitButton = Instance.new("TextButton"); ExitButton.Size = UDim2.fromOffset(38, 34)
    ExitButton.Position = UDim2.new(1, -44, 0, 7); ExitButton.BackgroundColor3 = ButtonDark; ExitButton.Text = "×"
    ExitButton.TextColor3 = Color3.fromRGB(255, 170, 180); ExitButton.TextSize = 23; ExitButton.Font = Enum.Font.Gotham
    ExitButton.Parent = Header; Corner(ExitButton, 8); Stroke(ExitButton, Border, 1)
    AddHover(ExitButton, ButtonDark, Color3.fromRGB(95, 43, 55))

    -- SIDEBAR
    local SidebarWidth = math.min(155, WindowWidth * 0.34); local Sidebar = Instance.new("Frame"); Sidebar.Position = UDim2.fromOffset(10, 58)
    Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -68); Sidebar.BackgroundColor3 = Panel; Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Frame; Corner(Sidebar, 11); AddGradient(Sidebar, Color3.fromRGB(27, 26, 37), Panel, 90)
    Stroke(Sidebar, Border, 1); local SideLayout = Instance.new("UIListLayout"); SideLayout.Padding = UDim.new(0, 7)
    SideLayout.SortOrder = Enum.SortOrder.LayoutOrder; SideLayout.Parent = Sidebar; local SidePadding = Instance.new("UIPadding")
    SidePadding.PaddingTop = UDim.new(0, 9); SidePadding.PaddingLeft = UDim.new(0, 8); SidePadding.PaddingRight = UDim.new(0, 8)
    SidePadding.Parent = Sidebar

    local function MakeNav(text, order)
        local b = Instance.new("TextButton"); b.Name = text; b.LayoutOrder = order
        b.Size = UDim2.new(1, 0, 0, 43); b.BackgroundColor3 = ButtonDark; b.TextColor3 = White
        b.Text = text; b.TextSize = WindowWidth < 380 and 11 or 13; b.Font = Enum.Font.GothamBold
        b.Parent = Sidebar; Corner(b, 8); Stroke(b, Border, 1)
        return b
    end

    local SettingsNav = MakeNav("⚙  Settings", 1); local GameNav = MakeNav("◆  Noob Incremental", 2)
    local FightNav = MakeNav("⚔  Fight on a Baseplate", 3); local SoonNav = MakeNav("＋  Coming Soon", 4)

    -- CONTENT AREA
    local Content = Instance.new("Frame"); Content.Position = UDim2.new(0, SidebarWidth + 20, 0, 58); Content.Size = UDim2.new(1, -SidebarWidth - 30,
    1, -68)
    Content.BackgroundColor3 = Panel; Content.BorderSizePixel = 0; Content.Parent = Frame
    Corner(Content, 11); AddGradient(Content, Color3.fromRGB(27, 26, 37), Panel, 90); Stroke(Content, Border, 1)

    local function MakePage(name)
        local page = Instance.new("ScrollingFrame"); page.Name = name; page.Size = UDim2.new(1, -16, 1, -16)
        page.Position = UDim2.fromOffset(8, 8); page.BackgroundTransparency = 1; page.BorderSizePixel = 0
        page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = Purple; page.CanvasSize = UDim2.fromOffset(0, 0)
        page.Visible = false; page.Parent = Content; local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = page
        local padding = Instance.new("UIPadding"); padding.PaddingBottom = UDim.new(0, 10); padding.Parent = page

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.fromOffset(
                0,
                layout.AbsoluteContentSize.Y + 15
            )
        end)
        return page
    end

    local SettingsPage = MakePage("Settings"); local GamePage = MakePage("NoobIncremental")
    local FightPage = MakePage("FightOnABaseplate"); local SoonPage = MakePage("ComingSoon"); local CurrentPage = nil; local CurrentAccent = { Color = Purple, Light = PurpleLight, Active =
    Color3.fromRGB(55, 42, 77) }

    local function SelectPage(page)
        local pages = { Settings = SettingsPage, Game = GamePage, Fight = FightPage, Soon = SoonPage }
        for name, pageObject in pairs(pages) do
            if name == page then
                pageObject.Visible = true; pageObject.Position = UDim2.fromOffset(15, 8)
                Tween(pageObject, { Position = UDim2.fromOffset(8, 8) }, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            else
                pageObject.Visible = false
            end
        end

        CurrentPage = page; local activeColor = CurrentAccent.Active

        local function StyleNav(button, active)
            Tween(button, { BackgroundColor3 = active and activeColor or ButtonDark }); local outline = button:FindFirstChildOfClass("UIStroke")
            if outline then
                Tween(outline, { Color = active and PurpleLight or Border, Transparency = active and 0 or 0.18, Thickness = active and 1.35 or 1 })
            end
            button.TextColor3 = active
            and Color3.fromRGB(255, 255, 255)
            or Grey
        end

        StyleNav(SettingsNav, page == "Settings"); StyleNav(GameNav, page == "Game")
        StyleNav(FightNav, page == "Fight"); StyleNav(SoonNav, page == "Soon")
    end

    SettingsNav.Activated:Connect(function()
        SelectPage("Settings")
    end)
    GameNav.Activated:Connect(function()
        SelectPage("Game")
    end)
    FightNav.Activated:Connect(function()
        SelectPage("Fight")
    end)
    SoonNav.Activated:Connect(function()
        SelectPage("Soon")
    end)

    -- SETTINGS
    Label(SettingsPage, "SETTINGS", 17, 30).Font = Enum.Font.GothamBold; Label(SettingsPage, "Personalize your hub experience.", 12, 23, Grey)
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

    local function ApplyAccent(preset)
        local old = CurrentAccent; CurrentAccent = preset
        for _, o in ipairs(ScreenGui:GetDescendants()) do
            if o:IsA("UIStroke") and IsAccentColor(o.Color) then
                o.Color = preset.Light
            elseif o:IsA("ScrollingFrame")
                and (o.ScrollBarImageColor3 == Purple or o.ScrollBarImageColor3 == old.Color)
            then
                o.ScrollBarImageColor3 = preset.Color
            elseif o:IsA("TextLabel") or o:IsA("TextButton") then
                if o.TextColor3 == Purple
                    or o.TextColor3 == PurpleLight
                    or o.TextColor3 == old.Light
                then
                    o.TextColor3 = preset.Light
                end
                if o:IsA("TextButton")
                    and (o.BackgroundColor3 == old.Active or o.BackgroundColor3 == Color3.fromRGB(75, 50, 115) or o.BackgroundColor3 ==
                    Color3.fromRGB(100, 65, 160))
                then
                    o.BackgroundColor3 = preset.Active
                end
            end
        end

        Purple = preset.Color; PurpleLight = preset.Light
        for _, nav in ipairs({ SettingsNav, GameNav, SoonNav }) do
            local active =
            (CurrentPage == "Settings" and nav == SettingsNav)
            or (CurrentPage == "Game" and nav == GameNav)
            or (CurrentPage == "Soon" and nav == SoonNav)
            if active then
                nav.BackgroundColor3 = preset.Active; local st = nav:FindFirstChildOfClass("UIStroke")
                if st then
                    st.Color = preset.Light
                end
            end
        end

        for name, b in pairs(CategoryButtons) do
            if name == SelectedCategory then
                b.BackgroundColor3 = preset.Active; local st = b:FindFirstChildOfClass("UIStroke")
                if st then
                    st.Color = preset.Light
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

    Label(SettingsPage, "Window size", 11, 19, Grey); local SizeRow = Instance.new("Frame"); SizeRow.Size = UDim2.new(1, 0, 0, 34)
    SizeRow.BackgroundTransparency = 1; SizeRow.Parent = SettingsPage; local SizeLayout = Instance.new("UIListLayout")
    SizeLayout.FillDirection = Enum.FillDirection.Horizontal; SizeLayout.Padding = UDim.new(0, 6); SizeLayout.Parent = SizeRow

    for _, preset in ipairs({ {Name = "SMALL", Scale = 0.82}, {Name = "MEDIUM", Scale = 1}, {Name = "LARGE", Scale = 1.15} }) do
        local b = Instance.new("TextButton"); b.Size = UDim2.new(1 / 3, -5, 1, 0); b.BackgroundColor3 = ButtonDark
        b.Text = preset.Name; b.TextColor3 = White; b.TextSize = 10
        b.Font = Enum.Font.GothamBold; b.Parent = SizeRow; Corner(b, 7)
        Stroke(b, Border, 1); AddHover(b, ButtonDark, Color3.fromRGB(55, 48, 69))

        b.Activated:Connect(function()
            Tween(
                WindowScale,
                {
                    Scale = preset.Scale
                },
                TweenInfo.new(
                    0.28,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out
                )
            )
            for _, sib in ipairs(SizeRow:GetChildren()) do
                if sib:IsA("TextButton") then
                    local st = sib:FindFirstChildOfClass("UIStroke")
                    if st then
                        Tween(st, {
                            Color = sib == b and CurrentAccent.Light or Border,
                            Thickness = sib == b and 1.5 or 1
                        })
                    end
                end
            end
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


    Label(SettingsPage, "UPDATES", 13, 25, PurpleLight).Font = Enum.Font.GothamBold

    local RefreshHubButton = Instance.new("TextButton")
    RefreshHubButton.Size = UDim2.new(1, 0, 0, 48)
    RefreshHubButton.BackgroundColor3 = ButtonDark
    RefreshHubButton.TextColor3 = White
    RefreshHubButton.TextSize = 12
    RefreshHubButton.Font = Enum.Font.GothamBold
    RefreshHubButton.Text = "↻  REFRESH ENTIRE HUB"
    RefreshHubButton.Parent = SettingsPage
    Corner(RefreshHubButton, 9)
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
        RefreshHubButton.Text = "↻  DOWNLOADING LATEST HUB..."
        RefreshHubButton.Active = false
        task.spawn(function()
            local ok, result, detail = pcall(refreshAction)
            if not ok or result == false then
                RefreshBusy = false
                RefreshHubButton.Active = true
                RefreshHubButton.Text = "REFRESH FAILED - TRY AGAIN"
                warn("ShortName Hub refresh failed: " .. tostring(ok and detail or result))
                task.wait(2)
                if RefreshHubButton.Parent then
                    RefreshHubButton.Text = "↻  REFRESH ENTIRE HUB"
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
    local function MakeFolder(name, parent)
        local Folder = Instance.new("Frame"); Folder.Name = name:gsub("%W", "") .. "Folder"; Folder.Size = UDim2.new(1, 0, 0, 38)
        Folder.BackgroundColor3 = ButtonDark; Folder.BorderSizePixel = 0; Folder.ClipsDescendants = true
        Folder.Parent = parent or GamePage; Corner(Folder, 10); Stroke(Folder, Border, 1)
        AddGradient(Folder, Color3.fromRGB(34, 32, 46), ButtonDark, 90); local HeaderButton = Instance.new("TextButton"); HeaderButton.Size =
        UDim2.new(1, 0, 0, 38)
        HeaderButton.BackgroundTransparency = 1; HeaderButton.Text = "📁  " .. name .. "     +"; HeaderButton.TextColor3 = White
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
            HeaderButton.Text = (Open and "📂  " or "📁  ")
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
        local b = Instance.new("TextButton"); b.Size = UDim2.new(1, 0, 0, 38); b.BackgroundColor3 = color or Color3.fromRGB(75, 55, 115)
        b.TextColor3 = White; b.Text = text; b.TextSize = 12
        b.Font = Enum.Font.GothamBold; b.Parent = parent; Corner(b, 8)
        Stroke(b, Border, 1); AddHover(b, color or Color3.fromRGB(75, 55, 115), Color3.fromRGB(94, 68, 137)); b.Activated:Connect(callback)
        return b
    end

    -- HALLOWEEN EVENT FOLDER
    local HalloweenFolder = MakeFolder("HALLOWEEN EVENT")

    -- THANKSGIVING EVENT FOLDER
    -- Kept separate from Halloween so event features stay organized.
    local ThanksgivingFolder = MakeFolder("THANKSGIVING EVENT")
    local ThanksgivingScannerFolder = MakeFolder("EVENT SCANNER", ThanksgivingFolder)

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
    local FightScannerFolder = MakeFolder("GAME SCANNER", FightFolder)

    Label(FightScannerFolder, "FIGHT ON A BASEPLATE SCANNER", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
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
    local FightInspectorFolder = MakeFolder("COMBAT SYSTEM INSPECTOR", FightFolder)
    Label(FightInspectorFolder, "COMBAT SYSTEM INSPECTOR", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
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

    -- PLAYER UTILITIES (SETTINGS TAB)
    local UtilityFolder = SettingsPage

    Label(UtilityFolder, "PLAYER UTILITIES", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
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

    -- SESSION TOOLS: live diagnostics and copy helpers
    Label(UtilityFolder, "SESSION TOOLS", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
    Label(UtilityFolder, "RightControl hides or restores the hub.", 10, 20, Grey)
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

    -- COMING SOON PAGE
    Label(SoonPage, "COMING SOON", 17, 30).Font = Enum.Font.GothamBold; Label(SoonPage, "More features are being worked on.", 12, 25, Grey); local
    SoonCard = Instance.new("Frame")
    SoonCard.Size = UDim2.new(1, 0, 0, 75); SoonCard.BackgroundColor3 = ButtonDark; SoonCard.BorderSizePixel = 0
    SoonCard.Parent = SoonPage; Corner(SoonCard, 10); Stroke(SoonCard, Border, 1)
    AddGradient(SoonCard, Color3.fromRGB(36, 31, 49), ButtonDark, 90); local SoonText = Label(SoonCard, "Stay tuned for future updates!", 12, 75,
    White)
    SoonText.TextXAlignment = Enum.TextXAlignment.Center

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

    -- RightControl quickly minimizes/restores the hub without stealing
    -- keyboard input while a text field is focused.
    HubToggleConnection = UIS.InputBegan:Connect(function(input, processed)
        if processed or UIS:GetFocusedTextBox() then
            return
        end
        if input.KeyCode == Enum.KeyCode.RightControl then
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
        end
    end)

    -- WINDOW DRAGGING
    local Dragging = false; local DragInput; local DragStart
    local StartPosition

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            Dragging = true
            DragStart = input.Position
            StartPosition = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        then
            DragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local delta = input.Position - DragStart
            Frame.Position = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + delta.Y
            )
        end
    end)

    -- BUBBLE DRAGGING
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
        HouseAutoEnabled = false
        HouseLoopToken = HouseLoopToken + 1
        ScreenGui:Destroy()
    end)

    SelectPage("Settings"); Tween(WindowScale, { Scale = 1 }, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
    return { SetStatus = SetStatus, ScreenGui = ScreenGui }
end

return GUI
