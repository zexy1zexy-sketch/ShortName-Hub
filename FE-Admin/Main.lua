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


-- Extended local utility commands
local savedFov = Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70
local savedLighting = {
    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient
}
local history = {}
local historyIndex = 1
local noclipOn, flyOn = false, false
local flySpeed = 55
local noclipStep, flyStep, flyForce

local function setHumanoid(key, value)
    local h = getHumanoid()
    if not h then addLine("Character unavailable."); return end
    h[key] = value
    addLine(key .. " updated locally.")
end

local function playerDetails(p)
    if not p then addLine("Player not found."); return end
    addLine("Username: " .. p.Name)
    addLine("Display name: " .. p.DisplayName)
    addLine("UserId: " .. tostring(p.UserId))
    addLine("Account age: " .. tostring(p.AccountAge) .. " days")
    addLine("Team: " .. (p.Team and p.Team.Name or "None"))
    local c = p.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if h then addLine(string.format("Health: %.0f / %.0f", h.Health, h.MaxHealth)); addLine("State: " .. h:GetState().Name) end
    if r then
        local mine = getRoot()
        addLine(string.format("Position: %.1f, %.1f, %.1f", r.Position.X, r.Position.Y, r.Position.Z))
        if mine then addLine(string.format("Distance: %.1f studs", (r.Position-mine.Position).Magnitude)) end
    end
end

register("playerinfo|info|whois", "Show player account and character information", function(a)
    playerDetails(findPlayer(a[1]))
end)
register("find", "Find players by username or display-name text", function(a)
    local q = string.lower(a[1] or "")
    if q == "" then addLine("Usage: ;find <text>"); return end
    for _,p in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name),q,1,true) or string.find(string.lower(p.DisplayName),q,1,true) then
            addLine(p.Name .. " (" .. p.DisplayName .. ")")
        end
    end
