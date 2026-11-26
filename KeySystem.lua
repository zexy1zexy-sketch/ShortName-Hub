
-- SHORTNAME HUB KEY SYSTEM
-- EDIT THESE TWO SETTINGS

local HUB_KEY = "Key123"
local DISCORD_INVITE = "https://discord.gg/JgAsS6yYAH"

-- USERS WHO CAN SKIP KEY VERIFICATION (Roblox UserIds)
local KEY_BYPASS_USER_IDS = {
    [7867608166] = true,
}

-- KEY SYSTEM UI

local KeySystem = {}

-- Successful keys are remembered locally for 24 hours.
-- The cache is scoped to the current Roblox account on this executor/device.
local ACCESS_CACHE_SECONDS = 24 * 60 * 60
local function GetAccessCachePath()
    local player = game:GetService("Players").LocalPlayer
    local userId = player and tostring(player.UserId) or "unknown"
    return "ShortNameHub_KeyAccess_" .. userId .. ".txt"
end

local function HasCachedAccess()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then
        return false
    end
    local path = GetAccessCachePath()
    local ok, exists = pcall(isfile, path)
    if not ok or not exists then return false end

    local readOk, raw = pcall(readfile, path)
    local expiresAt = readOk and tonumber(raw) or nil
    if expiresAt and os.time() < expiresAt then
        return true
    end

    if type(delfile) == "function" then
        pcall(delfile, path)
    else
        pcall(writefile, path, "")
    end
    return false
end

local function SaveCachedAccess()
    if type(writefile) ~= "function" then return false end
    local expiresAt = os.time() + ACCESS_CACHE_SECONDS
    return pcall(writefile, GetAccessCachePath(), tostring(expiresAt))
