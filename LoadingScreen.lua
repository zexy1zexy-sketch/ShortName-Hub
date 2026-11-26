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

    local Purple = Color3.fromRGB(48, 48, 48)
    local Light = Color3.fromRGB(220, 220, 220)
    local White = Color3.fromRGB(242, 242, 242)
    local Grey = Color3.fromRGB(158, 158, 158)

    local Background = Instance.new("Frame")
    Background.Size = UDim2.fromScale(1, 1)
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BackgroundTransparency = 0.22
    Background.BorderSizePixel = 0
    Background.Parent = ScreenGui

    local Card = Instance.new("Frame")
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.Position = UDim2.fromScale(0.5, 0.5)
    Card.Size = UDim2.fromOffset(360, 142)
    Card.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Card.BorderSizePixel = 0
    Card.Parent = Background
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 3)
    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Color3.fromRGB(48, 48, 48)
    CardStroke.Transparency = 0
    CardStroke.Thickness = 1
    CardStroke.Parent = Card

    local Title = Instance.new("TextLabel")
    Title.Position = UDim2.fromOffset(20, 18)
    Title.Size = UDim2.new(1, -40, 0, 26)
    Title.BackgroundTransparency = 1
    Title.Text = "SHORTNAME HUB"
    Title.TextColor3 = White
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Card

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Position = UDim2.fromOffset(20, 45)
    Subtitle.Size = UDim2.new(1, -40, 0, 22)
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
    Track.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    Track.BorderSizePixel = 0
    Track.Parent = Card
    Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 2)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.fromScale(0, 1)
    Fill.BackgroundColor3 = Purple
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 2)

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
        Percentage.TextColor3 = Color3.fromRGB(190, 190, 190)
        Fill.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        task.delay(3, function()
            if ScreenGui.Parent then ScreenGui:Destroy() end
        end)
    end

    return Loading
end

return LoadingScreen