end)
register("distance", "Measure distance to a player", function(a)
    local p=findPlayer(a[1]); local x=getRoot(); local y=getRoot(p)
    if x and y then addLine(string.format("%s: %.1f studs",p.Name,(x.Position-y.Position).Magnitude)) else addLine("Player or character unavailable.") end
end)
register("health", "Show your current health", function()
    local h=getHumanoid(); if h then addLine(string.format("%.1f / %.1f",h.Health,h.MaxHealth)) end
end)
register("speedinfo", "Show local movement properties", function()
    local h=getHumanoid(); if h then
        addLine("WalkSpeed: "..h.WalkSpeed); addLine("JumpPower: "..h.JumpPower)
        addLine("HipHeight: "..h.HipHeight); addLine("UseJumpPower: "..tostring(h.UseJumpPower))
    end
end)
register("wsreset", "Reset local WalkSpeed to 16", function() setHumanoid("WalkSpeed",16) end)
register("jpreset", "Reset local JumpPower to 50", function()
    local h=getHumanoid(); if h then h.UseJumpPower=true; h.JumpPower=50; addLine("JumpPower reset.") end
end)
register("hipreset", "Reset local HipHeight to zero", function() setHumanoid("HipHeight",0) end)
register("jump", "Make your character jump", function() local h=getHumanoid(); if h then h.Jump=true end end)
register("platformstand", "Toggle local PlatformStand", function()
    local h=getHumanoid(); if h then h.PlatformStand=not h.PlatformStand; addLine("PlatformStand: "..tostring(h.PlatformStand)) end
end)
register("autorotate", "Toggle local AutoRotate", function()
    local h=getHumanoid(); if h then h.AutoRotate=not h.AutoRotate; addLine("AutoRotate: "..tostring(h.AutoRotate)) end
end)
register("freeze|anchor", "Anchor your local root part", function()
    local r=getRoot(); if r then r.Anchored=true; addLine("Local root anchored.") end
end)
register("unfreeze|unanchor", "Unanchor your local root part", function()
    local r=getRoot(); if r then r.Anchored=false; addLine("Local root unanchored.") end
end)
register("gravity", "Set local workspace gravity property", function(a)
    Workspace.Gravity=math.clamp(numberArg(a,1,196.2),0,500); addLine("Local gravity property updated.")
end)
register("gravityreset", "Reset gravity property to 196.2", function() Workspace.Gravity=196.2 end)
register("gravityinfo", "Display current gravity property", function() addLine("Gravity: "..Workspace.Gravity) end)
register("day", "Set local lighting to daytime", function() Lighting.ClockTime=14 end)
register("night", "Set local lighting to midnight", function() Lighting.ClockTime=0 end)
register("dawn", "Set local lighting to dawn", function() Lighting.ClockTime=6 end)
register("dusk", "Set local lighting to dusk", function() Lighting.ClockTime=18 end)
register("fogoff", "Remove local fog visually", function() Lighting.FogEnd=1000000 end)
register("fogreset", "Restore saved fog distance", function() Lighting.FogEnd=savedLighting.FogEnd end)
register("shadows", "Toggle local global shadows", function()
    Lighting.GlobalShadows=not Lighting.GlobalShadows; addLine("GlobalShadows: "..tostring(Lighting.GlobalShadows))
end)
register("ambient", "Set local ambient RGB values", function(a)
    Lighting.Ambient=Color3.fromRGB(math.clamp(numberArg(a,1,100),0,255),math.clamp(numberArg(a,2,100),0,255),math.clamp(numberArg(a,3,100),0,255))
end)
register("outdoorambient", "Set local outdoor ambient RGB values", function(a)
    Lighting.OutdoorAmbient=Color3.fromRGB(math.clamp(numberArg(a,1,100),0,255),math.clamp(numberArg(a,2,100),0,255),math.clamp(numberArg(a,3,100),0,255))
end)
register("fovreset", "Restore saved camera field of view", function()
    if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView=savedFov end
end)
register("zoom", "Set camera maximum zoom distance", function(a)
    LocalPlayer.CameraMaxZoomDistance=math.clamp(numberArg(a,1,128),1,1000)
end)
register("zoommin", "Set camera minimum zoom distance", function(a)
    LocalPlayer.CameraMinZoomDistance=math.clamp(numberArg(a,1,0.5),0.5,100)
end)
register("zoomreset", "Restore default zoom distances", function()
    LocalPlayer.CameraMinZoomDistance=0.5; LocalPlayer.CameraMaxZoomDistance=128
end)
register("firstperson", "Lock camera to first person", function() LocalPlayer.CameraMode=Enum.CameraMode.LockFirstPerson end)
register("thirdperson", "Return camera to classic mode", function() LocalPlayer.CameraMode=Enum.CameraMode.Classic end)
register("mouseunlock", "Release mouse lock", function() UserInputService.MouseBehavior=Enum.MouseBehavior.Default end)
register("mouselock", "Lock mouse to center", function() UserInputService.MouseBehavior=Enum.MouseBehavior.LockCenter end)
register("team", "Show your current team", function() addLine("Team: "..(LocalPlayer.Team and LocalPlayer.Team.Name or "None")) end)
register("account", "Show your account information", function()
    addLine("Username: "..LocalPlayer.Name); addLine("Display: "..LocalPlayer.DisplayName)
    addLine("UserId: "..LocalPlayer.UserId); addLine("Account age: "..LocalPlayer.AccountAge.." days")
end)
register("place", "Show current PlaceId and JobId", function()
    addLine("PlaceId: "..game.PlaceId); addLine("JobId: "..game.JobId)
end)
register("uptime", "Show local session duration", function()
    addLine(string.format("Session: %.1f minutes",Workspace.DistributedGameTime/60))
end)
register("ping", "Show client network ping estimate", function()
    local ok,v=pcall(function() return LocalPlayer:GetNetworkPing() end)
    addLine(ok and string.format("Ping: %.0f ms",v*1000) or "Ping unavailable.")
end)
register("resetlighting", "Restore saved local lighting properties", function()
    for k,v in pairs(savedLighting) do pcall(function() Lighting[k]=v end) end
    addLine("Lighting restored.")
end)
register("resetall", "Reset local movement, camera, lighting and physics settings", function()
    local h=getHumanoid()
    if h then h.WalkSpeed=16; h.UseJumpPower=true; h.JumpPower=50; h.HipHeight=0; h.PlatformStand=false; h.AutoRotate=true end
    if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView=savedFov end
    for k,v in pairs(savedLighting) do pcall(function() Lighting[k]=v end) end
    Workspace.Gravity=196.2
    if noclipStep then noclipStep:Disconnect(); noclipStep=nil end
    noclipOn=false
    if flyStep then flyStep:Disconnect(); flyStep=nil end
    if flyForce then flyForce:Destroy(); flyForce=nil end
    flyOn=false
    addLine("Local settings restored.")
end)
register("notify", "Show a local notification", function(a) notify(table.concat(a," ")) end)
register("saylocal|echo", "Print text in the local terminal", function(a) addLine(table.concat(a," ")) end)
register("commandcount", "Show number of registered command names", function()
    local n=0; for _ in pairs(commands) do n+=1 end; addLine(n.." command names registered.")
end)
register("history", "Show recent command history", function()
    for i=math.max(1,#history-19),#history do addLine(i..": "..history[i],CONFIG.Muted) end
end)
register("prefix", "Display command prefix", function() addLine("Prefix: "..CONFIG.Prefix) end)
register("about", "Show standalone build information", function()
    addLine("ShortName FE Admin - standalone client utility")
    addLine("Branch: fe-admin-standalone")
    addLine("Server authority is not available to executor-only scripts.")
end)
register("close|quit", "Close the admin interface", function() gui:Destroy() end)
register("showui|restore", "Show the admin interface", function() frame.Visible=true end)
register("hideui|minimize", "Hide the admin interface", function() frame.Visible=false end)

local function execute(raw)
    raw = tostring(raw or "")
    if raw == "" then return end
    table.insert(history, raw)
    if #history > 100 then table.remove(history, 1) end
    historyIndex = #history + 1
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
addLine("Type ;help to view commands. RightCtrl toggles the window.", CONFIG.Muted)
addLine("Use ;help <word> to search commands.", CONFIG.Muted)
notify("Standalone client utility loaded.")