end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function KeySystem.Start()
    local localPlayer = game:GetService("Players").LocalPlayer
    if localPlayer and KEY_BYPASS_USER_IDS[localPlayer.UserId] then
        return true
    end
    if HasCachedAccess() then
        return true
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ShortNameKeySystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local success = pcall(function()
        ScreenGui.Parent = gethui()
    end)

    if not success then
        ScreenGui.Parent = game:GetService("CoreGui")
    end

    -- MAIN GUI COLORS
    local Purple = Color3.fromRGB(42, 42, 42)
    local PurpleLight = Color3.fromRGB(215, 215, 215)
    local Dark = Color3.fromRGB(8, 8, 8)
    local Panel = Color3.fromRGB(12, 12, 12)
    local ButtonDark = Color3.fromRGB(24, 24, 24)
    local White = Color3.fromRGB(242, 242, 242)
    local Grey = Color3.fromRGB(158, 158, 158)
    local Border = Color3.fromRGB(48, 48, 48)

    local FastTween = TweenInfo.new(
        0.18,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    )

    local function Tween(object, properties, info)
        local tween = TweenService:Create(
            object,
            info or FastTween,
            properties
        )
        tween:Play()
        return tween
    end

    local function Corner(object, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, math.min(radius or 8, 3))
        corner.Parent = object
        return corner
    end

    local function Stroke(object, color, thickness)
        local stroke = Instance.new("UIStroke")
        stroke.Color = color or Border
        stroke.Thickness = thickness or 1
        stroke.Transparency = 0
        stroke.Parent = object
        return stroke
    end

    local function Gradient(object, first, second, rotation)
        object.BackgroundColor3 = first
        return nil
    end

    local function Label(parent, text, size, position, color, font)
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = size
        label.Position = position
        label.Text = text
        label.TextColor3 = color or White
        label.TextSize = 12
        label.Font = font or Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = parent
        return label
    end

    -- BACKGROUND

    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.fromScale(1, 1)
    Background.BackgroundColor3 = Color3.new(0, 0, 0)
    Background.BackgroundTransparency = 0.22
    Background.BorderSizePixel = 0
    Background.Parent = ScreenGui

    -- MAIN WINDOW

    local Window = Instance.new("Frame")
    Window.Name = "KeyWindow"
    Window.AnchorPoint = Vector2.new(0.5, 0.5)
    Window.Position = UDim2.fromScale(0.5, 0.5)
    Window.Size = UDim2.fromOffset(390, 285)
    Window.BackgroundColor3 = Dark
    Window.BorderSizePixel = 0
    Window.Parent = Background

    Corner(Window, 3)
    Stroke(Window, Border, 1)
    Window.BackgroundColor3 = Dark

    local WindowScale = Instance.new("UIScale")
    WindowScale.Scale = 0.88
    WindowScale.Parent = Window

    -- HEADER

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 76)
    Header.BackgroundColor3 = Panel
    Header.BorderSizePixel = 0
    Header.Parent = Window

    Corner(Header, 3)
    Header.BackgroundColor3 = Color3.fromRGB(9, 9, 9)

    local HeaderCover = Instance.new("Frame")
    HeaderCover.Size = UDim2.new(1, 0, 0, 12)
    HeaderCover.Position = UDim2.new(0, 0, 1, -12)
    HeaderCover.BackgroundColor3 = Dark
    HeaderCover.BorderSizePixel = 0
    HeaderCover.Parent = Header

    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, -2, 0, 1)
    AccentLine.Position = UDim2.new(0, 1, 1, -2)
    AccentLine.BackgroundColor3 = Purple
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = Header

    AccentLine.BackgroundColor3 = Border

    local Title = Label(
        Header,
        "SHORTNAME HUB",
        UDim2.new(1, -40, 0, 27),
        UDim2.fromOffset(20, 13),
        White,
        Enum.Font.GothamBold
    )
    Title.TextSize = 19

    local Subtitle = Label(
        Header,
        "SECURE ACCESS  /  KEY VERIFICATION",
        UDim2.new(1, -40, 0, 18),
        UDim2.fromOffset(21, 43),
        Grey,
        Enum.Font.GothamMedium
    )
    Subtitle.TextSize = 9

    -- CONTENT

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.fromOffset(20, 88)
    Content.Size = UDim2.new(1, -40, 1, -100)
    Content.Parent = Window

    local Description = Label(
        Content,
        "Enter your access key to unlock the hub.",
        UDim2.new(1, 0, 0, 20),
        UDim2.fromOffset(0, 0),
        Grey,
        Enum.Font.Gotham
    )
    Description.TextSize = 11

    -- KEY INPUT

    local InputContainer = Instance.new("Frame")
    InputContainer.Name = "InputContainer"
    InputContainer.Position = UDim2.fromOffset(0, 32)
    InputContainer.Size = UDim2.new(1, 0, 0, 42)
    InputContainer.BackgroundColor3 = ButtonDark
    InputContainer.BorderSizePixel = 0
    InputContainer.Parent = Content

    Corner(InputContainer, 3)
    local InputStroke = Stroke(InputContainer, Border, 1)

    local KeyBox = Instance.new("TextBox")
    KeyBox.Name = "KeyInput"
    KeyBox.BackgroundTransparency = 1
    KeyBox.Position = UDim2.fromOffset(12, 0)
    KeyBox.Size = UDim2.new(1, -24, 1, 0)
    KeyBox.Text = ""
    KeyBox.PlaceholderText = "Enter your key here..."
    KeyBox.PlaceholderColor3 = Grey
    KeyBox.TextColor3 = White
    KeyBox.TextSize = 12
    KeyBox.Font = Enum.Font.Gotham
    KeyBox.ClearTextOnFocus = false
    KeyBox.TextXAlignment = Enum.TextXAlignment.Left
    KeyBox.Parent = InputContainer

    KeyBox.Focused:Connect(function()
        Tween(InputStroke, {
            Color = PurpleLight,
            Thickness = 1.5
        })
    end)

    KeyBox.FocusLost:Connect(function()
        Tween(InputStroke, {
            Color = Border,
            Thickness = 1
        })
    end)

    -- STATUS

    local StatusDot = Instance.new("Frame")
    StatusDot.Size = UDim2.fromOffset(7, 7)
    StatusDot.Position = UDim2.fromOffset(2, 88)
    StatusDot.BackgroundColor3 = Grey
    StatusDot.BorderSizePixel = 0
    StatusDot.Parent = Content
    Corner(StatusDot, 10)

    local Status = Label(
        Content,
        "WAITING FOR KEY",
        UDim2.new(1, -20, 0, 18),
        UDim2.fromOffset(16, 82),
        Grey,
        Enum.Font.GothamBold
    )
    Status.TextSize = 9

    local function SetStatus(message, color)
        Status.Text = message
        Status.TextColor3 = color
        Tween(StatusDot, {
            BackgroundColor3 = color
        })
    end

    -- BUTTON CREATION

    local function MakeButton(name, text, position, color, lightColor)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(1, 0, 0, 36)
        button.Position = position
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = White
        button.TextSize = 11
        button.Font = Enum.Font.GothamBold
        button.AutoButtonColor = false
        button.Parent = Content

        Corner(button, 3)
        local outline = Stroke(button, lightColor or Border, 1)
        Gradient(button, color, color:Lerp(Color3.new(0, 0, 0), 0.15), 90)

        button.MouseEnter:Connect(function()
            Tween(button, {
                BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.08)
            })
            Tween(outline, {
                Color = lightColor or PurpleLight
            })
        end)

        button.MouseLeave:Connect(function()
            Tween(button, {
                BackgroundColor3 = color
            })
            Tween(outline, {
                Color = lightColor or Border
            })
        end)

        button.MouseButton1Down:Connect(function()
            Tween(button, {
                Size = UDim2.new(1, -3, 0, 34)
            })
        end)

        button.MouseButton1Up:Connect(function()
            Tween(button, {
                Size = UDim2.new(1, 0, 0, 36)
            })
        end)

        return button
    end

    local VerifyButton = MakeButton(
        "VerifyButton",
        "UNLOCK HUB",
        UDim2.fromOffset(0, 112),
        Purple,
        PurpleLight
    )

    local DiscordButton = MakeButton(
        "DiscordButton",
        "JOIN DISCORD",
        UDim2.fromOffset(0, 156),
        ButtonDark,
        Border
    )

    -- FOOTER

    local Footer = Label(
        Content,
        "SHORTNAME HUB  •  ACCESS GATE",
        UDim2.new(1, 0, 0, 15),
        UDim2.fromOffset(0, 203),
        Color3.fromRGB(105, 100, 120),
        Enum.Font.GothamMedium
    )
    Footer.TextSize = 8
    Footer.TextXAlignment = Enum.TextXAlignment.Center

    -- VERIFICATION

    local Finished = false
    local AccessGranted = false

    local function VerifyKey()
        if Finished then
            return
        end

        if KeyBox.Text == HUB_KEY then
            SetStatus(
                "KEY ACCEPTED - ACCESS GRANTED",
                Color3.fromRGB(220, 220, 220)
            )

            VerifyButton.Text = "ACCESS GRANTED"
            Tween(VerifyButton, {
                BackgroundColor3 = Color3.fromRGB(48, 48, 48)
            })

            AccessGranted = true
            SaveCachedAccess()
            Finished = true
        else
            SetStatus(
                "INVALID KEY - TRY AGAIN",
                Color3.fromRGB(185, 185, 185)
            )

            local originalPosition = Window.Position

            Tween(Window, {
                Position = originalPosition + UDim2.fromOffset(-5, 0)
            }, TweenInfo.new(0.06))

            task.delay(0.07, function()
                if Window.Parent then
                    Tween(Window, {
                        Position = originalPosition + UDim2.fromOffset(5, 0)
                    }, TweenInfo.new(0.06))
                end
            end)

            task.delay(0.14, function()
                if Window.Parent then
                    Tween(Window, {
                        Position = originalPosition
                    }, TweenInfo.new(0.08))
                end
            end)
        end
    end

    VerifyButton.Activated:Connect(VerifyKey)

    KeyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            VerifyKey()
        end
    end)

    -- DISCORD

    DiscordButton.Activated:Connect(function()
        local copied = pcall(function()
            setclipboard(DISCORD_INVITE)
        end)

        if copied then
            SetStatus(
                "DISCORD INVITE COPIED",
                Color3.fromRGB(205, 205, 205)
            )
        else
            SetStatus(
                "COPY FAILED - CHECK YOUR INVITE",
                Color3.fromRGB(255, 100, 100)
            )
        end
    end)

    -- OPEN ANIMATION

    Tween(
        WindowScale,
        {Scale = 1},
        TweenInfo.new(
            0.4,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        )
    )

    -- Apply the flat monochrome text style while ScreenGui is still in scope.
    for _, descendant in ipairs(ScreenGui:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
            descendant.TextStrokeTransparency = 1
        end
    end

    -- WAIT FOR ACCESS

    while not Finished and ScreenGui.Parent do
        task.wait()
    end

    if AccessGranted then
        Tween(
            WindowScale,
            {Scale = 0.92},
            TweenInfo.new(0.18, Enum.EasingStyle.Quad)
        )
        task.wait(0.18)
    end

    ScreenGui:Destroy()

    return AccessGranted
end

return KeySystem
