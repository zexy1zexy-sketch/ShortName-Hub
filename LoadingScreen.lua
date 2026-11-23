-- SHORTNAME HUB - ANIMATED LOADING SCREEN

local LoadingScreen = {}

local TweenService = game:GetService("TweenService")

function LoadingScreen.Start()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ShortNameLoadingScreen"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = gethui and gethui() or game:GetService("CoreGui")

    local Purple = Color3.fromRGB(145, 75, 255)
    local PurpleLight = Color3.fromRGB(195, 145, 255)
    local Dark = Color3.fromRGB(9, 8, 15)
    local White = Color3.fromRGB(245, 240, 255)
    local Grey = Color3.fromRGB(155, 145, 175)

    local function Tween(Object, Properties, Duration, Style)
        local Animation = TweenService:Create(
            Object,
            TweenInfo.new(
                Duration,
                Style or Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            Properties
        )

        Animation:Play()
        return Animation
    end

    -- BACKGROUND

    local Background = Instance.new("Frame")
    Background.Size = UDim2.fromScale(1, 1)
    Background.BackgroundColor3 = Dark
    Background.BorderSizePixel = 0
    Background.Parent = ScreenGui

    -- SUBTLE BACKGROUND GLOW

    local Glow = Instance.new("Frame")
    Glow.AnchorPoint = Vector2.new(0.5, 0.5)
    Glow.Position = UDim2.fromScale(0.5, 0.43)
    Glow.Size = UDim2.fromOffset(370, 370)
    Glow.BackgroundColor3 = Purple
    Glow.BackgroundTransparency = 0.91
    Glow.BorderSizePixel = 0
    Glow.Parent = Background

    local GlowCorner = Instance.new("UICorner")
    GlowCorner.CornerRadius = UDim.new(1, 0)
    GlowCorner.Parent = Glow

    local GlowGradient = Instance.new("UIGradient")
    GlowGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
    GlowGradient.Parent = Glow

    -- LOGO

    local Logo = Instance.new("ImageLabel")
    Logo.Name = "LoadingLogo"
    Logo.AnchorPoint = Vector2.new(0.5, 0.5)
    Logo.Position = UDim2.fromScale(0.5, 0.39)
    Logo.Size = UDim2.fromOffset(155, 155)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://84886464670561"
    Logo.ScaleType = Enum.ScaleType.Fit
    Logo.Parent = Background

    local LogoScale = Instance.new("UIScale")
    LogoScale.Scale = 0.7
    LogoScale.Parent = Logo

    local LogoStroke = Instance.new("UIStroke")
    LogoStroke.Color = PurpleLight
    LogoStroke.Thickness = 2
    LogoStroke.Transparency = 0.35
    LogoStroke.Parent = Logo

    -- FLOATING PARTICLES

    local Particles = {}

    for i = 1, 12 do
        local Particle = Instance.new("TextLabel")
        Particle.BackgroundTransparency = 1
        Particle.Text = "✦"
        Particle.TextColor3 = PurpleLight
        Particle.TextSize = math.random(9, 17)
        Particle.Font = Enum.Font.GothamBold
        Particle.Size = UDim2.fromOffset(25, 25)
        Particle.Position = UDim2.fromScale(
            math.random(20, 80) / 100,
            math.random(20, 65) / 100
        )
        Particle.TextTransparency = 0.2
        Particle.Parent = Background

        table.insert(Particles, Particle)

        task.spawn(function()
            while Particle.Parent do
                local NewPosition = Particle.Position + UDim2.fromOffset(
                    math.random(-20, 20),
                    math.random(-35, -15)
                )

                Tween(Particle, {
                    Position = NewPosition,
                    TextTransparency = 0.85
                }, math.random(12, 22) / 10)

                task.wait(math.random(12, 22) / 10)

                if Particle.Parent then
                    Particle.Position = UDim2.fromScale(
                        math.random(20, 80) / 100,
                        math.random(30, 70) / 100
                    )
                    Particle.TextTransparency = 0.15
                end
            end
        end)
    end

    -- TITLE

    local Title = Instance.new("TextLabel")
    Title.AnchorPoint = Vector2.new(0.5, 0.5)
    Title.Position = UDim2.fromScale(0.5, 0.61)
    Title.Size = UDim2.fromOffset(350, 35)
    Title.BackgroundTransparency = 1
    Title.Text = "SHORTNAME HUB"
    Title.TextColor3 = White
    Title.TextSize = 23
    Title.Font = Enum.Font.GothamBlack
    Title.Parent = Background

    -- SUBTITLE

    local Subtitle = Instance.new("TextLabel")
    Subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    Subtitle.Position = UDim2.fromScale(0.5, 0.66)
    Subtitle.Size = UDim2.fromOffset(350, 22)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "GETTING EVERYTHING READY..."
    Subtitle.TextColor3 = Grey
    Subtitle.TextSize = 10
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.Parent = Background

    -- LOADING BAR BACKGROUND

    local BarBackground = Instance.new("Frame")
    BarBackground.AnchorPoint = Vector2.new(0.5, 0.5)
    BarBackground.Position = UDim2.fromScale(0.5, 0.75)
    BarBackground.Size = UDim2.fromOffset(260, 7)
    BarBackground.BackgroundColor3 = Color3.fromRGB(35, 29, 47)
    BarBackground.BorderSizePixel = 0
    BarBackground.ClipsDescendants = true
    BarBackground.Parent = Background

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = BarBackground

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.fromScale(0, 1)
    Bar.BackgroundColor3 = Purple
    Bar.BorderSizePixel = 0
    Bar.Parent = BarBackground

    local BarGradient = Instance.new("UIGradient")
    BarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Purple),
        ColorSequenceKeypoint.new(1, PurpleLight)
    })
    BarGradient.Parent = Bar

    local BarFillCorner = Instance.new("UICorner")
    BarFillCorner.CornerRadius = UDim.new(1, 0)
    BarFillCorner.Parent = Bar

    -- PERCENTAGE

    local Percentage = Instance.new("TextLabel")
    Percentage.AnchorPoint = Vector2.new(0.5, 0.5)
    Percentage.Position = UDim2.fromScale(0.5, 0.79)
    Percentage.Size = UDim2.fromOffset(100, 20)
    Percentage.BackgroundTransparency = 1
    Percentage.Text = "0%"
    Percentage.TextColor3 = PurpleLight
    Percentage.TextSize = 11
    Percentage.Font = Enum.Font.GothamBold
    Percentage.Parent = Background

    -- ANIMATIONS

    Tween(LogoScale, {
        Scale = 1
    }, 0.8, Enum.EasingStyle.Back)

    task.spawn(function()
        while Logo.Parent do
            Tween(Logo, {
                Rotation = 8
            }, 1.4, Enum.EasingStyle.Sine)

            task.wait(1.4)

            if not Logo.Parent then
                break
            end

            Tween(Logo, {
                Rotation = -8
            }, 1.4, Enum.EasingStyle.Sine)

            task.wait(1.4)
        end
    end)

    task.spawn(function()
        while Logo.Parent do
            Tween(LogoScale, {
                Scale = 1.07
            }, 1.1, Enum.EasingStyle.Sine)

            Tween(Glow, {
                BackgroundTransparency = 0.85
            }, 1.1)

            task.wait(1.1)

            if not Logo.Parent then
                break
            end

            Tween(LogoScale, {
                Scale = 1
            }, 1.1, Enum.EasingStyle.Sine)

            Tween(Glow, {
                BackgroundTransparency = 0.93
            }, 1.1)

            task.wait(1.1)
        end
    end)

    -- Progress is driven by completed loader operations, not elapsed time.
    local Loading = {}
    local Finished = false

    function Loading.SetProgress(current, total, message)
        if Finished then
            return
        end
        total = math.max(1, tonumber(total) or 1)
        current = math.clamp(tonumber(current) or 0, 0, total)
        local fraction = current / total
        Subtitle.Text = tostring(message or "LOADING...")
        Percentage.Text = tostring(math.floor(fraction * 100 + 0.5)) .. "%"
        Tween(Bar, {
            Size = UDim2.fromScale(fraction, 1)
        }, 0.22, Enum.EasingStyle.Quad)
    end

    function Loading.Finish()
        if Finished then
            return
        end
        Loading.SetProgress(1, 1, "SHORTNAME HUB READY")
        Finished = true
        task.spawn(function()
            task.wait(0.3)
            Tween(LogoScale, {Scale = 0.75}, 0.25)
            Tween(Background, {BackgroundTransparency = 1}, 0.35)
            Tween(Logo, {ImageTransparency = 1}, 0.25)
            task.wait(0.4)
            if ScreenGui.Parent then
                ScreenGui:Destroy()
            end
        end)
    end

    function Loading.Fail(message)
        if Finished then
            return
        end
        Finished = true
        Subtitle.Text = "LOAD FAILED"
        Percentage.Text = tostring(message or "Please re-execute the loader.")
        Percentage.TextSize = 9
        Percentage.TextWrapped = true
        Bar.BackgroundColor3 = Color3.fromRGB(220, 75, 90)
        task.spawn(function()
            task.wait(2.5)
            if ScreenGui.Parent then
                ScreenGui:Destroy()
            end
        end)
    end

    return Loading
end

return LoadingScreen
