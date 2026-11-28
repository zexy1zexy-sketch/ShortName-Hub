--[[
    ShortName FE Admin - Standalone Client Utility Edition
    Branch: fe-admin-standalone
    This script provides LOCAL client-side utilities only.
    It does not grant server permissions or replicate privileged actions.
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    Name = "ShortName FE Admin",
    Accent = Color3.fromRGB(145, 91, 255),
    Background = Color3.fromRGB(17, 19, 27),
    Panel = Color3.fromRGB(27, 30, 42),
    Text = Color3.fromRGB(240, 240, 248),
    Muted = Color3.fromRGB(153, 158, 177),
    Prefix = ";",
}

local old = game:GetService("CoreGui"):FindFirstChild("ShortNameFEAdmin")
if old then old:Destroy() end

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    return getCharacter():FindFirstChildOfClass("Humanoid")
end

local function getRoot(player)
    local character = (player or LocalPlayer).Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function notify(message)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = CONFIG.Name, Text = tostring(message), Duration = 3
        })
    end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "ShortNameFEAdmin"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(520, 350)
frame.Position = UDim2.new(0.5, -260, 0.5, -175)
frame.BackgroundColor3 = CONFIG.Background
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = CONFIG.Accent
stroke.Transparency = 0.35
stroke.Thickness = 1
stroke.Parent = frame

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 42)
top.BackgroundColor3 = CONFIG.Panel
top.BorderSizePixel = 0
top.Parent = frame
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(14, 0)
title.Size = UDim2.new(1, -100, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "✦ SHORTNAME  /  FE ADMIN"
title.TextColor3 = CONFIG.Text
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(34, 28)
close.Position = UDim2.new(1, -42, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(190, 65, 78)
close.Text = "×"
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 20
close.Parent = top
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local log = Instance.new("ScrollingFrame")
log.Position = UDim2.fromOffset(12, 54)
log.Size = UDim2.new(1, -24, 1, -112)
log.BackgroundColor3 = CONFIG.Panel
log.BorderSizePixel = 0
log.ScrollBarThickness = 4
log.CanvasSize = UDim2.new()
log.Parent = frame
Instance.new("UICorner", log).CornerRadius = UDim.new(0, 8)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = log

local function addLine(text, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -16, 0, 22)
    label.Position = UDim2.fromOffset(8, 0)
    label.Font = Enum.Font.Code
    label.Text = tostring(text)
    label.TextColor3 = color or CONFIG.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = log
    task.defer(function()
        log.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
        log.CanvasPosition = Vector2.new(0, math.max(0, log.CanvasSize.Y.Offset))
    end)
end

local input = Instance.new("TextBox")
input.Position = UDim2.new(0, 12, 1, -48)
input.Size = UDim2.new(1, -24, 0, 36)
input.BackgroundColor3 = CONFIG.Panel
input.BorderSizePixel = 0
input.PlaceholderText = "Enter command...  (try ;help)"
input.Text = ""
input.ClearTextOnFocus = false
input.Font = Enum.Font.Code
input.TextSize = 14
input.TextColor3 = CONFIG.Text
input.PlaceholderColor3 = CONFIG.Muted
input.Parent = frame
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)

local dragging, dragStart, startPos
top.InputBegan:Connect(function(obj)
    if obj.UserInputType == Enum.UserInputType.MouseButton1 or obj.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = obj.Position
        startPos = frame.Position
        obj.Changed:Connect(function()
            if obj.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(obj)
    if dragging and (obj.UserInputType == Enum.UserInputType.MouseMovement or obj.UserInputType == Enum.UserInputType.Touch) then
        local delta = obj.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local commands = {}
local function register(names, description, callback)
    for name in string.gmatch(names, "[^|]+") do
        commands[string.lower(name)] = {description = description, run = callback}
    end
end

local function numberArg(args, index, default)
    return tonumber(args[index]) or default
end

local function findPlayer(query)
    if not query then return nil end
    query = string.lower(query)
    if query == "me" then return LocalPlayer end
    for _, player in ipairs(Players:GetPlayers()) do
        if string.lower(player.Name) == query or string.lower(player.DisplayName) == query then return player end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if string.sub(string.lower(player.Name), 1, #query) == query then return player end
    end
end

register("help|commands", "List available commands", function()
    local seen = {}
    for name, data in pairs(commands) do
        if not seen[data] then
            seen[data] = true
            addLine(CONFIG.Prefix .. name .. "  -  " .. data.description, CONFIG.Muted)
        end
    end
end)

register("clear|cls", "Clear the terminal", function()
    for _, child in ipairs(log:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    addLine("Terminal cleared.")
end)

register("ws|walkspeed", "Set your local WalkSpeed: ws 32", function(a)
    local h = getHumanoid(); if h then h.WalkSpeed = math.clamp(numberArg(a,1,16), 0, 250); addLine("Local WalkSpeed updated.") end
end)

register("jp|jumppower", "Set local JumpPower: jp 70", function(a)
    local h = getHumanoid(); if h then h.UseJumpPower = true; h.JumpPower = math.clamp(numberArg(a,1,50), 0, 250); addLine("Local JumpPower updated.") end
end)

register("hip|hipheight", "Set local HipHeight: hip 5", function(a)
    local h = getHumanoid(); if h then h.HipHeight = math.clamp(numberArg(a,1,0), -10, 50); addLine("Local HipHeight updated.") end
end)

register("sit", "Sit your character", function() local h=getHumanoid(); if h then h.Sit=true end end)
register("stand|unsit", "Stand up", function() local h=getHumanoid(); if h then h.Sit=false end end)
register("reset", "Reset your local character", function() local h=getHumanoid(); if h then h.Health=0 end end)

register("fov", "Set camera field of view: fov 90", function(a)
    Workspace.CurrentCamera.FieldOfView = math.clamp(numberArg(a,1,70), 1, 120)
    addLine("Camera FOV updated.")
end)

register("time", "Set local time: time 14", function(a)
    Lighting.ClockTime = math.clamp(numberArg(a,1,14), 0, 24)
    addLine("Local lighting time updated.")
end)

register("brightness", "Set local brightness: brightness 3", function(a)
    Lighting.Brightness = math.clamp(numberArg(a,1,2), 0, 10)
end)

register("fullbright", "Enable local fullbright", function()
    Lighting.Brightness = 3
    Lighting.ClockTime = 14
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    addLine("Local fullbright enabled.")
end)

register("fog", "Set local fog end distance: fog 500", function(a)
    Lighting.FogEnd = math.clamp(numberArg(a,1,100000), 0, 100000)
end)

register("goto|tp", "Move your character beside a player: tp username", function(a)
    local target = findPlayer(a[1]); local mine=getRoot(); local theirs=getRoot(target)
    if not target or not theirs or not mine then addLine("Player or character not found.", Color3.fromRGB(255,100,100)); return end
    mine.CFrame = theirs.CFrame * CFrame.new(3,0,0)
    addLine("Moved locally beside " .. target.Name .. ".")
end)

register("view", "View a player's character: view username", function(a)
    local target=findPlayer(a[1]); local h=target and target.Character and target.Character:FindFirstChildOfClass("Humanoid")
    if h then Workspace.CurrentCamera.CameraSubject=h; addLine("Camera target: "..target.Name) else addLine("Player not found.") end
end)

register("unview|viewself", "Return camera to your character", function()
    local h=getHumanoid(); if h then Workspace.CurrentCamera.CameraSubject=h end
end)

register("coords|position|pos", "Show your current coordinates", function()
    local root=getRoot()
    if root then local p=root.Position; addLine(string.format("X %.1f  Y %.1f  Z %.1f",p.X,p.Y,p.Z)) end
end)

register("players", "List players in this server", function()
    for _, p in ipairs(Players:GetPlayers()) do addLine(p.Name .. "  (" .. p.DisplayName .. ")") end
end)

register("count", "Show player count", function()
    addLine(tostring(#Players:GetPlayers()) .. " players in server.")
end)

register("hideui|minimize", "Hide the admin window", function() frame.Visible=false end)
register("showui|restore", "Show the admin window", function() frame.Visible=true end)

register("rejoin", "Reconnect to this server", function()
    local TeleportService=game:GetService("TeleportService")
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

register("serverhop", "Find another public server (not implemented in this local build)", function()
    addLine("Server hopping requires a separate supported server-browser module.", Color3.fromRGB(255,190,90))
end)

local function execute(raw)
    raw = tostring(raw or "")
    if raw == "" then return end
    addLine("> " .. raw, CONFIG.Accent)
    local parts = {}
    for token in string.gmatch(raw, "%S+") do table.insert(parts, token) end
    local name = string.lower((parts[1] or ""):gsub("^"..CONFIG.Prefix, ""))
    table.remove(parts, 1)
    local entry = commands[name]
    if not entry then addLine("Unknown command. Type ;help.", Color3.fromRGB(255,110,110)); return end
    local ok, err = pcall(entry.run, parts)
    if not ok then addLine("Error: " .. tostring(err), Color3.fromRGB(255,110,110)) end
end

input.FocusLost:Connect(function(enter)
    if enter then local value=input.Text; input.Text=""; execute(value) end
end)

addLine("ShortName FE Admin loaded.")
addLine("Standalone branch build - client-side utilities only.", CONFIG.Muted)
addLine("Type ;help to view commands.", CONFIG.Muted)
notify("Standalone client utility loaded.")
