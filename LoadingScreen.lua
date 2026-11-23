-- ShortName Hub minimal loading screen.
local LoadingScreen = {}
local TweenService = game:GetService("TweenService")

function LoadingScreen.Start()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ShortNameLoadingScreen"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    local parented = pcall(function()
        if type(gethui) == "function" then
            ScreenGui.Parent = gethui()
        else
            ScreenGui.Parent = game:GetService("CoreGui")
        end
    end)
    if not parented or not ScreenGui.Parent then
        ScreenGui.Parent = game:GetService("CoreGui")
    end

    local Purple = Color3.fromRGB(145, 75, 255)
    local Light = Color3.fromRGB(195, 155, 255)
    local White = Color3.fromRGB(245, 242, 255)
    local Grey = Color3.fromRGB(155, 150, 170)

    local Background = Instance.new("Frame")
    Background.Size = UDim2.fromScale(1, 1)
    Background.BackgroundColor3 = Color3.fromRGB(8, 8, 13)
    Background.BackgroundTransparency = 0.18
    Background.BorderSizePixel = 0
    Background.Parent = ScreenGui

    local Card = Instance.new("Frame")
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.Position = UDim2.fromScale(0.5, 0.5)
    Card.Size = UDim2.fromOffset(330, 142)
    Card.BackgroundColor3 = Color3.fromRGB(20, 19, 28)
    Card.BorderSizePixel = 0
    Card.Parent = Background
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 14)
    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Purple
    CardStroke.Transparency = 0.42
    CardStroke.Thickness = 1.2
    CardStroke.Parent = Card

    local Spinner = Instance.new("TextLabel")
    Spinner.Size = UDim2.fromOffset(36, 36)
    Spinner.Position = UDim2.fromOffset(18, 18)
    Spinner.BackgroundTransparency = 1
    Spinner.Text = "◌"
    Spinner.TextColor3 = Light
    Spinner.TextSize = 31
    Spinner.Font = Enum.Font.Gotham
    Spinner.Parent = Card

    local Title = Instance.new("TextLabel")
    Title.Position = UDim2.fromOffset(62, 18)
    Title.Size = UDim2.new(1, -80, 0, 26)
    Title.BackgroundTransparency = 1
    Title.Text = "SHORTNAME HUB"
    Title.TextColor3 = White
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Card

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Position = UDim2.fromOffset(62, 45)
    Subtitle.Size = UDim2.new(1, -80, 0, 22)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Preparing your hub..."
    Subtitle.TextColor3 = Grey
    Subtitle.TextSize = 10
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.TextTruncate = Enum.TextTruncate.AtEnd
    Subtitle.Parent = Card

    local Track = Instance.new("Frame")
    Track.Position = UDim2.fromOffset(20, 94)
    Track.Size = UDim2.new(1, -40, 0, 5)
    Track.BackgroundColor3 = Color3.fromRGB(43, 40, 54)
    Track.BorderSizePixel = 0
    Track.Parent = Card
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.fromScale(0, 1)
    Fill.BackgroundColor3 = Purple
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Percentage = Instance.new("TextLabel")
    Percentage.Position = UDim2.fromOffset(20, 106)
    Percentage.Size = UDim2.new(1, -40, 0, 18)
    Percentage.BackgroundTransparency = 1
    Percentage.Text = "0%"
    Percentage.TextColor3 = Light
    Percentage.TextSize = 9
    Percentage.Font = Enum.Font.GothamMedium
    Percentage.TextXAlignment = Enum.TextXAlignment.Right
    Percentage.Parent = Card

    local Finished = false
    local Loading = {}

    task.spawn(function()
        while Spinner.Parent and not Finished do
            local tween = TweenService:Create(Spinner, TweenInfo.new(0.8, Enum.EasingStyle.Linear), { Rotation = Spinner.Rotation + 360 })
            tween:Play()
            tween.Completed:Wait()
        end
    end)

    function Loading.SetProgress(current, total, message)
        if Finished then return end
        total = math.max(1, tonumber(total) or 1)
        current = math.clamp(tonumber(current) or 0, 0, total)
        local fraction = current / total
        Subtitle.Text = tostring(message or "LOADING...")
        Percentage.Text = tostring(math.floor(fraction * 100 + 0.5)) .. "%"
        TweenService:Create(Fill, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromScale(fraction, 1)
        }):Play()
    end

    function Loading.Finish()
        if Finished then return end
        Loading.SetProgress(1, 1, "ShortName Hub is ready")
        Finished = true
        task.delay(0.35, function()
            if ScreenGui.Parent then ScreenGui:Destroy() end
        end)
    end

    function Loading.Fail(message)
        if Finished then return end
        Finished = true
        Subtitle.Text = "LOAD FAILED"
        Percentage.Text = tostring(message or "Please execute the loader again.")
        Percentage.TextColor3 = Color3.fromRGB(255, 135, 145)
        Fill.BackgroundColor3 = Color3.fromRGB(220, 75, 90)
        task.delay(3, function()
            if ScreenGui.Parent then ScreenGui:Destroy() end
        end)
    end

    return Loading
end

return LoadingScreen
