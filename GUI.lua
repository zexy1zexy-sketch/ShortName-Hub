local Players = game:GetService("Players"); local UIS = game:GetService("UserInputService"); local GuiService = game:GetService("GuiService")
local CREATOR_USER_ID = 7867608166
local LocalPlayer = Players.LocalPlayer
local IsCreator = LocalPlayer ~= nil and LocalPlayer.UserId == CREATOR_USER_ID
local OwnerViewEnabled = IsCreator
local OwnerOnlyFolders = {}
local function GetUploadKeyCache()
 local shared = _G
 if type(getgenv) == "function" then
 local ok, value = pcall(getgenv)
 if ok and type(value) == "table" then shared = value end
 end
 if type(shared.__SHORTNAME_UPLOAD_KEY) ~= "string" then shared.__SHORTNAME_UPLOAD_KEY = "" end
 return shared
end
local UploadKeyCache = GetUploadKeyCache()
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
 local welcomeTitle = label(welcomeCard, "SHORTNAME HUB - CONTROL CENTER", 13, 25, accent.Light)
 welcomeTitle.Position = UDim2.fromOffset(14, 12)
 welcomeTitle.Font = Enum.Font.GothamBold
 local welcomeDescription = label(welcomeCard, "A living changelog of features, improvements, and fixes since the Updates page was introduced.", 11, 48, white)
 welcomeDescription.Position = UDim2.fromOffset(14, 42)
 welcomeDescription.TextWrapped = true

 local currentVersion = tostring(config.Version or "1.2.6")
 label(page, "CHANGELOG - v" .. currentVersion, 12, 25, accent.Light).Font = Enum.Font.GothamBold
 local updateItems = {
 {
 "v1.4.3 - Standalone Observer console | Nov 28",
 "Promoted Observer to its own owner-only top-level tab. Consolidated remote logging, live changes, object scanning, instance inspection, and structure finding into one console with an ALL selector, unified logs, filtering, copy/clear controls, and one authenticated report upload. Removed the duplicate detector folders and upload interfaces.",
 },
 {
 "v1.3.2 - Remove legacy combat tab and tools | Nov 26",
 "Removed the dedicated game tab, combat HUD, hitbox visualizer, weapon movement observer, and game-specific hitbox diagnostics. Retained read-only universal scanners, live observer, and remote logger; renamed scanner modules to remove legacy game-specific filenames.",
 },
 {
 "v1.3.1 - Feedback location and text stroke cleanup | Nov 26",
 "Removed the FEED header button. Moved the permanent feedback form to Coming Soon. Enforced zero text stroke on all existing and dynamically created hub, key-screen, and loading-screen text objects.",
 },
 {
 "v1.3.0 - Header toolbar and permanent feedback feed | Nov 26",
 "Moved the quick menu into the managed horizontal toolbar to prevent overlap. Added the feedback form to the interface.",
 },
 {
 "v1.2.9 - Key startup crash fix | Nov 26",
 "Removed the key-screen descendant styling scan that was crashing startup.",
 },
 {
 "v1.2.7 - Compact header and clean typography | Nov 26",
 "Reworked header sizing to adapt to the available window width and reserve space for the hub title. Removed text outlines throughout the hub, key system, and loading screen.",
 },
 {
 "v1.2.6 - Header, key and loading screen polish | Nov 26",
 "Rebuilt the header actions into a right-aligned horizontal control rail to prevent overlap at all supported window sizes. Matched the key verification and loading screens to the flat monochrome interface.",
 },
 {
 "v1.2.5 - Xeno-inspired monochrome interface | Nov 26",
 "Reworked the hub with a near-black flat interface, neutral borders, compact text-only navigation, and a cleaner responsive layout.",
 },
 {
 "v1.2.4 - 24-hour key remember-me | Nov 25",
 "After a user enters the correct key, access is remembered locally for 24 hours. The key is requested again after the saved access expires."
 },
 {
 "v1.2.3 - Key system Discord invite | Nov 25",
 "Updated the key-system JOIN DISCORD button to copy the official community invite: https://discord.gg/JgAsS6yYAH."
 },
 {
 "v1.2.2 - Guess the Slapper cleanup | Nov 25",
 "Removed Auto Dodge, player roster/cards, manual round notes, and the universal inspector from Guess the Slapper. Kept only the Who Slapped Me detector and its compact mini panel."
 },
 {
 "v1.2.0 - Game tools, automation & reliability | Nov 23-25",
 "Added the owner-only Detection & Observation area, manual game detector and manually approved game reports. Added universal game, structure, instance and live-value scanners/observers, report snapshots, authenticated uploads and owner security reports. Added the Guess the Slapper who-hit-you detector. Added Noob Incremental code redemption and Thanksgiving Event automation, including Turkey Oof milestones, all three Noob upgrades (including Noob Upgrade 3), and Turkey upgrades. Added separate Toggle All controls for Farm Area and Thanksgiving Event. Added bounded remote-call logging and authenticated report uploads. Fixed detector metadata, observation signal quality, Perfect Dodge logging, remote argument formatting, automation lookups/toggles, GUI cleanup, refresh recovery, startup failures and multiple Luau compiler/register-limit issues. Removed always-on inspection watchers that caused FPS drops; scanners are on-demand."
 },
 {
 "v1.1.0 - Interface redesign | Nov 22-23",
 "Introduced the Updates home page and collapsible minimal sidebar. Expanded the responsive window and added adjustable UI scale, transparency, custom backgrounds, accent colors, active-navigation glow and page animations. Added searchable navigation, global search with Ctrl+K, settings search, notification history, quick menu, profiles, keybinds, HUD and player directory. Added the creator-only Players dashboard, community ranks and presence roster, plus a separate Player Tools area. Fixed accent colors gradually brightening, small-window scrolling, navigation/view switching, overlapping header controls, unsupported icons and feedback placement."
 },
 {
 "v1.0.2 - Versioned notes & settings polish | Nov 22",
 "Added the versioned release label to the loader and hub header, plus expandable update notes. Improved settings search and version display. Added the early diagnostic console with minimize, hide and drag controls, session diagnostics and a hub hotkey. Added full hub refresh/reload controls and utility actions. Improved module loading and private-repository startup, report upload timeouts and feedback formatting."
 },
 {
 "v1.0.1 - Core stability | Nov 22",
 "Improved the key-system/loading flow, error handling and module loader. Fixed base64 whitespace decoding and private-repository loader startup. Continued stabilizing the GUI and automation controls ahead of the larger interface redesign."
 },
 {
 "v1.0.0 - Initial version tracking | Nov 22",
 "Established ShortName Hub's initial public version identifier and displayed the version in the hub header and loader so releases could be tracked consistently."
 },
 {
 "Earlier project foundation | Nov 19-22",
 "Built the modular hub and game-specific tools, including Noob Incremental automation, NPC/teleport/scythe utilities, Thanksgiving scanning and report upload, and universal diagnostics. Added owner/member view separation and private report/feedback infrastructure. Removed the house-toggle feature and later kept RemoteSpy controls out of the regular GUI."
 }
 }

 for _, item in ipairs(updateItems) do
 local card = Instance.new("Frame")
 card.Size = UDim2.new(1, 0, 0, 42)
 card.BackgroundColor3 = buttonDark
 card.BorderSizePixel = 0
 card.ClipsDescendants = true
 card.Parent = page
 corner(card, 10)
 stroke(card, border, 1)
 local heading = Instance.new("TextButton")
 heading.Size = UDim2.new(1, -20, 0, 40)
 heading.Position = UDim2.fromOffset(10, 1)
 heading.BackgroundTransparency = 1
 heading.Text = item[1] .. " +"
 heading.TextColor3 = white
 heading.TextSize = 10
 heading.Font = Enum.Font.GothamBold
 heading.TextXAlignment = Enum.TextXAlignment.Left
 heading.TextTruncate = Enum.TextTruncate.AtEnd
 heading.Parent = card
 local detail = label(card, item[2], 10, 66, grey)
 detail.Position = UDim2.fromOffset(12, 43)
 detail.Size = UDim2.new(1, -24, 0, 62)
 detail.TextWrapped = true
 detail.TextYAlignment = Enum.TextYAlignment.Top
 detail.Visible = false
 local expanded = false
 heading.Activated:Connect(function()
 expanded = not expanded
 detail.Visible = expanded
 heading.Text = item[1] .. (expanded and " -" or " +")
 tween(card, { Size = UDim2.new(1, 0, 0, expanded and 112 or 42) }, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
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

function GUI.Create(Config, Controller, Scythe, ObjectScanner, InstanceInspector, StructureScanner, LiveObserver, RemoteLogger, RefreshCallback, PresenceModule, ThemeModule)
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
 math.max(300, math.min(900, math.floor(Viewport.X * 0.90)))
 local WindowHeight = math.max(340, math.min(680, math.floor(Viewport.Y * 0.82)))
 -- Xeno-inspired monochrome theme: near-black surfaces, quiet borders, white text.
 local Purple = Color3.fromRGB(205, 205, 205); local Dark = Color3.fromRGB(8, 8, 8)
 local Panel = Color3.fromRGB(12, 12, 12); local ButtonDark = Color3.fromRGB(24, 24, 24); local White = Color3.fromRGB(242, 242, 242)
 local Grey = Color3.fromRGB(158, 158, 158); local PurpleLight = Color3.fromRGB(225, 225, 225); local Border = Color3.fromRGB(48, 48, 48)
 local FastTween = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

 local function Tween(obj, properties, info)
 if obj and obj.Parent then
 TweenService:Create(obj, info or FastTween, properties):Play()
 end
 end

 local function AddGradient(obj, topColor, bottomColor, rotation)
 -- Keep surfaces flat and monochrome like the reference interface.
 obj.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
 return nil
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
 local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, math.min(radius or 8, 3)); c.Parent = obj
 end

 local function Stroke(obj, color, thickness)
 local s = Instance.new("UIStroke"); s.Color = color or Purple; s.Thickness = thickness or 1
 s.Transparency = 0.18; s.Parent = obj
 return s
 end

 local function Label(parent, text, size, height, color)
 local item = Instance.new("TextLabel"); item.Size = UDim2.new(1, 0, 0, height or 25); item.BackgroundTransparency = 1
 item.Text = text; item.TextColor3 = color or White; item.TextSize = size or 13
 item.TextStrokeTransparency = 1; item.TextStrokeColor3 = Color3.new(0, 0, 0)
 item.Font = Enum.Font.Gotham; item.TextXAlignment = Enum.TextXAlignment.Left; item.Parent = parent
 return item
 end

 -- MAIN WINDOW
 local Frame = Instance.new("Frame"); Frame.Size = UDim2.fromOffset(WindowWidth, WindowHeight); Frame.Position = UDim2.new(0.5, -WindowWidth / 2,
 0.5, -WindowHeight / 2)
 Frame.BackgroundColor3 = Dark; Frame.BorderSizePixel = 0; Frame.ClipsDescendants = true; Frame.Parent = ScreenGui
 local WindowScale = Instance.new("UIScale"); WindowScale.Scale = 1; WindowScale.Parent = Frame
 Corner(Frame, 3); Frame.BackgroundColor3 = Dark; Stroke(Frame, Border, 1)
 GUI.BackgroundImage = Instance.new("ImageLabel")
 GUI.BackgroundImage.Name = "CustomBackground"
 GUI.BackgroundImage.Size = UDim2.fromScale(1, 1)
 GUI.BackgroundImage.BackgroundTransparency = 1
 GUI.BackgroundImage.ImageTransparency = 1
 GUI.BackgroundImage.ScaleType = Enum.ScaleType.Crop
 GUI.BackgroundImage.ZIndex = 0
 GUI.BackgroundImage.Parent = Frame

 local AccentLine = Instance.new("Frame"); AccentLine.Name = "AccentLine"; AccentLine.Size = UDim2.new(1, -28, 0, 1)
 AccentLine.Position = UDim2.fromOffset(14, 48); AccentLine.BackgroundColor3 = Border; AccentLine.BorderSizePixel = 0
 AccentLine.ZIndex = 3; AccentLine.Parent = Frame; AddGradient(AccentLine, PurpleLight, Purple, 0)
 Corner(AccentLine, 2)

 local Header, MinButton, ExitButton, OwnerViewButton, GearButton, RefreshHubButton
 do -- section scope: keeps Luau local-register usage below the 200-local limit
 -- HEADER
 Header = Instance.new("Frame"); Header.Size = UDim2.new(1, 0, 0, 48); Header.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
 Header.BorderSizePixel = 0; Header.Parent = Frame; Corner(Header, 2)
 local HeaderTitle = Label(Header, "SHORTNAME HUB", 15, 48); HeaderTitle.Font =
 Enum.Font.GothamBold
 HeaderTitle.Size = UDim2.new(1, IsCreator and -410 or -336, 0, 25); HeaderTitle.TextTruncate = Enum.TextTruncate.AtEnd; HeaderTitle.Position = UDim2.fromOffset(14, 5); HeaderTitle.TextSize = 15
 local ReportedExecutor = "Unknown / unavailable"
 pcall(function()
 if type(identifyexecutor) == "function" then
 local value = identifyexecutor()
 if type(value) == "string" and value ~= "" then ReportedExecutor = value end
 elseif type(getexecutorname) == "function" then
 local value = getexecutorname()
 if type(value) == "string" and value ~= "" then ReportedExecutor = value end
 end
 end)
 local HeaderSubtitle = Label(Header, "@" .. tostring(LocalPlayer and LocalPlayer.Name or "Unknown") .. " | " .. ReportedExecutor .. " | v" .. tostring(Config.Version or "1.0.0"), 8, 14, Grey); HeaderSubtitle.Position = UDim2.fromOffset(14, 27)
 HeaderSubtitle.Size = UDim2.new(1, IsCreator and -410 or -336, 0, 13); HeaderSubtitle.TextTruncate = Enum.TextTruncate.AtEnd; HeaderSubtitle.Font = Enum.Font.GothamMedium; HeaderSubtitle.TextTransparency = 0.12

 MinButton = Instance.new("TextButton"); MinButton.Size = UDim2.fromOffset(24, 30); MinButton.Position = UDim2.new(1, -70, 0, 8)
 MinButton.BackgroundColor3 = ButtonDark; MinButton.Text = "-"; MinButton.TextColor3 = White
 MinButton.TextSize = 17; MinButton.Font = Enum.Font.GothamBold; MinButton.Parent = Header
 MinButton.ZIndex = 5; Corner(MinButton, 2); Stroke(MinButton, Border, 1)
 AddHover(MinButton, ButtonDark, Color3.fromRGB(55, 48, 69))

 ExitButton = Instance.new("TextButton"); ExitButton.Size = UDim2.fromOffset(24, 30)
 ExitButton.Position = UDim2.new(1, -36, 0, 8); ExitButton.BackgroundColor3 = ButtonDark; ExitButton.Text = "X"
 ExitButton.TextColor3 = Color3.fromRGB(255, 170, 180); ExitButton.TextSize = 21; ExitButton.Font = Enum.Font.Gotham
 ExitButton.Parent = Header; Corner(ExitButton, 2); Stroke(ExitButton, Border, 1)
 AddHover(ExitButton, ButtonDark, Color3.fromRGB(95, 43, 55))

 -- CREATOR-ONLY VIEW SWITCH
 if IsCreator then
 OwnerViewButton = Instance.new("TextButton")
 OwnerViewButton.Size = UDim2.fromOffset(54, 30)
 OwnerViewButton.Position = UDim2.new(1, -240, 0, 9)
 OwnerViewButton.BackgroundColor3 = ButtonDark
 OwnerViewButton.Text = "OWNER"
 OwnerViewButton.TextColor3 = White
 OwnerViewButton.TextSize = 9
 OwnerViewButton.Font = Enum.Font.GothamBold
 OwnerViewButton.Parent = Header
 OwnerViewButton.ZIndex = 8
 Corner(OwnerViewButton, 7)
 Stroke(OwnerViewButton, Border, 1)
 AddHover(OwnerViewButton, ButtonDark, Color3.fromRGB(48, 48, 48))
 end

 -- OWNER SETTINGS SHORTCUT: sits immediately left of the owner/users switch.
 do
 GearButton = Instance.new("TextButton")
 GearButton.Size = UDim2.fromOffset(68, 30)
 GearButton.Position = UDim2.new(1, IsCreator and -274 or -240, 0, 8)
 GearButton.BackgroundColor3 = ButtonDark
 GearButton.Text = "SETTINGS"
 GearButton.TextColor3 = White
 GearButton.TextSize = 17
 GearButton.Font = Enum.Font.GothamBold
 GearButton.Parent = Header
 GearButton.ZIndex = 8
 Corner(GearButton, 8)
 Stroke(GearButton, Border, 1)
 AddHover(GearButton, ButtonDark, Color3.fromRGB(55, 48, 69))
 end

 end
 local CrownButton, FeedbackButton, CommunityPanel, FeedbackPanel, FeedbackTitle, FeedbackClose, FeedbackBox, FeedbackStatus
 local FeedbackSend
 do -- section scope: keeps Luau local-register usage below the 200-local limit
 -- COMMUNITY SHORTCUTS
 CrownButton = Instance.new("TextButton")
 CrownButton.Size = UDim2.fromOffset(48, 30)
 CrownButton.Position = UDim2.new(1, IsCreator and -172 or -172, 0, 8)
 CrownButton.BackgroundColor3 = ButtonDark
 CrownButton.Text = "CREDS"
 CrownButton.TextColor3 = White
 CrownButton.TextSize = 19
 CrownButton.Font = Enum.Font.GothamBold
 CrownButton.Parent = Header
 CrownButton.ZIndex = 8
 Corner(CrownButton, 8)
 Stroke(CrownButton, Color3.fromRGB(155, 120, 65), 1)
 AddHover(CrownButton, ButtonDark, Color3.fromRGB(65, 53, 37))

 CommunityPanel = Instance.new("Frame")
 CommunityPanel.Size = UDim2.fromOffset(244, 132)
 CommunityPanel.Position = UDim2.new(1, -254, 0, 56)
 CommunityPanel.BackgroundColor3 = Panel
 CommunityPanel.BorderSizePixel = 0
 CommunityPanel.Visible = false
 CommunityPanel.ZIndex = 20
 CommunityPanel.Parent = Frame
 Corner(CommunityPanel, 10)
 Stroke(CommunityPanel, CurrentAccent and CurrentAccent.Light or PurpleLight, 1.2)
 local CommunityTitle = Label(CommunityPanel, " CONTRIBUTORS", 13, 28, PurpleLight)
 CommunityTitle.Font = Enum.Font.GothamBold
 CommunityTitle.Position = UDim2.fromOffset(8, 4)
 CommunityTitle.ZIndex = 21
 local CreatorLine = Label(CommunityPanel, " shortname_zen - CREATOR", 11, 28, White)
 CreatorLine.Position = UDim2.fromOffset(8, 36)
 CreatorLine.ZIndex = 21
 local CommunityNote = Label(CommunityPanel, " More contributors will be listed here as they join.", 9, 38, Grey)
 CommunityNote.Position = UDim2.fromOffset(8, 68)
 CommunityNote.TextWrapped = true
 CommunityNote.ZIndex = 21
 local CommunityClose = Instance.new("TextButton")
 CommunityClose.Size = UDim2.fromOffset(24, 24)
 CommunityClose.Position = UDim2.new(1, -29, 0, 4)
 CommunityClose.BackgroundColor3 = ButtonDark
 CommunityClose.Text = ""
 CommunityClose.TextColor3 = White
 CommunityClose.TextSize = 17
 CommunityClose.Parent = CommunityPanel
 CommunityClose.ZIndex = 22
 Corner(CommunityClose, 6)
 CommunityClose.Activated:Connect(function()
 CommunityPanel.Visible = false
 end)

 FeedbackPanel = Instance.new("Frame")
 FeedbackPanel.Size = UDim2.fromOffset(244, 226)
 FeedbackPanel.Position = UDim2.new(1, -254, 0, 56)
 FeedbackPanel.BackgroundColor3 = Panel
 FeedbackPanel.BorderSizePixel = 0
 FeedbackPanel.ZIndex = 20
 FeedbackPanel.Parent = Frame
 Corner(FeedbackPanel, 10)
 Stroke(FeedbackPanel, PurpleLight, 1.2)
 FeedbackTitle = Label(FeedbackPanel, " SEND FEEDBACK", 13, 28, PurpleLight)
 FeedbackTitle.Font = Enum.Font.GothamBold
 FeedbackTitle.Position = UDim2.fromOffset(8, 4)
 FeedbackTitle.ZIndex = 21
 FeedbackClose = Instance.new("TextButton")
 FeedbackClose.Size = UDim2.fromOffset(24, 24)
 FeedbackClose.Position = UDim2.new(1, -29, 0, 4)
 FeedbackClose.BackgroundColor3 = ButtonDark
 FeedbackClose.Text = ""
 FeedbackClose.TextColor3 = White
 FeedbackClose.TextSize = 17
 FeedbackClose.Parent = FeedbackPanel
 FeedbackClose.ZIndex = 22
 Corner(FeedbackClose, 6)
 FeedbackBox = Instance.new("TextBox")
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
 FeedbackStatus = Label(FeedbackPanel, "Ideas go to the private hub feedback inbox.", 9, 26, Grey)
 FeedbackStatus.Position = UDim2.fromOffset(10, 154)
 FeedbackStatus.TextWrapped = true
 FeedbackStatus.ZIndex = 21
 FeedbackSend = Instance.new("TextButton")
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
 FeedbackClose.Activated:Connect(function()
 SelectPage("Soon")
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
 Body = HttpService:JSONEncode({
 message = message,
 username = LocalPlayer and LocalPlayer.Name or "",
 userId = LocalPlayer and LocalPlayer.UserId or 0
 })
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

 end
 local SidebarWidth, Sidebar, SidebarSearch, PlayerAdminUI, GameNav, PlayerToolsNav, DetectionNav, SoonNav, IsNoobIncrementalExperience
 do -- section scope: keeps Luau local-register usage below the 200-local limit
 -- SIDEBAR
 SidebarWidth = math.min(166, WindowWidth * 0.28); Sidebar = Instance.new("ScrollingFrame"); Sidebar.Name = "Sidebar"
 Sidebar.Position = UDim2.fromOffset(14, 62); Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -76)
 Sidebar.BackgroundColor3 = Panel; Sidebar.BackgroundTransparency = 1; Sidebar.BorderSizePixel = 0
 Sidebar.CanvasSize = UDim2.fromOffset(0, 0); Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.None
 Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y; Sidebar.ScrollingEnabled = true
 Sidebar.ScrollBarThickness = 4; Sidebar.ScrollBarImageColor3 = Purple; Sidebar.Active = true
 Sidebar.ClipsDescendants = true; Sidebar.Parent = Frame
 local SideLayout = Instance.new("UIListLayout"); SideLayout.Padding = UDim.new(0, 3)
 SideLayout.SortOrder = Enum.SortOrder.LayoutOrder; SideLayout.Parent = Sidebar
 local SidePadding = Instance.new("UIPadding")
 SidePadding.PaddingTop = UDim.new(0, 9); SidePadding.PaddingLeft = UDim.new(0, 8); SidePadding.PaddingRight = UDim.new(0, 8)
 SidePadding.PaddingBottom = UDim.new(0, 9); SidePadding.Parent = Sidebar
 SideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
 Sidebar.CanvasSize = UDim2.fromOffset(0, SideLayout.AbsoluteContentSize.Y + 18)
 end)

 SidebarSearch = Instance.new("TextBox")
 SidebarSearch.Name = "SidebarSearch"; SidebarSearch.LayoutOrder = 0
 SidebarSearch.Size = UDim2.new(1, 0, 0, 34); SidebarSearch.BackgroundColor3 = ButtonDark
 SidebarSearch.BackgroundTransparency = 0.08; SidebarSearch.BorderSizePixel = 0
 SidebarSearch.Text = ""; SidebarSearch.PlaceholderText = "Search tabs..."
 SidebarSearch.PlaceholderColor3 = Grey; SidebarSearch.TextColor3 = White
 SidebarSearch.TextSize = 10; SidebarSearch.Font = Enum.Font.Gotham
 SidebarSearch.ClearTextOnFocus = false; SidebarSearch.TextXAlignment = Enum.TextXAlignment.Left
 SidebarSearch.Parent = Sidebar; Corner(SidebarSearch, 2); Stroke(SidebarSearch, Border, 1)

 local function MakeNav(text, order)
 local b = Instance.new("TextButton"); b.Name = text; b.LayoutOrder = order
 b.Size = UDim2.new(1, 0, 0, 38); b.BackgroundColor3 = ButtonDark; b.BackgroundTransparency = 1; b.TextColor3 = Grey
 b.Text = text; b:SetAttribute("SNHFullText", text); b:SetAttribute("SNHShortText", text:match("^([^%s]+)") or "-"); b.TextSize = WindowWidth < 380 and 11 or 12; b.Font = Enum.Font.GothamMedium
 b.TextXAlignment = Enum.TextXAlignment.Left
 b.Parent = Sidebar; Corner(b, 2)
 local navStroke = Stroke(b, Border, 1)
 navStroke.Transparency = 1
 return b
 end

 PlayerAdminUI = {}
 -- All game tabs remain available in every experience. When the current
 -- experience matches one of them, move that tab to the top automatically.
 GameNav = MakeNav("Noob Incremental", 1)
 GUI.GuessSlapperNav = MakeNav("Guess the Slapper", 2)
 GUI.UpdatesNav = MakeNav("Updates", 3)
 PlayerToolsNav = MakeNav("Player Tools", 5)
 SoonNav = MakeNav("Coming Soon", 6)
 if IsCreator then PlayerAdminUI.Nav = MakeNav("Players", 7) end
 DetectionNav = IsCreator and MakeNav("Observer", 8) or nil

 local CurrentExperienceName = tostring(game.Name or "")
 pcall(function()
 local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
 if info and type(info.Name) == "string" and info.Name ~= "" then
 CurrentExperienceName = info.Name
 end
 end)
 local experienceKey = CurrentExperienceName:lower()
 IsNoobIncrementalExperience = game.PlaceId == 76911729991355 or game.GameId == 76911729991355
 or experienceKey:find("noob incremental", 1, true) ~= nil
 or experienceKey:find("noob", 1, true) ~= nil
 local activeGameNav
 if game.PlaceId == 106683702021527 or game.GameId == 9449993534
 or experienceKey:find("guess the slapper", 1, true)
 or experienceKey:find("slapper", 1, true) then
 activeGameNav = GUI.GuessSlapperNav
 elseif IsNoobIncrementalExperience then
 activeGameNav = GameNav
 end
 if activeGameNav then
 local gameTabs = { GameNav, GUI.GuessSlapperNav }
 activeGameNav.LayoutOrder = 1
 local nextOrder = 2
 for _, nav in ipairs(gameTabs) do
 if nav ~= activeGameNav then
 nav.LayoutOrder = nextOrder
 nextOrder = nextOrder + 1
 end
 end
 GUI.UpdatesNav.LayoutOrder = 3
 PlayerToolsNav.LayoutOrder = 5
 SoonNav.LayoutOrder = 6
 if PlayerAdminUI.Nav then PlayerAdminUI.Nav.LayoutOrder = 7 end
 if DetectionNav then DetectionNav.LayoutOrder = 8 end
 end

 local SidebarNavButtons = { PlayerAdminUI.Nav, PlayerToolsNav, GameNav, GUI.GuessSlapperNav, DetectionNav, SoonNav }
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

 end
 local Content, SettingsPage, PlayerToolsPage, GamePage, DetectionPage, SoonPage, CurrentPage
 local CurrentAccent, FloatingTabsEnabled, FloatingTabWindow, RestoreFloatingPage, SelectPage
 do -- section scope: keeps Luau local-register usage below the 200-local limit
 -- CONTENT AREA
 Content = Instance.new("Frame"); Content.Position = UDim2.new(0, SidebarWidth + 20, 0, 58); Content.Size = UDim2.new(1, -SidebarWidth - 30,
 1, -68)
 Content.BackgroundColor3 = Panel; Content.BackgroundTransparency = 0.18; Content.BorderSizePixel = 0; Content.Parent = Frame
 Corner(Content, 2); Content.BackgroundColor3 = Panel; Stroke(Content, Border, 1)

 GUI.SidebarCollapsed = false
 GUI.SidebarToggle = Instance.new("TextButton")
 GUI.SidebarToggle.Name = "SidebarToggle"
 GUI.SidebarToggle.Size = UDim2.fromOffset(42, 30)
 GUI.SidebarToggle.Position = UDim2.new(1, IsCreator and -342 or -274, 0, 8)
 GUI.SidebarToggle.BackgroundColor3 = ButtonDark
 GUI.SidebarToggle.Text = "-"
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
 for _, nav in pairs({ PlayerAdminUI.Nav, PlayerToolsNav, GameNav, GUI.GuessSlapperNav, DetectionNav, SoonNav }) do
 if nav then
 nav.Text = GUI.SidebarCollapsed and (nav:GetAttribute("SNHShortText") or "-") or (nav:GetAttribute("SNHFullText") or nav.Name)
 nav.TextXAlignment = GUI.SidebarCollapsed and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
 nav.TextSize = GUI.SidebarCollapsed and 16 or (WindowWidth < 380 and 11 or 12)
 end
 end
 GUI.SidebarToggle.Text = GUI.SidebarCollapsed and "+" or "-"
 end)

 local function MakePage(name)
 local page = Instance.new("ScrollingFrame"); page.Name = name; page.Size = UDim2.new(1, -16, 1, -16)
 page.Position = UDim2.fromOffset(8, 8); page.BackgroundTransparency = 1; page.BorderSizePixel = 0
 page.ScrollBarThickness = 5; page.ScrollBarImageColor3 = Purple; page.CanvasSize = UDim2.fromOffset(0, 0)
 page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.ScrollingDirection = Enum.ScrollingDirection.Y
 page.ScrollingEnabled = true; page.Active = true; page.ClipsDescendants = true
 page.Visible = false; page.Parent = Content; local layout = Instance.new("UIListLayout")
 layout.Padding = UDim.new(0, 11); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = page
 local padding = Instance.new("UIPadding"); padding.PaddingBottom = UDim.new(0, 18); padding.Parent = page
 page.CanvasSize = UDim2.fromOffset(0, 0)
 return page
 end

 GUI.UpdatesPage = MakePage("Updates"); SettingsPage = MakePage("Settings"); PlayerAdminUI.Page = IsCreator and MakePage("Players") or nil
 PlayerToolsPage = MakePage("PlayerTools")
 GamePage = MakePage("NoobIncremental")
 GUI.GuessSlapperPage = MakePage("GuessTheSlapper")
 DetectionPage = IsCreator and MakePage("Observer") or nil; SoonPage = MakePage("ComingSoon"); CurrentPage = nil; CurrentAccent = { Color = Purple, Light = PurpleLight, Active = Color3.fromRGB(38, 38, 38) }

 FloatingTabsEnabled = false
 FloatingTabWindow = Instance.new("Frame")
 FloatingTabWindow.Name = "FloatingTabWindow"
 FloatingTabWindow.Size = UDim2.new(0.68, 0, 0.72, 0)
 FloatingTabWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
 FloatingTabWindow.AnchorPoint = Vector2.new(0.5, 0.5)
 FloatingTabWindow.BackgroundColor3 = Panel
 FloatingTabWindow.BorderSizePixel = 0
 FloatingTabWindow.Visible = false
 FloatingTabWindow.ZIndex = 30
 FloatingTabWindow.Parent = ScreenGui
 Corner(FloatingTabWindow, 12)
 Stroke(FloatingTabWindow, PurpleLight, 1.2)
 local FloatingHeader = Instance.new("Frame")
 FloatingHeader.Size = UDim2.new(1, 0, 0, 34)
 FloatingHeader.BackgroundColor3 = Dark
 FloatingHeader.BorderSizePixel = 0
 FloatingHeader.ZIndex = 31
 FloatingHeader.Parent = FloatingTabWindow
 Corner(FloatingHeader, 10)
 local FloatingTitle = Label(FloatingHeader, " TAB WINDOW", 11, 32, White)
 FloatingTitle.Position = UDim2.fromOffset(8, 0)
 FloatingTitle.ZIndex = 32
 local FloatingClose = Instance.new("TextButton")
 FloatingClose.Size = UDim2.fromOffset(26, 25)
 FloatingClose.Position = UDim2.new(1, -31, 0, 4)
 FloatingClose.BackgroundColor3 = ButtonDark
 FloatingClose.Text = "X"
 FloatingClose.TextColor3 = White
 FloatingClose.TextSize = 12
 FloatingClose.Font = Enum.Font.GothamBold
 FloatingClose.ZIndex = 32
 FloatingClose.Parent = FloatingHeader
 Corner(FloatingClose, 6)
 local FloatingBody = Instance.new("Frame")
 FloatingBody.Position = UDim2.fromOffset(7, 40)
 FloatingBody.Size = UDim2.new(1, -14, 1, -47)
 FloatingBody.BackgroundTransparency = 1
 FloatingBody.ClipsDescendants = true
 FloatingBody.ZIndex = 31
 FloatingBody.Parent = FloatingTabWindow
 local CurrentFloatingPage
 function RestoreFloatingPage()
 if CurrentFloatingPage and CurrentFloatingPage.Parent then
 CurrentFloatingPage.Parent = Content
 CurrentFloatingPage.Position = UDim2.fromOffset(8, 8)
 CurrentFloatingPage.Size = UDim2.new(1, -16, 1, -16)
 CurrentFloatingPage.Visible = false
 end
 CurrentFloatingPage = nil
 end
 FloatingClose.Activated:Connect(function()
 FloatingTabWindow.Visible = false
 end)
 local floatingDragging, floatingDragStart, floatingStartPosition = false, nil, nil
 FloatingHeader.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 floatingDragging = true
 floatingDragStart = input.Position
 floatingStartPosition = FloatingTabWindow.Position
 input.Changed:Connect(function()
 if input.UserInputState == Enum.UserInputState.End then floatingDragging = false end
 end)
 end
 end)
 UIS.InputChanged:Connect(function(input)
 if floatingDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
 local delta = input.Position - floatingDragStart
 FloatingTabWindow.Position = UDim2.new(
 floatingStartPosition.X.Scale, floatingStartPosition.X.Offset + delta.X,
 floatingStartPosition.Y.Scale, floatingStartPosition.Y.Offset + delta.Y
 )
 end
 end)
 function SelectPage(page)
 local pages = { Updates = GUI.UpdatesPage, Settings = SettingsPage, Players = PlayerAdminUI.Page, PlayerTools = PlayerToolsPage, Game = GamePage, GuessSlapper = GUI.GuessSlapperPage, Observer = DetectionPage, Soon = SoonPage }
 if CurrentFloatingPage then RestoreFloatingPage() end
 local selectedPage = pages[page]
 local useFloating = FloatingTabsEnabled and page ~= "Settings" and selectedPage ~= nil
 if useFloating then
 for _, pageObject in pairs(pages) do if pageObject then pageObject.Visible = false end end
 selectedPage.Parent = FloatingBody
 selectedPage.Position = UDim2.fromOffset(0, 0)
 selectedPage.Size = UDim2.new(1, 0, 1, 0)
 selectedPage.Visible = true
 selectedPage.CanvasPosition = Vector2.new(0, 0)
 CurrentFloatingPage = selectedPage
 FloatingTitle.Text = " " .. string.upper(tostring(page)) .. " • SHORTNAME HUB"
 FloatingTabWindow.Visible = true
 else
 FloatingTabWindow.Visible = false
 for name, pageObject in pairs(pages) do
 if pageObject then
 if pageObject.Parent ~= Content then pageObject.Parent = Content end
 pageObject.Size = UDim2.new(1, -16, 1, -16)
 pageObject.Position = UDim2.fromOffset(8, 8)
 pageObject.Visible = name == page
 if name == page then pageObject.CanvasPosition = Vector2.new(0, 0) end
 end
 end
 end

 CurrentPage = page; local activeColor = Color3.fromRGB(38, 38, 38)

 local function StyleNav(button, active)
 Tween(button, { BackgroundColor3 = active and activeColor or ButtonDark, BackgroundTransparency = active and 0.08 or 1 }); local outline = button:FindFirstChildOfClass("UIStroke")
 if outline then
 Tween(outline, { Color = Border, Transparency = 1, Thickness = 1 })
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
 if DetectionNav then StyleNav(DetectionNav, page == "Observer") end; StyleNav(SoonNav, page == "Soon")
 end

 do
 GUI.GlobalSearchButton = Instance.new("TextButton")
 GUI.GlobalSearchButton.Name = "GlobalSearchButton"
 GUI.GlobalSearchButton.Size = UDim2.fromOffset(52, 30)
 GUI.GlobalSearchButton.Position = UDim2.new(1, IsCreator and -376 or -308, 0, 8)
 GUI.GlobalSearchButton.BackgroundColor3 = ButtonDark
 GUI.GlobalSearchButton.Text = "SEARCH"
 GUI.GlobalSearchButton.TextColor3 = White
 GUI.GlobalSearchButton.TextSize = 8
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
 searchClose.Text = ""
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
 ComingSoon = "Soon"
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
 resultButton.Text = " " .. string.sub(value:gsub("%s+", " "), 1, 54) .. " - " .. pageKey
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
 end)
 if GearButton then
 GearButton.Activated:Connect(function()
 CommunityPanel.Visible = false
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
 if DetectionNav then
 DetectionNav.Activated:Connect(function()
 if OwnerViewEnabled then SelectPage("Observer") end
 end)
 end
 SoonNav.Activated:Connect(function()
 SelectPage("Soon")
 end)

 end
 local AccentPresets, ApplyAccent, SurfacePresets, ActiveSurfacePreset, ApplySurfaceTheme
 do -- section scope: keeps Luau local-register usage below the 200-local limit
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
 -- AUTO-LOAD AFTER REJOIN
 do
 local shared = _G
 if type(getgenv) == "function" then
 local ok, env = pcall(getgenv)
 if ok and type(env) == "table" then shared = env end
 end
 local setAutoLoad = shared.__SHORTNAME_SET_AUTOLOAD
 local autoLoadEnabled = false
 if type(readfile) == "function" and type(isfile) == "function" then
 local ok, exists = pcall(isfile, "ShortNameHub_AutoLoad.txt")
 if ok and exists then
 local readOk, value = pcall(readfile, "ShortNameHub_AutoLoad.txt")
 autoLoadEnabled = readOk and tostring(value):lower() == "true"
 end
 end
 Label(SettingsPage, "AUTO-LOAD", 13, 25, PurpleLight).Font = Enum.Font.GothamBold
 Label(SettingsPage, "Queues ShortName Hub to run again when you teleport or rejoin. Requires executor queue-on-teleport and file APIs.", 10, 38, Grey).TextWrapped = true
 local autoLoadButton = Instance.new("TextButton")
 autoLoadButton.Size = UDim2.new(1, 0, 0, 38)
 autoLoadButton.BackgroundColor3 = autoLoadEnabled and Color3.fromRGB(45, 115, 75) or ButtonDark
 autoLoadButton.TextColor3 = White
 autoLoadButton.Text = autoLoadEnabled and "AUTO-LOAD AFTER REJOIN: ON" or "AUTO-LOAD AFTER REJOIN: OFF"
 autoLoadButton.TextSize = 11
 autoLoadButton.Font = Enum.Font.GothamBold
 autoLoadButton.Parent = SettingsPage
 Corner(autoLoadButton, 9)
 Stroke(autoLoadButton, Border, 1)
 local autoLoadStatus = Label(SettingsPage, autoLoadEnabled and "Preference saved." or "Auto-load is disabled.", 10, 22, Grey)
 autoLoadButton.Activated:Connect(function()
 if type(setAutoLoad) ~= "function" then
 autoLoadStatus.Text = "AUTO-LOAD CONTROL UNAVAILABLE — RE-EXECUTE THE UPDATED LOADER"
 return
 end
 local nextEnabled = not autoLoadEnabled
 local ok, message = setAutoLoad(nextEnabled)
 if ok then
 autoLoadEnabled = nextEnabled
 autoLoadButton.Text = autoLoadEnabled and "AUTO-LOAD AFTER REJOIN: ON" or "AUTO-LOAD AFTER REJOIN: OFF"
 autoLoadButton.BackgroundColor3 = autoLoadEnabled and Color3.fromRGB(45, 115, 75) or ButtonDark
 end
 autoLoadStatus.Text = tostring(message or (ok and "Saved." or "Could not update auto-load."))
 end)
 end

 Label(SettingsPage, "APPEARANCE", 13, 25, PurpleLight).Font = Enum.Font.GothamBold; Label(SettingsPage, "Accent color", 11, 19, Grey)

 AccentPresets = {
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

 function ApplyAccent(preset)
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
 for _, nav in pairs({ GUI.UpdatesNav, PlayerAdminUI.Nav, PlayerToolsNav, GameNav, GUI.GuessSlapperNav, SoonNav }) do
 if nav then
 local active = (CurrentPage == "Updates" and nav == GUI.UpdatesNav)
 or (CurrentPage == "Players" and nav == PlayerAdminUI.Nav)
 or (CurrentPage == "PlayerTools" and nav == PlayerToolsNav)
 or (CurrentPage == "Game" and nav == GameNav)
 or (CurrentPage == "GuessSlapper" and nav == GUI.GuessSlapperNav)
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
 SurfacePresets = {
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

 ActiveSurfacePreset = SurfacePresets[1]
 function ApplySurfaceTheme(preset)
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

 local FloatingTabsToggle = Instance.new("TextButton")
 FloatingTabsToggle.Size = UDim2.new(1, 0, 0, 38)
 FloatingTabsToggle.BackgroundColor3 = ButtonDark
 FloatingTabsToggle.TextColor3 = White
 FloatingTabsToggle.TextSize = 11
 FloatingTabsToggle.Font = Enum.Font.GothamBold
 FloatingTabsToggle.Parent = SettingsPage
 Corner(FloatingTabsToggle, 9)
 Stroke(FloatingTabsToggle, Border, 1)
 local function UpdateFloatingToggle()
 FloatingTabsToggle.Text = "OPEN TABS IN FLOATING WINDOWS: " .. (FloatingTabsEnabled and "ON" or "OFF")
 end
 UpdateFloatingToggle()
 FloatingTabsToggle.Activated:Connect(function()
 FloatingTabsEnabled = not FloatingTabsEnabled
 UpdateFloatingToggle()
 if not FloatingTabsEnabled then
 RestoreFloatingPage()
 FloatingTabWindow.Visible = false
 if CurrentPage and CurrentPage ~= "Settings" then SelectPage(CurrentPage) end
 end
 end)

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


 RefreshHubButton = Instance.new("TextButton")
 RefreshHubButton.Size = UDim2.fromOffset(68, 30)
 RefreshHubButton.Position = UDim2.new(1, -104, 0, 8)
 RefreshHubButton.BackgroundColor3 = ButtonDark
 RefreshHubButton.TextColor3 = White
 RefreshHubButton.TextSize = 9
 RefreshHubButton.Font = Enum.Font.GothamBold
 RefreshHubButton.Text = "REFRESH"
 RefreshHubButton.Parent = Header
 RefreshHubButton.ZIndex = 8
 RefreshHubButton.AutoButtonColor = false
 RefreshHubButton:SetAttribute("SNHTooltip", "Refresh entire hub")
 Corner(RefreshHubButton, 8)
 -- No text/icon stroke on the refresh control.
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
 RefreshHubButton.Text = "REFRESH"
 end
 end
 end)
 end)

 end
 local SetStatus, MakeFolder, MakeBox
 do -- section scope: keeps Luau local-register usage below the 200-local limit
 -- NOOB INCREMENTAL
 Label(GamePage, "NOOB INCREMENTAL", 17, 30).Font = Enum.Font.GothamBold; Label(GamePage, "Tap a folder to show or hide its features.", 12, 22,
 Grey)
 local Status = Label(GamePage, "STATUS: READY", 12, 28, Color3.fromRGB(170, 210, 255)); Status.Font = Enum.Font.GothamBold

 function SetStatus(text)
 Status.Text = "STATUS: " .. tostring(text)
 end

 -- FOLDER SYSTEM
 function MakeFolder(name, parent, visible)
 local Folder = Instance.new("Frame"); Folder.Name = name:gsub("%W", "") .. "Folder"; Folder.Size = UDim2.new(1, 0, 0, 38)
 Folder.Visible = visible ~= false or OwnerViewEnabled
 if visible == false then table.insert(OwnerOnlyFolders, Folder) end
 Folder.BackgroundColor3 = ButtonDark; Folder.BorderSizePixel = 0; Folder.ClipsDescendants = true
 Folder.Parent = parent or GamePage; Corner(Folder, 10); Stroke(Folder, Border, 1)
 AddGradient(Folder, Color3.fromRGB(34, 32, 46), ButtonDark, 90); local HeaderButton = Instance.new("TextButton"); HeaderButton.Size =
 UDim2.new(1, 0, 0, 38)
 local FolderIcons = {
 ["HALLOWEEN EVENT"] = "",
 ["REALM 1"] = "",
 ["FARM AREA"] = "",
 ["THANKSGIVING EVENT"] = "",
 ["TURKEY OOF UPGRADES"] = "",
 ["EVENT SCANNER"] = "",
 ["PLAYER TOOLS"] = "",
 ["DETECTORS"] = "",
 ["DETECTION & OBSERVATION"] = "",
 ["UNIVERSAL OBJECT SCANNER"] = "",
 ["UNIVERSAL INSTANCE INSPECTOR"] = "",
 ["UNIVERSAL STRUCTURE FINDER"] = "",
 ["NPC & TELEPORT"] = "",
 ["REMOTES"] = "",
 ["HOUSE TELEPORT"] = "",
 }
 local FolderIcon = ""
 HeaderButton.BackgroundTransparency = 1; HeaderButton.Text = name .. " +"; HeaderButton.TextColor3 = White
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
 HeaderButton.Text = FolderIcon .. " "
 .. name
 .. (Open and " -" or " +")
 UpdateSize()
 end)

 FolderLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
 if Open then
 UpdateSize()
 end
 end)
 return FolderContent
 end

 -- NOOB INCREMENTAL CODE REDEEMER (Place ID 76911729991355)
 if IsNoobIncrementalExperience then
 local CodeFolder = MakeFolder("CODE REDEEMER", GamePage)
 Label(CodeFolder, "Redeems the supplied codes through the game's own Shop UI.", 10, 30, Grey).TextWrapped = true
 local CodesToRedeem = {
 "THANKS4JOINING", "RELEASE", "LABUPDATE", "FOOTBALLEVENT",
 "500KGROUPMEMBERS!!!", "SPACEREALMISOUT!", "MASTERIESAREHERE!",
 "UNDERWATERISFINALLYHERE", "UPDATEFIX", "YINYANG",
 "ANOTHERMINIUPDATE", "FIXINGSTUFF", "SUMMONGHOULAXGOD",
 "ZEUSAPPEARED", "HAPPYHALLOWEEN!", "CHANGESSHUTDOWN",
 "HAPPYHALLOWEEN2!", "MINIUPDATEAGAIN", "SHUTDOWNSORRY",
 "HAPPYTHANKSGIVING", "HAPPYSHUTDOWN"
 }
 local CodeStatus = Label(CodeFolder, "READY: " .. tostring(#CodesToRedeem) .. " codes queued", 10, 28, Color3.fromRGB(170, 210, 255))
 CodeStatus.TextWrapped = true
 local CodeRunning = false
 local sharedEnv = _G
 if type(getgenv) == "function" then
 local envOk, env = pcall(getgenv)
 if envOk and type(env) == "table" then sharedEnv = env end
 end
 if type(sharedEnv.__SNH_NOOB_CODES_ATTEMPTED) ~= "table" then
 sharedEnv.__SNH_NOOB_CODES_ATTEMPTED = {}
 end
 local CodeAttempted = sharedEnv.__SNH_NOOB_CODES_ATTEMPTED

 local function FindCodeControls()
 local playerGui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
 local shop = playerGui and playerGui:FindFirstChild("Shop")
 local main = shop and shop:FindFirstChild("Main")
 local frame = main and main:FindFirstChild("Frame")
 local mainContent = frame and frame:FindFirstChild("MainContent")
 local shopContent = mainContent and mainContent:FindFirstChild("Shop")
 local scrolling = shopContent and shopContent:FindFirstChild("ScrollingFrame")
 local codesFrame = scrolling and scrolling:FindFirstChild("Codes")
 local redeemButton = codesFrame and codesFrame:FindFirstChild("Redeem", true)
 if not codesFrame or not redeemButton or not redeemButton:IsA("GuiButton") then
 return nil, nil, "Open the in-game Shop > Codes panel first."
 end
 local candidates = {}
 for _, descendant in ipairs(codesFrame:GetDescendants()) do
 if descendant:IsA("TextBox") and descendant.Visible then
 table.insert(candidates, descendant)
 end
 end
 table.sort(candidates, function(a, b)
 return a.AbsolutePosition.Y < b.AbsolutePosition.Y
 end)
 local codeBox = candidates[1]
 if not codeBox then
 return nil, nil, "Couldn't find the normal code input field."
 end
 return codeBox, redeemButton
 end

 local function RedeemOne(code)
 local codeBox, redeemButton, reason = FindCodeControls()
 if not codeBox then return false, reason end

 codeBox.Text = code
 task.wait(0.15)

 -- GuiButton has an Activated event, not an :Activate() method.
 -- Use the executor's signal firing API to invoke the game's own
 -- connected redemption handler without guessing its remote.
 local fired, fireError = false, nil
 if type(firesignal) == "function" then
 local ok, err = pcall(function()
 firesignal(redeemButton.Activated)
 end)
 fired = ok
 fireError = err
 if not fired then
 local clickOk, clickErr = pcall(function()
 firesignal(redeemButton.MouseButton1Click)
 end)
 fired = clickOk
 if not fired then fireError = clickErr or fireError end
 end
 end

 if not fired then
 return false, "This executor doesn't expose firesignal (needed to press the game's Redeem button)."
 .. (fireError and (" Details: " .. tostring(fireError)) or "")
 end

 CodeAttempted[code] = true
 return true
 end
 local function MakeCodeAction(text)
 local button = Instance.new("TextButton")
 button.Size = UDim2.new(1, 0, 0, 40)
 button.BackgroundColor3 = Color3.fromRGB(75, 55, 115)
 button.TextColor3 = White
 button.Text = text
 button.TextSize = 11
 button.Font = Enum.Font.GothamBold
 button.Parent = CodeFolder
 Corner(button, 9)
 Stroke(button, Border, 1)
 return button
 end

 local RedeemAllButton = MakeCodeAction("REDEEM ALL 21 CODES")
 local RetryButton = MakeCodeAction("RETRY CODES NOT ATTEMPTED THIS SESSION")
 RetryButton.BackgroundColor3 = ButtonDark

 local function RunCodeBatch(retryOnly)
 if CodeRunning then return end
 CodeRunning = true
 RedeemAllButton.Active = false
 RetryButton.Active = false
 local attemptedNow, skipped, failed = 0, 0, 0
 local lastError = nil

 local batchOk, batchError = xpcall(function()
 for index, code in ipairs(CodesToRedeem) do
 if retryOnly and CodeAttempted[code] then
 skipped = skipped + 1
 else
 CodeStatus.Text = "CHECKING SHOP UI — " .. code
 local ok, reason = RedeemOne(code)
 if ok then
 attemptedNow = attemptedNow + 1
 CodeStatus.Text = "SUBMITTED " .. tostring(index) .. "/" .. tostring(#CodesToRedeem) .. ": " .. code
 else
 failed = failed + 1
 lastError = tostring(reason or "Unknown redemption error")
 CodeStatus.Text = "FAILED: " .. code .. " | " .. lastError
 if lastError:find("Shop", 1, true) then break end
 end
 task.wait(1.25)
 end
 end
 end, function(err)
 return debug.traceback(tostring(err), 2)
 end)

 if not batchOk then
 lastError = tostring(batchError)
 end

 if not batchOk then
 CodeStatus.Text = "SCRIPT ERROR: " .. tostring(lastError):sub(1, 220)
 elseif failed > 0 then
 CodeStatus.Text = "DONE — submitted: " .. attemptedNow .. " | failed: " .. failed .. " | last: " .. tostring(lastError):sub(1, 160)
 else
 CodeStatus.Text = "DONE — submitted: " .. attemptedNow .. " | skipped: " .. skipped .. " | errors: 0"
 end

 RedeemAllButton.Active = true
 RetryButton.Active = true
 CodeRunning = false
 end
 RedeemAllButton.Activated:Connect(function()
 task.spawn(function() RunCodeBatch(false) end)
 end)
 RetryButton.Activated:Connect(function()
 task.spawn(function() RunCodeBatch(true) end)
 end)
 end

 if OwnerViewButton then
 OwnerViewButton.Activated:Connect(function()
 if not IsCreator then return end
 OwnerViewEnabled = not OwnerViewEnabled
 OwnerViewButton.Text = OwnerViewEnabled and "OWN" or "USER"
 OwnerViewButton.BackgroundColor3 = ButtonDark
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
 DetectionPage.Visible = OwnerViewEnabled and CurrentPage == "Observer"
 end
 if not OwnerViewEnabled then
 if CurrentPage == "Players" or CurrentPage == "Observer" then
 SelectPage("Updates")
 end
 CommunityPanel.Visible = false
 end
 end)
 end

 -- INPUT BOXES
 function MakeBox(parent, label, value, callback)
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

 end
 -- BUTTONS + persisted toggle state (restored only when Auto-Load is enabled).
 local MakeButton
 local RestorePersistedToggleStates
 do
 local HttpService = game:GetService("HttpService")
 local ToggleStateFile = "ShortNameHub_ToggleStates.json"
 local ToggleStates = {}
 local ToggleButtons = {}
 local ToggleKeyCounts = {}
 local sharedEnvironment = _G
 if type(getgenv) == "function" then
 local ok, env = pcall(getgenv)
 if ok and type(env) == "table" then sharedEnvironment = env end
 end
 local AutoLoadRestoreEnabled = sharedEnvironment.__SHORTNAME_AUTOLOAD_ACTIVE == true
 if type(readfile) == "function" and type(isfile) == "function" then
 local ok, exists = pcall(isfile, ToggleStateFile)
 if ok and exists then
 local readOk, raw = pcall(readfile, ToggleStateFile)
 if readOk and type(raw) == "string" then
 local decodeOk, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
 if decodeOk and type(decoded) == "table" then ToggleStates = decoded end
 end
 end
 end
 local function SaveToggleStates()
 if type(writefile) ~= "function" then return end
 local ok, encoded = pcall(function() return HttpService:JSONEncode(ToggleStates) end)
 if ok then pcall(writefile, ToggleStateFile, encoded) end
 end
 local function GetToggleKey(parent, initialText)
 local names = {}
 local node = parent
 while node and node ~= ScreenGui do
 table.insert(names, 1, tostring(node.Name))
 node = node.Parent
 end
 local base = tostring(game.PlaceId) .. "/" .. table.concat(names, "/") .. "/" .. tostring(initialText)
 ToggleKeyCounts[base] = (ToggleKeyCounts[base] or 0) + 1
 return base .. "#" .. tostring(ToggleKeyCounts[base])
 end
 local function ReadToggleState(button)
 local upper = tostring(button.Text or ""):upper()
 if upper:match("%f[%a]ON%f[%A]") or upper:match("%f[%a]STARTED?%f[%A]") then return true end
 if upper:match("%f[%a]OFF%f[%A]") or upper:match("%f[%a]STOPPED?%f[%A]") then return false end
 return nil
 end
 MakeButton = function(parent, text, callback, color)
 local b = Instance.new("TextButton"); b.Size = UDim2.new(1, 0, 0, 42); b.BackgroundColor3 = color or Color3.fromRGB(75, 55, 115)
 b.TextColor3 = White; b.Text = text; b.TextSize = 12
 b.Font = Enum.Font.GothamBold; b.Parent = parent; Corner(b, 10)
 Stroke(b, Border, 1); AddHover(b, color or Color3.fromRGB(75, 55, 115), Color3.fromRGB(94, 68, 137))
 local toggleKey = GetToggleKey(parent, text)
 local function Activate()
 callback()
 local state = ReadToggleState(b)
 if state ~= nil then
 ToggleStates[toggleKey] = state
 SaveToggleStates()
 end
 end
 b.Activated:Connect(Activate)
 local initialState = ReadToggleState(b)
 if initialState ~= nil then
 table.insert(ToggleButtons, {
 Button = b,
 Key = toggleKey,
 Activate = Activate,
 InitialState = initialState
 })
 end
 return b
 end
 RestorePersistedToggleStates = function()
 if not AutoLoadRestoreEnabled then return end
 for _, entry in ipairs(ToggleButtons) do
 local savedState = ToggleStates[entry.Key]
 if type(savedState) == "boolean" and savedState ~= entry.InitialState then
 pcall(entry.Activate)
 end
 end
 end
 end

 -- NOOB INCREMENTAL: REALM 1 > FARM AREA
 -- Actions are based on the owner's uploaded outgoing MainRemote observations.
 do
 local Realm1Folder = MakeFolder("REALM 1", GamePage)
 local FarmAreaFolder = MakeFolder("FARM AREA", Realm1Folder)
 Label(FarmAreaFolder, "Farm Area automation. Each enabled action repeats every 2 seconds.", 10, 30, Grey).TextWrapped = true

 local FarmStatus = Label(FarmAreaFolder, "FARM AREA: READY", 10, 24, Color3.fromRGB(170, 210, 255))
 FarmStatus.TextWrapped = true

 local FarmActions = {
 {Name = "UPGRADE CHICKEN", Args = {"UpgradeAnimal", "Chicken"}},
 {Name = "UPGRADE COW", Args = {"UpgradeAnimal", "Cow"}},
 {Name = "BUY CHICKEN", Args = {"BuyAnimal", "Chicken", true}},
 {Name = "BUY COW", Args = {"BuyAnimal", "Cow", true}},
 {Name = "BIGGER WHEAT DEPOSIT", Args = {"UpgradeUpgradeMax", "BiggerWheatDeposit", "Bread"}},
 {Name = "MORE BREAD CONSUMPTION", Args = {"UpgradeUpgradeMax", "MoreConsumption", "Bread"}},
 }

 local FarmRunning = {}
 local FarmButtons = {}
 local FarmStopped = false

 local function GetFarmRemote()
 local replicatedStorage = game:GetService("ReplicatedStorage")
 local netFolder = replicatedStorage:FindFirstChild("__Net")
 local remote = netFolder and netFolder:FindFirstChild("MainRemote")
 if remote and remote:IsA("RemoteEvent") then
 return remote
 end
 return nil
 end

 local function SetFarmButton(index, enabled)
 local button = FarmButtons[index]
 if not button then return end
 button.Text = (enabled and "ON | " or "OFF | ") .. FarmActions[index].Name
 button.BackgroundColor3 = enabled and Color3.fromRGB(45, 115, 75) or Color3.fromRGB(85, 55, 65)
 end

 local function SetFarmAction(index, enabled)
 local actionData = FarmActions[index]
 if not actionData or FarmStopped then return end
 FarmRunning[index] = enabled == true
 SetFarmButton(index, FarmRunning[index])
 if not enabled then
 FarmStatus.Text = "FARM AREA: " .. actionData.Name .. " STOPPED"
 return
 end
 FarmStatus.Text = "FARM AREA: " .. actionData.Name .. " RUNNING"
 task.spawn(function()
 while FarmRunning[index] and not FarmStopped do
 local remote = GetFarmRemote()
 if not remote then
 FarmStatus.Text = "FARM AREA: MainRemote not found; retrying..."
 else
 local ok, err = pcall(function()
 remote:FireServer(unpack(actionData.Args))
 end)
 if not ok then
 FarmRunning[index] = false
 SetFarmButton(index, false)
 FarmStatus.Text = "FARM AREA ERROR: " .. tostring(err):sub(1, 140)
 break
 end
 end
 task.wait(2)
 end
 end)
 end

 local function StopAllFarmActions()
 FarmStopped = true
 for index in ipairs(FarmActions) do
 FarmRunning[index] = false
 SetFarmButton(index, false)
 end
 FarmStatus.Text = "FARM AREA: ALL ACTIONS STOPPED"
 FarmStopped = false
 end

 local FarmToggleAllButton
 local function UpdateFarmToggleAllButton()
 local allEnabled = true
 for index in ipairs(FarmActions) do
 if not FarmRunning[index] then allEnabled = false break end
 end
 FarmToggleAllButton.Text = allEnabled and "TURN ALL FARM ACTIONS OFF" or "TURN ALL FARM ACTIONS ON"
 end

 FarmToggleAllButton = MakeButton(FarmAreaFolder, " TURN ALL FARM ACTIONS ON", function()
 local allEnabled = true
 for index in ipairs(FarmActions) do
 if not FarmRunning[index] then allEnabled = false break end
 end
 if allEnabled then
 StopAllFarmActions()
 else
 for index in ipairs(FarmActions) do
 if not FarmRunning[index] then SetFarmAction(index, true) end
 end
 FarmStatus.Text = "FARM AREA: ALL ACTIONS RUNNING"
 end
 UpdateFarmToggleAllButton()
 end, Color3.fromRGB(55, 95, 135))

 for index, action in ipairs(FarmActions) do
 local actionIndex = index
 FarmRunning[actionIndex] = false
 FarmButtons[actionIndex] = MakeButton(FarmAreaFolder, "OFF | " .. action.Name, function()
 if FarmStopped then return end
 SetFarmAction(actionIndex, not FarmRunning[actionIndex])
 UpdateFarmToggleAllButton()
 end)
 end

 MakeButton(FarmAreaFolder, "STOP ALL FARM ACTIONS", function()
 StopAllFarmActions()
 UpdateFarmToggleAllButton()
 end, Color3.fromRGB(115, 55, 65))
 end

 -- SNH THANKSGIVING EVENT AUTOMATION
 -- One milestone control, a separated Noob upgrade area, and one unified Turkey upgrade station.
 do -- Isolate locals for Luau's local-register limit.
 local ThanksgivingFolder = MakeFolder("THANKSGIVING EVENT", GamePage)
 local ThanksgivingDestroyed = false
 local function GetThanksgivingRemote()
 local replicatedStorage = game:GetService("ReplicatedStorage")
 local netFolder = replicatedStorage:FindFirstChild("__Net")
 local remote = netFolder and netFolder:FindFirstChild("MainRemote")
 if remote and remote:IsA("RemoteEvent") then
 return remote
 end
 return nil
 end

 Label(ThanksgivingFolder, "TURKEY OOF MILESTONE", 11, 25, PurpleLight).Font = Enum.Font.GothamBold
 Label(ThanksgivingFolder, "Milestone progression control.", 10, 24, Grey)
 local MilestoneStatus = Label(ThanksgivingFolder, "MILESTONE: READY", 10, 22, Color3.fromRGB(170, 210, 255))
 local MilestoneRunning = false
 local MilestoneToken = 0
 local MilestoneButton
 local function SetMilestone(enabled)
 MilestoneRunning = enabled
 MilestoneToken = MilestoneToken + 1
 local token = MilestoneToken
 MilestoneButton.Text = (enabled and "ON | " or "OFF | ") .. "TURKEY OOF MILESTONE"
 MilestoneButton.BackgroundColor3 = enabled and Color3.fromRGB(45, 115, 75) or Color3.fromRGB(85, 55, 65)
 if not enabled then
 MilestoneStatus.Text = "MILESTONE: STOPPED"
 return
 end
 task.spawn(function()
 while MilestoneRunning and MilestoneToken == token and not ThanksgivingDestroyed do
 local remote = GetThanksgivingRemote()
 if not remote then
 MilestoneStatus.Text = "MILESTONE: MainRemote not found; retrying"
 else
 local ok, err = pcall(function()
 remote:FireServer("TurkeyOofMilestoneUp")
 end)
 MilestoneStatus.Text = ok and "MILESTONE: REQUEST SENT" or ("MILESTONE ERROR: " .. tostring(err):sub(1, 100))
 end
 task.wait(2)
 end
 end)
 end
 MilestoneButton = MakeButton(ThanksgivingFolder, "OFF | TURKEY OOF MILESTONE", function()
 if not ThanksgivingDestroyed then SetMilestone(not MilestoneRunning) end
 end, Color3.fromRGB(85, 55, 65))

 Label(ThanksgivingFolder, "NOOB UPGRADES", 11, 25, PurpleLight).Font = Enum.Font.GothamBold
 Label(ThanksgivingFolder, "Noob upgrades are kept in their own section so more Noob upgrades can be added here later without mixing them into the Turkey upgrade list.", 10, 42, Grey).TextWrapped = true
 local NoobStatus = Label(ThanksgivingFolder, "NOOB UPGRADES: READY", 10, 22, Color3.fromRGB(170, 210, 255))
 local NoobUpgradeData = {
 { Name = "NOOB UPGRADE 1", Target = "TurkeyOof_Starter" },
 { Name = "NOOB UPGRADE 2", Target = "TurkeyOof_Second" },
 { Name = "NOOB UPGRADE 3", Target = "TurkeyOof_Third" }
 }
 local NoobRunning = {}
 local NoobTokens = {}
 local NoobButtons = {}

 local function SetNoobUpgrade(index, enabled)
 local data = NoobUpgradeData[index]
 if not data or ThanksgivingDestroyed then return end
 NoobTokens[index] = (NoobTokens[index] or 0) + 1
 local token = NoobTokens[index]
 NoobRunning[index] = enabled
 local button = NoobButtons[index]
 if button then
 button.Text = (enabled and "ON | " or "OFF | ") .. data.Name
 button.BackgroundColor3 = enabled and Color3.fromRGB(45, 115, 75) or Color3.fromRGB(85, 55, 65)
 end
 if not enabled then
 NoobStatus.Text = data.Name .. ": STOPPED"
 return
 end
 task.spawn(function()
 while NoobRunning[index] and NoobTokens[index] == token and not ThanksgivingDestroyed do
 local remote = GetThanksgivingRemote()
 if not remote then
 NoobStatus.Text = data.Name .. ": MainRemote not found; retrying"
 else
 local ok, err = pcall(function()
 remote:FireServer("UpgradeThanksgivingNoobMax", data.Target)
 end)
 NoobStatus.Text = ok and (data.Name .. ": REQUEST SENT") or ("NOOB UPGRADE ERROR: " .. tostring(err):sub(1, 100))
 end
 task.wait(2)
 end
 end)
 end

 for index, data in ipairs(NoobUpgradeData) do
 NoobRunning[index] = false
 NoobTokens[index] = 0
 local upgradeIndex = index
 NoobButtons[upgradeIndex] = MakeButton(ThanksgivingFolder, "OFF | " .. data.Name, function()
 if not ThanksgivingDestroyed then
 SetNoobUpgrade(upgradeIndex, not NoobRunning[upgradeIndex])
 end
 end, Color3.fromRGB(85, 55, 65))
 end

 Label(ThanksgivingFolder, "TURKEY UPGRADES", 11, 25, PurpleLight).Font = Enum.Font.GothamBold
 Label(ThanksgivingFolder, "All Turkey Oof upgrades are grouped here. Toggle All sends each upgrade request in sequence to avoid firing the entire list at once.", 10, 38, Grey).TextWrapped = true
 local TurkeyUpgradeStatus = Label(ThanksgivingFolder, "TURKEY UPGRADES: READY", 10, 24, Color3.fromRGB(170, 210, 255))
 TurkeyUpgradeStatus.TextWrapped = true

 -- Captured upgrade order, including the two upgrades that were previously outside Toggle All.
 local TurkeyUpgradeNames = {
 "MoreTurkeyOof",
 "MoreTurkeyOofII",
 "FasterThanksgivingNoobs",
 "MoreFeathers",
 "MoreTurkeyOofIII",
 "MoreFeathersII",
 "MoreTurkeyOofIV",
 "MoreFeathersIII",
 "MoreFeathersIV",
 "MoreFeathersV",
 "MoreFeathersVI",
 "MoreTurkeyOofV",
 "MoreFeathersVII",
 "MoreTurkeyOofVI"
 }
 local TurkeyUpgradeRunning = {}
 local TurkeyUpgradeButtons = {}
 local TurkeySchedulerRunning = false
 local TurkeySchedulerToken = 0
 local TurkeyDestroyed = false

 local function UpdateTurkeyButton(index)
 local button = TurkeyUpgradeButtons[index]
 if not button then return end
 local enabled = TurkeyUpgradeRunning[index] == true
 button.Text = (enabled and "ON | " or "OFF | ") .. string.upper(TurkeyUpgradeNames[index])
 button.BackgroundColor3 = enabled and Color3.fromRGB(45, 115, 75) or Color3.fromRGB(85, 55, 65)
 end

 local ToggleAllTurkeyButton
 local function UpdateToggleAllButton()
 local allEnabled = true
 for i = 1, #TurkeyUpgradeNames do
 if not TurkeyUpgradeRunning[i] then allEnabled = false break end
 end
 ToggleAllTurkeyButton.Text = allEnabled and "TURN ALL TURKEY UPGRADES OFF" or "TURN ALL TURKEY UPGRADES ON"
 end

 local function StartTurkeyScheduler()
 if TurkeySchedulerRunning then return end
 TurkeySchedulerRunning = true
 TurkeySchedulerToken = TurkeySchedulerToken + 1
 local schedulerToken = TurkeySchedulerToken
 task.spawn(function()
 while TurkeySchedulerRunning and TurkeySchedulerToken == schedulerToken and not TurkeyDestroyed and not ThanksgivingDestroyed do
 local sentAny = false
 for i = 1, #TurkeyUpgradeNames do
 if not TurkeySchedulerRunning or TurkeyDestroyed or ThanksgivingDestroyed then break end
 if TurkeyUpgradeRunning[i] then
 local remote = GetThanksgivingRemote()
 if not remote then
 TurkeyUpgradeStatus.Text = "TURKEY UPGRADES: MainRemote not found; retrying"
 else
 local upgradeName = TurkeyUpgradeNames[i]
 local ok, err = pcall(function()
 remote:FireServer("UpgradeUpgradeMax", "TurkeyOof", upgradeName)
 end)
 if ok then
 sentAny = true
 TurkeyUpgradeStatus.Text = "TURKEY UPGRADES: REQUEST SENT — " .. upgradeName
 else
 TurkeyUpgradeRunning[i] = false
 UpdateTurkeyButton(i)
 TurkeyUpgradeStatus.Text = "TURKEY UPGRADE ERROR (" .. upgradeName .. "): " .. tostring(err):sub(1, 90)
 end
 end
 task.wait(0.2)
 end
 end
 if not sentAny then
 local anyEnabled = false
 for i = 1, #TurkeyUpgradeNames do
 if TurkeyUpgradeRunning[i] then anyEnabled = true break end
 end
 if not anyEnabled then
 TurkeySchedulerRunning = false
 break
 end
 end
 task.wait(2)
 end
 if TurkeySchedulerToken == schedulerToken then
 TurkeySchedulerRunning = false
 end
 end)
 end

 local function SetTurkeyUpgradeEnabled(index, enabled)
 if not TurkeyUpgradeNames[index] or ThanksgivingDestroyed then return end
 TurkeyUpgradeRunning[index] = enabled == true
 UpdateTurkeyButton(index)
 local anyEnabled = false
 for i = 1, #TurkeyUpgradeNames do
 if TurkeyUpgradeRunning[i] then anyEnabled = true break end
 end
 if anyEnabled then
 StartTurkeyScheduler()
 TurkeyUpgradeStatus.Text = "TURKEY UPGRADES: RUNNING — sending requests in order"
 else
 TurkeyUpgradeStatus.Text = "TURKEY UPGRADES: ALL STOPPED"
 end
 UpdateToggleAllButton()
 end

 ToggleAllTurkeyButton = MakeButton(ThanksgivingFolder, " TURN ALL TURKEY UPGRADES ON", function()
 if ThanksgivingDestroyed then return end
 local allEnabled = true
 for i = 1, #TurkeyUpgradeNames do
 if not TurkeyUpgradeRunning[i] then allEnabled = false break end
 end
 local enableAll = not allEnabled
 for i = 1, #TurkeyUpgradeNames do
 TurkeyUpgradeRunning[i] = enableAll
 UpdateTurkeyButton(i)
 end
 UpdateToggleAllButton()
 if enableAll then
 TurkeyUpgradeStatus.Text = "TURKEY UPGRADES: ALL ENABLED — sending in sequence"
 StartTurkeyScheduler()
 else
 TurkeyUpgradeStatus.Text = "TURKEY UPGRADES: ALL STOPPED"
 end
 end, Color3.fromRGB(55, 95, 135))

 for index, upgradeName in ipairs(TurkeyUpgradeNames) do
 TurkeyUpgradeRunning[index] = false
 local upgradeIndex = index
 TurkeyUpgradeButtons[upgradeIndex] = MakeButton(ThanksgivingFolder, "OFF | " .. string.upper(upgradeName), function()
 if ThanksgivingDestroyed then return end
 SetTurkeyUpgradeEnabled(upgradeIndex, not TurkeyUpgradeRunning[upgradeIndex])
 end, Color3.fromRGB(85, 55, 65))
 end

 MakeButton(ThanksgivingFolder, "STOP ALL TURKEY UPGRADES", function()
 for i = 1, #TurkeyUpgradeNames do
 TurkeyUpgradeRunning[i] = false
 UpdateTurkeyButton(i)
 end
 TurkeySchedulerRunning = false
 TurkeySchedulerToken = TurkeySchedulerToken + 1
 UpdateToggleAllButton()
 TurkeyUpgradeStatus.Text = "TURKEY UPGRADES: ALL STOPPED"
 end, Color3.fromRGB(115, 55, 65))

 -- One master control for every repeating MainRemote action in Thanksgiving Event.
 local ThanksgivingToggleAllButton
 local function StopAllThanksgivingActions()
 SetMilestone(false)
 for i = 1, #NoobUpgradeData do
 SetNoobUpgrade(i, false)
 end
 for i = 1, #TurkeyUpgradeNames do
 TurkeyUpgradeRunning[i] = false
 UpdateTurkeyButton(i)
 end
 TurkeySchedulerRunning = false
 TurkeySchedulerToken = TurkeySchedulerToken + 1
 UpdateToggleAllButton()
 TurkeyUpgradeStatus.Text = "TURKEY UPGRADES: ALL STOPPED"
 end

 local function UpdateThanksgivingToggleAllButton()
 local allEnabled = MilestoneRunning
 for i = 1, #NoobUpgradeData do
 if not NoobRunning[i] then allEnabled = false break end
 end
 if allEnabled then
 for i = 1, #TurkeyUpgradeNames do
 if not TurkeyUpgradeRunning[i] then allEnabled = false break end
 end
 end
 ThanksgivingToggleAllButton.Text = allEnabled and "TURN ALL THANKSGIVING ACTIONS OFF" or "TURN ALL THANKSGIVING ACTIONS ON"
 end

 ThanksgivingToggleAllButton = MakeButton(ThanksgivingFolder, " TURN ALL THANKSGIVING ACTIONS ON", function()
 if ThanksgivingDestroyed then return end
 local allEnabled = MilestoneRunning
 for i = 1, #NoobUpgradeData do
 if not NoobRunning[i] then allEnabled = false break end
 end
 if allEnabled then
 for i = 1, #TurkeyUpgradeNames do
 if not TurkeyUpgradeRunning[i] then allEnabled = false break end
 end
 end
 if allEnabled then
 StopAllThanksgivingActions()
 else
 SetMilestone(true)
 for i = 1, #NoobUpgradeData do
 if not NoobRunning[i] then SetNoobUpgrade(i, true) end
 end
 for i = 1, #TurkeyUpgradeNames do
 TurkeyUpgradeRunning[i] = true
 UpdateTurkeyButton(i)
 end
 StartTurkeyScheduler()
 TurkeyUpgradeStatus.Text = "TURKEY UPGRADES: ALL ENABLED — sending in sequence"
 end
 UpdateThanksgivingToggleAllButton()
 end, Color3.fromRGB(55, 95, 135))

 ScreenGui.Destroying:Connect(function()
 ThanksgivingDestroyed = true
 TurkeyDestroyed = true
 TurkeySchedulerRunning = false
 TurkeySchedulerToken = TurkeySchedulerToken + 1
 MilestoneRunning = false
 NoobRunning = false
 end)
 end

 -- GUESS THE SLAPPER: retain only the feature that estimates who hit the local player.
 if GUI.GuessSlapperNav then
 local PlayersService = game:GetService("Players")
 local detectorContent = MakeFolder("WHO SLAPPED ME", GUI.GuessSlapperPage)
 local identificationTitle = Label(detectorContent, "WHO SLAPPED ME", 13, 22, PurpleLight)
 identificationTitle.Font = Enum.Font.GothamBold
 local identificationInfo = Label(detectorContent, "Estimates who hit you using visible health, knockback, animation, and nearby-player signals. Results are not server-confirmed.", 10, 28, Grey)
 identificationInfo.TextWrapped = true
 identificationInfo.Size = UDim2.new(1, 0, 0, 58)

 local detectorStatus = Label(detectorContent, "DETECTOR: STOPPED", 11, 24, Color3.fromRGB(235, 175, 125))
 detectorStatus.Font = Enum.Font.GothamBold
 local detectorSummary = Label(detectorContent, "Waiting for player activity.", 10, 22, Grey)
 detectorSummary.TextWrapped = true
 local lastDetection = Label(detectorContent, "No activity detected yet.", 12, 28, White)
 lastDetection.TextWrapped = true
 local historyLabel = Label(detectorContent, "Recent usernames will appear here.", 10, 80, Grey)
 historyLabel.TextWrapped = true
 historyLabel.TextYAlignment = Enum.TextYAlignment.Top

 local detectorRunning = false
 local detectorConnections = {}
 local characterConnections = {}
 local recentActions = {}
 local detectorHistory = {}
 local lastRootVelocity = {}

 -- Compact, read-only activity panel. It does not alter game mechanics.
 local miniPanel = Instance.new("Frame")
 miniPanel.Name = "PlayerActivityMiniPanel"
 miniPanel.Size = UDim2.fromOffset(248, 112)
 miniPanel.Position = UDim2.new(1, -264, 0, 92)
 miniPanel.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
 miniPanel.BackgroundTransparency = 0.08
 miniPanel.BorderSizePixel = 0
 miniPanel.Visible = false
 miniPanel.ZIndex = 40
 miniPanel.Parent = ScreenGui
 local miniCorner = Instance.new("UICorner")
 miniCorner.CornerRadius = UDim.new(0, 10)
 miniCorner.Parent = miniPanel
 local miniStroke = Instance.new("UIStroke")
 miniStroke.Color = PurpleLight
 miniStroke.Transparency = 0.25
 miniStroke.Thickness = 1
 miniStroke.Parent = miniPanel
 local miniTitle = Instance.new("TextLabel")
 miniTitle.BackgroundTransparency = 1
 miniTitle.Position = UDim2.fromOffset(12, 7)
 miniTitle.Size = UDim2.new(1, -48, 0, 22)
 miniTitle.Font = Enum.Font.GothamBold
 miniTitle.Text = "WHO SLAPPED ME"
 miniTitle.TextColor3 = White
 miniTitle.TextSize = 12
 miniTitle.TextXAlignment = Enum.TextXAlignment.Left
 miniTitle.ZIndex = 41
 miniTitle.Parent = miniPanel
 local miniClose = Instance.new("TextButton")
 miniClose.BackgroundTransparency = 1
 miniClose.Position = UDim2.new(1, -32, 0, 4)
 miniClose.Size = UDim2.fromOffset(26, 26)
 miniClose.Font = Enum.Font.GothamBold
 miniClose.Text = "×"
 miniClose.TextColor3 = Grey
 miniClose.TextSize = 20
 miniClose.ZIndex = 42
 miniClose.Parent = miniPanel
 local miniStatus = Instance.new("TextLabel")
 miniStatus.BackgroundTransparency = 1
 miniStatus.Position = UDim2.fromOffset(12, 34)
 miniStatus.Size = UDim2.new(1, -24, 0, 18)
 miniStatus.Font = Enum.Font.GothamBold
 miniStatus.Text = "STOPPED"
 miniStatus.TextColor3 = Color3.fromRGB(235, 175, 125)
 miniStatus.TextSize = 10
 miniStatus.TextXAlignment = Enum.TextXAlignment.Left
 miniStatus.ZIndex = 41
 miniStatus.Parent = miniPanel
 local miniResult = Instance.new("TextLabel")
 miniResult.BackgroundTransparency = 1
 miniResult.Position = UDim2.fromOffset(12, 56)
 miniResult.Size = UDim2.new(1, -24, 0, 42)
 miniResult.Font = Enum.Font.Gotham
 miniResult.Text = "Waiting for player activity."
 miniResult.TextColor3 = Grey
 miniResult.TextSize = 11
 miniResult.TextWrapped = true
 miniResult.TextXAlignment = Enum.TextXAlignment.Left
 miniResult.TextYAlignment = Enum.TextYAlignment.Top
 miniResult.ZIndex = 41
 miniResult.Parent = miniPanel
 -- Drag the floating detector by its title; supports mouse and touch.
 local miniDragging = false
 local miniDragInput = nil
 local miniDragStart = nil
 local miniStartPosition = nil
 miniTitle.Active = true
 miniTitle.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1
 or input.UserInputType == Enum.UserInputType.Touch then
 miniDragging = true
 miniDragInput = input
 miniDragStart = input.Position
 miniStartPosition = miniPanel.Position
 input.Changed:Connect(function()
 if input.UserInputState == Enum.UserInputState.End then
 miniDragging = false
 miniDragInput = nil
 end
 end)
 end
 end)
 UIS.InputChanged:Connect(function(input)
 if miniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
 or input.UserInputType == Enum.UserInputType.Touch) then
 local delta = input.Position - miniDragStart
 miniPanel.Position = UDim2.new(
 miniStartPosition.X.Scale,
 miniStartPosition.X.Offset + delta.X,
 miniStartPosition.Y.Scale,
 miniStartPosition.Y.Offset + delta.Y
 )
 end
 end)
 miniClose.Activated:Connect(function()
 miniPanel.Visible = false
 end)
 local function setMiniDetectorState(running)
 miniPanel.Visible = running
 miniStatus.Text = running and "LISTENING FOR HITS ON YOU" or "STOPPED"
 miniStatus.TextColor3 = running and Color3.fromRGB(130, 220, 165) or Color3.fromRGB(235, 175, 125)
 end
 local showMiniButton
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
 table.insert(lines, item.result)
 end
 historyLabel.Text = table.concat(lines, "\n")
 end
 local function detectImpact(victim, signal, severity)
 if not detectorRunning or victim ~= PlayersService.LocalPlayer then return end
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
 result = "@" .. best.player.Name
 else
 result = "Unknown"
 end
 local entry = {
 time = os.time(),
 result = result,
 victim = victim.Name,
 signal = signal
 }
 table.insert(detectorHistory, entry)
 while #detectorHistory > 12 do table.remove(detectorHistory, 1) end
 lastDetection.Text = "SLAPPER: " .. entry.result
 lastDetection.TextColor3 = color
 miniResult.Text = "LAST HIT: @" .. tostring(entry.result)
 miniResult.TextColor3 = color
 detectorSummary.Text = "Hit detected"
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
 setMiniDetectorState(false)
 end
 local detectorButton
 detectorButton = MakeButton(detectorContent, "START SLAP DETECTOR", function()
 if detectorRunning then
 stopSlapDetector()
 detectorButton.Text = "START SLAP DETECTOR"
 return
 end
 detectorRunning = true
 setMiniDetectorState(true)
 detectorStatus.Text = "DETECTOR: LISTENING"
 detectorStatus.TextColor3 = Color3.fromRGB(130, 220, 165)
 detectorSummary.Text = "Listening for hits on you..."
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
 showMiniButton = MakeButton(detectorContent, "SHOW MINI DETECTOR", function()
 miniPanel.Visible = not miniPanel.Visible
 end, Color3.fromRGB(75, 85, 115))
 MakeButton(detectorContent, "CLEAR HISTORY", function()
 table.clear(detectorHistory)
 lastDetection.Text = "No activity detected yet."
 lastDetection.TextColor3 = White
 renderHistory()
 end, Color3.fromRGB(75, 75, 95))
 local detectorDisclaimer = Label(detectorContent, "Names are estimates from client-visible signals, not server-confirmed attacker IDs.", 9, 30, Grey)
 detectorDisclaimer.TextWrapped = true
 detectorDisclaimer.Size = UDim2.new(1, 0, 0, 30)
 GUI.StopSlapDetector = stopSlapDetector

 end
 -- CREATOR-ONLY PLAYER ROSTER.
 if PlayerAdminUI.Page then
 task.spawn(function()
 Label(PlayerAdminUI.Page, "COMMUNITY PLAYERS", 16, 28).Font = Enum.Font.GothamBold
 Label(PlayerAdminUI.Page, "Registered hub users. Online status expires after 90 seconds without a heartbeat. Executor names are client-reported.", 10, 42, Grey).TextWrapped = true
 local sharedEnv = _G
 pcall(function() if type(getgenv) == "function" then sharedEnv = getgenv() end end)
 local OwnerSession = type(sharedEnv.__SHORTNAME_OWNER_SESSION) == "string" and sharedEnv.__SHORTNAME_OWNER_SESSION or ""
 local OwnerSecret = ""
 local RefreshRoster
 local RosterStatus = Label(PlayerAdminUI.Page, OwnerSession ~= "" and "OWNER SESSION: CACHED (MAY EXPIRE)" or "OWNER SESSION: NOT VERIFIED", 10, 24, Grey)
 Label(PlayerAdminUI.Page, "OWNER SIGN-IN: enter the Worker OWNER_SECRET you configured. It is sent only to the HTTPS Worker endpoint; never paste it into chat or GitHub.", 10, 48, Grey).TextWrapped = true
 local KeyBox = MakeBox(PlayerAdminUI.Page, "OWNER SECRET", "", function(value)
 OwnerSecret = tostring(value or "")
 end)
 KeyBox.PlaceholderText = "Enter your OWNER_SECRET"
 MakeButton(PlayerAdminUI.Page, "VERIFY OWNER SESSION", function()
 if OwnerSecret == "" then RosterStatus.Text = "ENTER YOUR OWNER SECRET FIRST" return end
 RosterStatus.Text = "VERIFYING OWNER ACCESS..."
 task.spawn(function()
 local submittedSecret = OwnerSecret
 local ok, sent, result = pcall(function() return PresenceModule.LoginOwner(submittedSecret) end)
 OwnerSecret = ""
 KeyBox.Text = ""
 if ok and sent and type(result) == "table" and type(result.session) == "string" then
 OwnerSession = result.session
 sharedEnv.__SHORTNAME_OWNER_SESSION = OwnerSession
 RosterStatus.Text = "OWNER SESSION VERIFIED — EXPIRES IN 30 MINUTES"
 RefreshRoster()
 else
 RosterStatus.Text = "OWNER VERIFICATION FAILED: " .. tostring(ok and result or sent)
 end
 end)
 end, Color3.fromRGB(55, 100, 85))
 local SearchBox = MakeBox(PlayerAdminUI.Page, "SEARCH USERNAME OR USER ID", "", function() end)
 SearchBox.PlaceholderText = "Type a username or Roblox user ID..."
 local cachedPlayers = {}
 local cachedBans = {}
 local activeRosterFilter = "All Members"
 local function ClearRosterRows()
 for _, child in ipairs(PlayerAdminUI.Page:GetChildren()) do
 if child.Name == "PresencePlayerRow" then child:Destroy() end
 end
 end
 local function RenderRoster()
 ClearRosterRows()
 local query = tostring(SearchBox.Text or ""):lower():gsub("^%s*(.-)%s*$", "%1")
 local shown = 0
 local bannedIds = {}
 for _, banData in ipairs(cachedBans) do bannedIds[tostring(banData.userId)] = true end
 for _, playerData in ipairs(cachedPlayers) do
 local username = tostring(playerData.username or "")
 local userIdText = tostring(playerData.userId or "")
 local rank = tostring(playerData.rank or "Member")
 local categoryMatch = activeRosterFilter == "All Members"
 or (activeRosterFilter == "Premium Users" and rank == "Premium")
 or (activeRosterFilter == "Staff" and rank == "Staff")
 or (activeRosterFilter == "Banned Users" and bannedIds[userIdText] == true)
 if categoryMatch and (query == "" or username:lower():find(query, 1, true) or userIdText:find(query, 1, true)) then
 shown += 1
 local row = Instance.new("Frame")
 row.Name = "PresencePlayerRow"
 row.Size = UDim2.new(1, 0, 0, 104)
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
 details.Size = UDim2.new(1, -150, 1, -10)
 details.TextXAlignment = Enum.TextXAlignment.Left
 details.TextYAlignment = Enum.TextYAlignment.Center
 details.TextWrapped = true
 details.Font = Enum.Font.Gotham
 details.TextSize = 9
 details.TextColor3 = online and Color3.fromRGB(130, 230, 165) or Grey
 details.Text = tostring(playerData.displayName or username) .. " (@" .. username .. ")\nUSER ID: " .. userIdText .. "\n" .. seenText .. "\nEXECUTOR (REPORTED): " .. tostring(playerData.executor or "Unknown / unavailable") .. "\nRANK: " .. tostring(playerData.rank or "Member")
 details.Parent = row
 local rankOptions = { { "MEM", "Member", 0 }, { "PREM", "Premium", 1 }, { "STAFF", "Staff", 2 } }
 for _, option in ipairs(rankOptions) do
 local selectedRank = option[2]
 local button = Instance.new("TextButton")
 button.Size = UDim2.fromOffset(40, 22)
 button.Position = UDim2.new(1, -134 + option[3] * 44, 0, 12)
 button.BackgroundColor3 = playerData.rank == selectedRank and CurrentAccent.Active or Color3.fromRGB(48, 45, 60)
 button.Text = option[1]
 button.TextColor3 = White
 button.TextSize = 8
 button.Font = Enum.Font.GothamBold
 button.Parent = row
 Corner(button, 5)
 button.Activated:Connect(function()
 local saved, response, message = pcall(function() return PresenceModule.SetRank(OwnerSession, playerData.userId, selectedRank) end)
 if saved and response then
 playerData.rank = selectedRank
 RosterStatus.Text = "SAVED RANK: @" .. username .. " -> " .. selectedRank
 RenderRoster()
 else
 RosterStatus.Text = "RANK UPDATE FAILED: " .. tostring(saved and message or response)
 end
 end)
 end
 local banOptions = { { "1 DAY", "1d", 0 }, { "30 DAY", "30d", 1 }, { "PERM", "permanent", 2 } }
 for _, option in ipairs(banOptions) do
 local duration = option[2]
 local button = Instance.new("TextButton")
 button.Size = UDim2.fromOffset(40, 22)
 button.Position = UDim2.new(1, -134 + option[3] * 44, 0, 57)
 button.BackgroundColor3 = Color3.fromRGB(105, 48, 58)
 button.Text = option[1]
 button.TextColor3 = White
 button.TextSize = 8
 button.Font = Enum.Font.GothamBold
 button.Parent = row
 Corner(button, 5)
 button.Activated:Connect(function()
 local saved, response, message = pcall(function() return PresenceModule.SetBan(OwnerSession, playerData.userId, duration) end)
 if saved and response then
 RosterStatus.Text = "HUB BAN APPLIED: @" .. username .. " (" .. option[1] .. ")"
 else
 RosterStatus.Text = "BAN FAILED: " .. tostring(saved and message or response)
 end
 end)
 end
 end
 end
 RosterStatus.Text = "ROSTER: " .. tostring(#cachedPlayers) .. " REGISTERED USERS • SHOWING " .. tostring(shown)
 end
 SearchBox:GetPropertyChangedSignal("Text"):Connect(RenderRoster)
 RefreshRoster = function()
 if not IsCreator then return end
 if not PresenceModule or type(PresenceModule.GetPlayers) ~= "function" then
 RosterStatus.Text = "ROSTER: PRESENCE MODULE UNAVAILABLE"
 return
 end
 if OwnerSession == "" then
 RosterStatus.Text = "ROSTER: ENTER OWNER SESSION"
 return
 end
 RosterStatus.Text = "ROSTER: LOADING..."
 local ok, sent, result = pcall(function() return PresenceModule.GetPlayers(OwnerSession) end)
 if not ok or not sent then
 RosterStatus.Text = "ROSTER: " .. tostring(ok and result or sent)
 return
 end
 cachedPlayers = type(result) == "table" and result.players or {}
 if PresenceModule and type(PresenceModule.GetBans) == "function" then
 local bansOk, bansSent, bansResult = pcall(function() return PresenceModule.GetBans(OwnerSession) end)
 if bansOk and bansSent and type(bansResult) == "table" then
 cachedBans = bansResult.bans or {}
 end
 end
 RenderRoster()
 end
 local filterButtons = {
 { "ALL MEMBERS", "All Members" },
 { "PREMIUM", "Premium Users" },
 { "STAFF", "Staff" },
 { "BANNED", "Banned Users" }
 }
 for _, filter in ipairs(filterButtons) do
 local label, value = filter[1], filter[2]
 MakeButton(PlayerAdminUI.Page, label, function()
 activeRosterFilter = value
 RenderRoster()
 end, Color3.fromRGB(65, 58, 92))
 end
 local SecurityReportStatus = Label(PlayerAdminUI.Page, "SECURITY REPORTS: NOT LOADED", 9, 78, Grey)
 SecurityReportStatus.TextWrapped = true
 MakeButton(PlayerAdminUI.Page, "LOAD SECURITY REPORTS", function()
 if not PresenceModule or type(PresenceModule.GetSecurityEvents) ~= "function" then
 SecurityReportStatus.Text = "SECURITY REPORTS: MODULE UNAVAILABLE"
 return
 end
 SecurityReportStatus.Text = "SECURITY REPORTS: LOADING..."
 task.spawn(function()
 local ok, sent, result = pcall(function() return PresenceModule.GetSecurityEvents(OwnerSession) end)
 if not ok or not sent or type(result) ~= "table" then
 SecurityReportStatus.Text = "SECURITY REPORTS: " .. tostring(ok and result or sent)
 return
 end
 local events = result.events or {}
 local lines = { "SECURITY REPORTS: " .. tostring(#events) .. " EVENTS (LATEST 8)" }
 for index = 1, math.min(#events, 8) do
 local event = events[index]
 table.insert(lines, tostring(event.eventType or "event") .. " | " .. tostring(event.createdAt or "time unknown"))
 table.insert(lines, "USER: " .. tostring(event.username or "Unknown") .. " / " .. tostring(event.userId or "unverified"))
 table.insert(lines, tostring(event.details or "No details"))
 end
 SecurityReportStatus.Text = table.concat(lines, "\\n")
 end)
 end, Color3.fromRGB(105, 70, 105))
 MakeButton(PlayerAdminUI.Page, "LOAD / REFRESH ALL REGISTERED USERS", RefreshRoster, Color3.fromRGB(55, 85, 125))
 task.spawn(function()
 while ScreenGui.Parent do
 task.wait(60)
 if PlayerAdminUI.Page.Visible and OwnerSession ~= "" then RefreshRoster() end
 end
 end)
 if OwnerSession ~= "" then task.defer(RefreshRoster) end
 end)
 end

 -- HALLOWEEN EVENT FOLDER
 local HalloweenFolder = MakeFolder("HALLOWEEN EVENT")

  do -- section scope: keeps Luau local-register usage below the 200-local limit
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
 if LiveObserver and type(LiveObserver.Stop) == "function" then
 pcall(function() LiveObserver:Stop() end)
 end
 StopAutoReset()
 StopPlayerTracker()
 if TeleportTargetRemovingConnection then
 TeleportTargetRemovingConnection:Disconnect()
 TeleportTargetRemovingConnection = nil
 end
 end)
 end

 -- OWNER-ONLY OBSERVER TAB: one top-level page, no nested detector folders.
 local HubToggleConnection, HubExtras, RunService
 do -- section scope: keep Observer locals from exhausting GUI.Create register limits
 if DetectionPage then
 Label(DetectionPage, "OBSERVER CONSOLE", 17, 30).Font = Enum.Font.GothamBold
 Label(DetectionPage, "A single control center for passive client-side detectors. Choose one detector or ALL, review captured reports, then upload them to the private report inbox.", 10, 42, Grey).TextWrapped = true

 local Console = DetectionPage
 local consoleStatus = Label(Console, "STATUS: READY", 11, 23, Color3.fromRGB(170, 210, 255))
 consoleStatus.Font = Enum.Font.GothamBold
 local consoleStats = Label(Console, "CAPTURED: 0  |  REPORTS: 0/5", 10, 22, Grey)

 local detectorOptions = {"ALL", "Remote Calls", "Live Changes", "Object Scanner", "Instance Inspector", "Structure Finder"}
 local selectedDetector = "Remote Calls"
 local selector = Instance.new("TextButton")
 selector.Name = "DetectorSelector"
 selector.Size = UDim2.new(1, 0, 0, 38)
 selector.BackgroundColor3 = ButtonDark
 selector.TextColor3 = White
 selector.Text = "DETECTOR: " .. selectedDetector .. "  ▾"
 selector.TextSize = 11
 selector.Font = Enum.Font.GothamBold
 selector.Parent = Console
 Corner(selector, 5)
 Stroke(selector, Border, 1)

 local optionPanel = Instance.new("Frame")
 optionPanel.Size = UDim2.new(1, 0, 0, 0)
 optionPanel.BackgroundColor3 = Panel
 optionPanel.BorderSizePixel = 0
 optionPanel.ClipsDescendants = true
 optionPanel.Visible = false
 optionPanel.Parent = Console
 Corner(optionPanel, 5)
 local optionLayout = Instance.new("UIListLayout")
 optionLayout.Padding = UDim.new(0, 3)
 optionLayout.Parent = optionPanel
 for _, name in ipairs(detectorOptions) do
 local option = Instance.new("TextButton")
 option.Size = UDim2.new(1, 0, 0, 30)
 option.BackgroundColor3 = name == "ALL" and Color3.fromRGB(45, 75, 110) or ButtonDark
 option.TextColor3 = White
 option.Text = name == "ALL" and "ALL — START EVERY DETECTOR" or name
 option.TextSize = 10
 option.Font = Enum.Font.GothamMedium
 option.Parent = optionPanel
 Corner(option, 4)
 option.Activated:Connect(function()
 selectedDetector = name
 selector.Text = "DETECTOR: " .. name .. "  ▾"
 optionPanel.Visible = false
 optionPanel.Size = UDim2.new(1, 0, 0, 0)
 end)
 end
 optionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
 if optionPanel.Visible then
 optionPanel.Size = UDim2.new(1, 0, 0, optionLayout.AbsoluteContentSize.Y + 4)
 end
 end)
 selector.Activated:Connect(function()
 local open = not optionPanel.Visible
 optionPanel.Visible = open
 optionPanel.Size = UDim2.new(1, 0, 0, open and (optionLayout.AbsoluteContentSize.Y + 4) or 0)
 selector.Text = "DETECTOR: " .. selectedDetector .. (open and "  ▴" or "  ▾")
 end)

 local filterBox = Instance.new("TextBox")
 filterBox.Name = "LogFilter"
 filterBox.Size = UDim2.new(1, 0, 0, 32)
 filterBox.BackgroundColor3 = ButtonDark
 filterBox.TextColor3 = White
 filterBox.PlaceholderColor3 = Grey
 filterBox.PlaceholderText = "Filter logs by detector or text..."
 filterBox.Text = ""
 filterBox.TextSize = 10
 filterBox.Font = Enum.Font.Gotham
 filterBox.ClearTextOnFocus = false
 filterBox.Parent = Console
 Corner(filterBox, 5)
 Stroke(filterBox, Border, 1)

 local logBox = Instance.new("TextBox")
 logBox.Name = "ObserverLog"
 logBox.Size = UDim2.new(1, 0, 0, 245)
 logBox.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
 logBox.TextColor3 = Color3.fromRGB(225, 225, 225)
 logBox.PlaceholderColor3 = Grey
 logBox.PlaceholderText = "Logs will appear here..."
 logBox.Text = ""
 logBox.TextSize = 10
 logBox.Font = Enum.Font.Code
 logBox.TextXAlignment = Enum.TextXAlignment.Left
 logBox.TextYAlignment = Enum.TextYAlignment.Top
 logBox.TextWrapped = false
 logBox.MultiLine = true
 logBox.ClearTextOnFocus = false
 logBox.TextEditable = false
 logBox.Parent = Console
 Corner(logBox, 5)
 Stroke(logBox, Border, 1)

 local consolePaused = false
 local consoleActive = false
 local consoleBuffer = {}
 local consoleFilter = ""
 local function renderConsole()
 local visible = {}
 for _, line in ipairs(consoleBuffer) do
 if consoleFilter == "" or string.find(string.lower(line), consoleFilter, 1, true) then
 table.insert(visible, line)
 end
 end
 logBox.Text = #visible > 0 and table.concat(visible, "\n") or "[OBSERVER] No entries match this filter."
 logBox.CursorPosition = #logBox.Text + 1
 end
 local function setConsoleText(value)
 table.clear(consoleBuffer)
 for line in tostring(value or ""):gmatch("[^\n]+") do
 table.insert(consoleBuffer, line)
 if #consoleBuffer > 2000 then table.remove(consoleBuffer, 1) end
 end
 renderConsole()
 end
 filterBox:GetPropertyChangedSignal("Text"):Connect(function()
 consoleFilter = string.lower(tostring(filterBox.Text or ""))
 renderConsole()
 end)
 local function appendConsole(line)
 if consolePaused then return end
 table.insert(consoleBuffer, os.date("[%H:%M:%S] ") .. tostring(line))
 while #consoleBuffer > 2000 do table.remove(consoleBuffer, 1) end
 renderConsole()
 end

 local function getReport(moduleRef, methodName)
 if not moduleRef then return nil end
 local ok, result = pcall(function() return moduleRef[methodName](moduleRef) end)
 if ok and type(result) == "string" and result ~= "" then return result end
 return nil
 end
 local function buildCombinedReport()
 local sections = {}
 local reportCount = 0
 local function addSection(title, moduleRef)
 local report = getReport(moduleRef, "GetReport")
 if report then
 table.insert(sections, "========== " .. title .. " ==========\n" .. report)
 reportCount += 1
 end
 end
 table.insert(sections, "SHORTNAME HUB — OBSERVER CONSOLE")
 table.insert(sections, "Captured: " .. os.date("!%Y-%m-%d %H:%M:%S UTC"))
 table.insert(sections, "Game: " .. tostring(game.Name) .. " | PlaceId: " .. tostring(game.PlaceId) .. " | UniverseId: " .. tostring(game.GameId))
 table.insert(sections, "Player: " .. tostring(LocalPlayer and LocalPlayer.Name or "Unknown"))
 addSection("REMOTE CALLS", RemoteLogger)
 addSection("LIVE CHANGES", LiveObserver)
 addSection("OBJECT SCAN", ObjectScanner)
 addSection("INSTANCE INSPECTION", InstanceInspector)
 addSection("STRUCTURE FINDER", StructureScanner)
 return table.concat(sections, "\n\n"), reportCount
 end
 local function refreshConsole()
 local report, reportCount = buildCombinedReport()
 if report ~= "" then
 setConsoleText(report)
 elseif #consoleBuffer == 0 then
 setConsoleText("[OBSERVER] No report data yet. Start a detector and use the game normally.")
 end
 local captured = 0
 if RemoteLogger and type(RemoteLogger.GetStats) == "function" then
 local ok, stats = pcall(function() return RemoteLogger:GetStats() end)
 if ok and stats then captured += tonumber(stats.Total) or 0 end
 end
 if LiveObserver and type(LiveObserver.GetChangeCount) == "function" then
 local ok, count = pcall(function() return LiveObserver:GetChangeCount() end)
 if ok then captured += tonumber(count) or 0 end
 end
 consoleStats.Text = "CAPTURED: " .. tostring(captured) .. "  |  REPORTS: " .. tostring(reportCount) .. "/5"
 end

 local function startOne(name)
 consoleActive = true
 if name == "Remote Calls" then
 if RemoteLogger and type(RemoteLogger.Start) == "function" then
 local ok, success, message = pcall(function() return RemoteLogger:Start() end)
 appendConsole("[REMOTE_CALLS] " .. tostring(ok and (message or (success and "RUNNING" or "START FAILED")) or success))
 else appendConsole("[REMOTE_CALLS] MODULE NOT LOADED") end
 elseif name == "Live Changes" then
 if LiveObserver and type(LiveObserver.Start) == "function" then
 local ok, result = pcall(function()
 return LiveObserver:Start(function(status, watched, changes)
 consoleStatus.Text = "STATUS: " .. tostring(status)
 consoleStats.Text = "WATCHING: " .. tostring(watched or 0) .. "  |  CHANGES: " .. tostring(changes or 0)
 appendConsole("[LIVE_CHANGES] " .. tostring(status))
 end)
 end)
 appendConsole("[LIVE_CHANGES] " .. tostring(ok and result or result))
 else appendConsole("[LIVE_CHANGES] MODULE NOT LOADED") end
 elseif name == "Object Scanner" then
 if ObjectScanner and type(ObjectScanner.Start) == "function" then
 local ok, result = pcall(function()
 return ObjectScanner:Start(function(status, count)
 consoleStatus.Text = "STATUS: " .. tostring(status)
 consoleStats.Text = "OBJECT DISCOVERIES: " .. tostring(count or 0)
 if tostring(status):find("COMPLETE", 1, true) or tostring(status):find("LIMIT REACHED", 1, true) then task.defer(refreshConsole) end
 end)
 end)
 appendConsole("[OBJECT_SCANNER] " .. tostring(ok and result or result))
 else appendConsole("[OBJECT_SCANNER] MODULE NOT LOADED") end
 elseif name == "Instance Inspector" then
 if InstanceInspector and type(InstanceInspector.Inspect) == "function" then
 task.spawn(function()
 local ok, result, count = pcall(function()
 return InstanceInspector:Inspect(function(status, total)
 consoleStatus.Text = "STATUS: " .. tostring(status)
 consoleStats.Text = "OBJECTS INSPECTED: " .. tostring(total or 0)
 end)
 end)
 appendConsole("[INSTANCE_INSPECTOR] " .. tostring(ok and (result and ("COMPLETE (" .. tostring(count or 0) .. ")") or "FAILED") or result))
 refreshConsole()
 end)
 else appendConsole("[INSTANCE_INSPECTOR] MODULE NOT LOADED") end
 elseif name == "Structure Finder" then
 if StructureScanner and type(StructureScanner.Start) == "function" then
 local ok, result = pcall(function()
 return StructureScanner:Start(function(status, count)
 consoleStatus.Text = "STATUS: " .. tostring(status)
 consoleStats.Text = "STRUCTURE DISCOVERIES: " .. tostring(count or 0)
 if tostring(status):find("COMPLETE", 1, true) or tostring(status):find("LIMIT REACHED", 1, true) then task.defer(refreshConsole) end
 end)
 end)
 appendConsole("[STRUCTURE_FINDER] " .. tostring(ok and result or result))
 else appendConsole("[STRUCTURE_FINDER] MODULE NOT LOADED") end
 end
 refreshConsole()
 end
 local function startAll()
 consoleActive = true
 consoleStatus.Text = "STATUS: STARTING ALL DETECTORS"
 appendConsole("[ALL] Starting every available detector...")
 for _, name in ipairs(detectorOptions) do
 if name ~= "ALL" then startOne(name) end
 end
 consoleStatus.Text = "STATUS: ALL DETECTORS REQUESTED"
 appendConsole("[ALL] Start requests sent. One-time scans will complete; live observers remain active.")
 end

 MakeButton(Console, "START SELECTED DETECTOR", function()
 if selectedDetector == "ALL" then
 startAll()
 else
 startOne(selectedDetector)
 consoleStatus.Text = "STATUS: " .. selectedDetector:upper() .. " START REQUESTED"
 end
 end, Color3.fromRGB(45, 105, 75))
 MakeButton(Console, "ALL — START EVERY DETECTOR", startAll, Color3.fromRGB(65, 85, 125))
 MakeButton(Console, "STOP ALL LIVE DETECTORS", function()
 consoleActive = false
 if RemoteLogger and type(RemoteLogger.Stop) == "function" then pcall(function() RemoteLogger:Stop() end) end
 if LiveObserver and type(LiveObserver.Stop) == "function" then pcall(function() LiveObserver:Stop() end) end
 if ObjectScanner and type(ObjectScanner.Stop) == "function" then pcall(function() ObjectScanner:Stop() end) end
 if StructureScanner and type(StructureScanner.Stop) == "function" then pcall(function() StructureScanner:Stop() end) end
 consoleStatus.Text = "STATUS: STOPPED"
 appendConsole("[OBSERVER] Live detectors stopped. Completed reports remain available.")
 end, Color3.fromRGB(115, 65, 65))
 MakeButton(Console, "PAUSE / RESUME LOGGING", function()
 consolePaused = not consolePaused
 consoleStatus.Text = consolePaused and "STATUS: LOGGING PAUSED" or "STATUS: LOGGING RESUMED"
 if not consolePaused then appendConsole("[OBSERVER] Logging resumed.") end
 end, Color3.fromRGB(75, 75, 90))
 MakeButton(Console, "REFRESH LOG VIEW", refreshConsole, Color3.fromRGB(55, 65, 80))
 MakeButton(Console, "CLEAR LOGS", function()
 table.clear(consoleBuffer)
 logBox.Text = ""
 for _, moduleRef in ipairs({RemoteLogger, LiveObserver, ObjectScanner, InstanceInspector, StructureScanner}) do
 if moduleRef and type(moduleRef.Clear) == "function" then pcall(function() moduleRef:Clear() end) end
 end
 consoleStats.Text = "CAPTURED: 0  |  REPORTS: 0/5"
 consoleStatus.Text = "STATUS: LOGS CLEARED"
 end, Color3.fromRGB(75, 75, 75))
 MakeButton(Console, "COPY ALL LOGS", function()
 refreshConsole()
 local copied = false
 local allLogs = table.concat(consoleBuffer, "\n")
 if type(setclipboard) == "function" then copied = pcall(function() setclipboard(allLogs) end) end
 if not copied and type(toclipboard) == "function" then copied = pcall(function() toclipboard(allLogs) end) end
 consoleStatus.Text = copied and "STATUS: LOGS COPIED" or "STATUS: CLIPBOARD UNAVAILABLE"
 end, Color3.fromRGB(65, 90, 130))

 local uploadKey = tostring(UploadKeyCache.__SHORTNAME_UPLOAD_KEY or "")
 MakeBox(Console, "OWNER UPLOAD KEY (CACHED FOR THIS EXECUTOR SESSION)", uploadKey, function(value)
 uploadKey = tostring(value or "")
 UploadKeyCache.__SHORTNAME_UPLOAD_KEY = uploadKey
 end)
 MakeButton(Console, "UPLOAD OBSERVER REPORT", function()
 if uploadKey == "" then
 consoleStatus.Text = "STATUS: ENTER UPLOAD KEY FIRST"
 return
 end
 local requestFunction
 if type(request) == "function" then requestFunction = request
 elseif type(http_request) == "function" then requestFunction = http_request
 elseif syn and type(syn.request) == "function" then requestFunction = syn.request
 elseif http and type(http.request) == "function" then requestFunction = http.request
 elseif fluxus and type(fluxus.request) == "function" then requestFunction = fluxus.request
 end
 if not requestFunction then
 consoleStatus.Text = "STATUS: EXECUTOR HTTP REQUEST API UNAVAILABLE"
 return
 end
 consoleStatus.Text = "STATUS: UPLOADING OBSERVER REPORT..."
 task.spawn(function()
 local HttpService = game:GetService("HttpService")
 local report = buildCombinedReport()
 if #report < 20 then
 consoleStatus.Text = "STATUS: NO REPORT DATA TO UPLOAD"
 return
 end
 if #report > 99000 then
 report = string.sub(report, 1, 99000) .. "\n[REPORT TRUNCATED TO FIT THE 100 KB WORKER LIMIT]"
 end
 local sent, response = pcall(function()
 return requestFunction({
 Url = "https://shortname-report-receive.ryft-amv.workers.dev/upload",
 Method = "POST",
 Timeout = 45,
 Headers = {["Content-Type"] = "application/json", ["x-upload-key"] = uploadKey},
 Body = HttpService:JSONEncode({report = report})
 })
 end)
 local code = type(response) == "table" and (response.StatusCode or response.Status or response.status_code) or nil
 local body = type(response) == "table" and (response.Body or response.body or "") or tostring(response)
 local decodedOk, decoded = pcall(function() return HttpService:JSONDecode(body) end)
 if sent and code == 200 and decodedOk and type(decoded) == "table" and decoded.ok == true then
 consoleStatus.Text = "STATUS: UPLOAD CONFIRMED — SAVED TO GITHUB"
 appendConsole("[UPLOAD] Report saved to scanner-reports/latest.txt")
 else
 consoleStatus.Text = "STATUS: UPLOAD FAILED — HTTP " .. tostring(code) .. " — " .. tostring(body):sub(1, 90)
 end
 end)
 end, Color3.fromRGB(45, 105, 145))
 Label(Console, "READ-ONLY / CLIENT-SIDE: this console cannot see server-only activity or another player's private traffic. Remote logging records outgoing calls from this client only.", 9, 48, Grey).TextWrapped = true
 refreshConsole()
 task.spawn(function()
 while ScreenGui.Parent and DetectionPage.Parent do
 task.wait(2)
 if consoleActive and DetectionPage.Visible and not consolePaused then
 refreshConsole()
 end
 end
 end)
 end
 end -- Observer section scope

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
 HubToggleConnection = nil
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
 HubExtras = {}
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
 local entry = os.date("%H:%M:%S") .. " " .. tostring(message)
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

 do -- Scope settings widgets to keep Luau local-register usage below the compiler limit.
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
 row.Text = " " .. player.DisplayName .. " (@" .. player.Name .. ")"
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
 DirectoryStatus.Text = "PLAYERS: " .. tostring(count) .. (SelectedDirectoryPlayer and SelectedDirectoryPlayer.Parent and " | @" .. SelectedDirectoryPlayer.Name or "")
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
 HubExtras.HasProfileFileAPI = function()
 return type(makefolder) == "function" and type(writefile) == "function"
 and type(readfile) == "function" and type(isfile) == "function"
 end
 MakeButton(SettingsPage, "SAVE LATEST PROFILE", function()
 if not HubExtras.HasProfileFileAPI() then ProfileStatus.Text = "PROFILE: FILE API UNAVAILABLE" return end
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
 if not HubExtras.HasProfileFileAPI() then ProfileStatus.Text = "PROFILE: FILE API UNAVAILABLE" return end
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

 end -- End scoped settings widgets.

 -- A compact menu in the header gives one-click access to common pages and HUD.
 local QuickMenuButton = Instance.new("TextButton")
 QuickMenuButton.Name = "QuickMenuButton"
 QuickMenuButton.Size = UDim2.fromOffset(30, 30)
 QuickMenuButton.Position = UDim2.new(1, IsCreator and -308 or -206, 0, 8)
 QuickMenuButton.BackgroundColor3 = ButtonDark
 QuickMenuButton.Text = "MENU"
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
 historyClose.Text = ""
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
 end)
 GUI.QuickMenuButton = QuickMenuButton

 end -- scoped extras: keep Luau local-register usage below the compiler limit.

 -- SESSION TOOLS: live diagnostics and copy helpers
 Label(UtilityFolder, "SESSION TOOLS", 12, 24, PurpleLight).Font = Enum.Font.GothamBold
 Label(UtilityFolder, "Hub toggle: " .. HubExtras.HubToggleKey.Name .. " | Quick menu: " .. HubExtras.QuickMenuKey.Name, 10, 20, Grey)
 local PerformanceLabel = Label(UtilityFolder, "FPS: -- | PING: -- | MEMORY: -- MB", 10, 24, White)
 PerformanceLabel.TextWrapped = true

 RunService = game:GetService("RunService")
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
 "FPS: %d | PING: %s | MEMORY: %s MB",
 lastFps,
 tostring(pingText),
 tostring(memoryText)
 )
 end
 if HubExtras.PerformanceHud and HubExtras.PerformanceHud.Parent and HubExtras.PerformanceHudEnabled then
 local elapsed = math.max(0, math.floor(os.clock() - HubExtras.SessionStartedAt))
 local sessionText = string.format("%02d:%02d:%02d", math.floor(elapsed / 3600), math.floor(elapsed / 60) % 60, elapsed % 60)
 HubExtras.PerformanceHud.Text = string.format("FPS %d - PING %s - %s", lastFps, tostring(pingText), sessionText)
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

 end
 do -- section scope: keeps Luau local-register usage below the 200-local limit
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

 end
  ScreenGui.Destroying:Connect(function()
 if GUI.StopSlapDetector then pcall(GUI.StopSlapDetector) end
 end)

 end
 -- COMING SOON PAGE
 Label(SoonPage, "COMING SOON", 17, 30).Font = Enum.Font.GothamBold; Label(SoonPage, "More features are being worked on.", 12, 25, Grey)
 GUI.SoonCard = Instance.new("Frame")
 GUI.SoonCard.Size = UDim2.new(1, 0, 0, 75); GUI.SoonCard.BackgroundColor3 = ButtonDark; GUI.SoonCard.BorderSizePixel = 0
 GUI.SoonCard.Parent = SoonPage; GUI.SoonCard.LayoutOrder = 3; Corner(GUI.SoonCard, 10); Stroke(GUI.SoonCard, Border, 1)
 AddGradient(GUI.SoonCard, Color3.fromRGB(36, 31, 49), ButtonDark, 90); GUI.SoonText = Label(GUI.SoonCard, "Stay tuned for future updates!", 12, 75,
 White)
 GUI.SoonText.TextXAlignment = Enum.TextXAlignment.Center

 -- Feedback lives permanently on the Coming Soon page, below the announcement card.

 -- MINIMIZE BUBBLE
 GUI.MinimizeBubble = Instance.new("TextButton"); GUI.MinimizeBubble.Name = "ShortNameBubble"; GUI.MinimizeBubble.Size = UDim2.fromOffset(55, 55)
 GUI.MinimizeBubble.Position = UDim2.new(0, 15, 0.5, -27); GUI.MinimizeBubble.BackgroundColor3 = Dark; GUI.MinimizeBubble.Text = "SN"
 GUI.MinimizeBubble.TextColor3 = White; GUI.MinimizeBubble.TextSize = 17; GUI.MinimizeBubble.Font = Enum.Font.GothamBold
 GUI.MinimizeBubble.Visible = false; GUI.MinimizeBubble.Parent = ScreenGui; Corner(GUI.MinimizeBubble, 50)
 AddGradient(GUI.MinimizeBubble, Color3.fromRGB(42, 31, 62), Dark, 90); Stroke(GUI.MinimizeBubble, PurpleLight, 2); AddHover(GUI.MinimizeBubble, Dark, Color3.fromRGB(43, 33, 61))
 HubExtras.Minimized = false

 MinButton.Activated:Connect(function()
 if HubExtras.Minimized then
 return
 end
 HubExtras.Minimized = true
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
 if ScreenGui.Parent and HubExtras.Minimized then
 Frame.Visible = false
 GUI.MinimizeBubble.Visible = true
 GUI.MinimizeBubble.Size = UDim2.fromOffset(42, 42)
 Tween(
 GUI.MinimizeBubble,
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

 GUI.MinimizeBubble.Activated:Connect(function()
 HubExtras.Minimized = false
 GUI.MinimizeBubble.Visible = false
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
 if HubExtras.Minimized then
 HubExtras.Minimized = false
 GUI.MinimizeBubble.Visible = false
 Frame.Visible = true
 WindowScale.Scale = 1
 else
 HubExtras.Minimized = true
 Frame.Visible = false
 GUI.MinimizeBubble.Visible = true
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

 GUI.MinimizeBubble.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1
 or input.UserInputType == Enum.UserInputType.Touch
 then
 BubbleDragging = true
 BubbleInput = input
 BubbleStart = input.Position
 BubblePosition = GUI.MinimizeBubble.Position
 input.Changed:Connect(function()
 if input.UserInputState == Enum.UserInputState.End then
 BubbleDragging = false
 end
 end)
 end
 end)

 GUI.MinimizeBubble.InputChanged:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseMovement
 or input.UserInputType == Enum.UserInputType.Touch
 then
 BubbleInput = input
 end
 end)

 UIS.InputChanged:Connect(function(input)
 if input == BubbleInput and BubbleDragging then
 local delta = input.Position - BubbleStart
 GUI.MinimizeBubble.Position = UDim2.new(
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
 if ObjectScanner and type(ObjectScanner.Stop) == "function" then
 ObjectScanner:Stop()
 end
 end)
 pcall(function()
 if InstanceInspector and type(InstanceInspector.Clear) == "function" then
 InstanceInspector:Clear()
 end
 end)
 pcall(function()
 if StructureScanner and type(StructureScanner.Stop) == "function" then
 StructureScanner:Stop()
 end
 end)
 if GUI.StopSlapDetector then pcall(GUI.StopSlapDetector) end
 ScreenGui:Destroy()
 end)

 -- Single horizontal action rail. UIListLayout owns placement so labels can never overlap.
 local HeaderActions = Instance.new("Frame")
 HeaderActions.Name = "HeaderActions"
 HeaderActions.AnchorPoint = Vector2.new(1, 0)
 HeaderActions.Position = UDim2.new(1, -8, 0, 8)
 HeaderActions.Size = UDim2.fromOffset(0, 30)
 HeaderActions.BackgroundTransparency = 1
 HeaderActions.Parent = Header
 HeaderActions.ZIndex = 9
 -- Updates is a header control, not a sidebar navigation item.
 GUI.UpdatesNav.Parent = HeaderActions

 local HeaderActionLayout = Instance.new("UIListLayout")
 HeaderActionLayout.FillDirection = Enum.FillDirection.Horizontal
 HeaderActionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
 HeaderActionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
 HeaderActionLayout.SortOrder = Enum.SortOrder.LayoutOrder
 HeaderActionLayout.Padding = UDim.new(0, 5)
 HeaderActionLayout.Parent = HeaderActions

 local function LayoutHeaderControls()
 local compact = WindowWidth < 560
 local gap = compact and 3 or 5
 local controls = {
 { GUI.GlobalSearchButton, compact and "SR" or "SEARCH", compact and 22 or 54 },
  { GUI.UpdatesNav, compact and "UP" or "UPDATES", compact and 22 or 58 },
 { GUI.SidebarToggle, compact and "MN" or "MENU", compact and 22 or 44 },
 { GUI.QuickMenuButton, compact and "MR" or "MORE", compact and 22 or 48 },
 { GearButton, compact and "ST" or "SET", compact and 22 or 42 },
 }
 if OwnerViewButton then table.insert(controls, { OwnerViewButton, compact and "OW" or "OWNER", compact and 22 or 48 }) end
 table.insert(controls, { CrownButton, "CREDS", compact and 42 or 54 })
  table.insert(controls, { RefreshHubButton, "REFRESH", compact and 52 or 68, compact and 8 or 9 })
 table.insert(controls, { MinButton, "-", 24 })
 table.insert(controls, { ExitButton, "X", 24 })

 local naturalWidth = gap * (#controls - 1)
 for _, item in ipairs(controls) do naturalWidth = naturalWidth + item[3] end
 local available = math.max(190, WindowWidth - (compact and 88 or 300))
 local scale = math.min(1, available / naturalWidth)
 local total = gap * (#controls - 1)

 for order, item in ipairs(controls) do
 local button, caption, natural = item[1], item[2], item[3]
 local width = math.max(compact and 18 or 22, math.floor(natural * scale))
 if button then
 button.Parent = HeaderActions
 button.LayoutOrder = order
 button.AutomaticSize = Enum.AutomaticSize.None
 button.Size = UDim2.fromOffset(width, 28)
 button.Text = caption
 button.TextSize = item[4] or (compact and 8 or 9)
 button.TextScaled = false
 button.TextWrapped = false
 button.TextTruncate = Enum.TextTruncate.AtEnd
 button.TextXAlignment = Enum.TextXAlignment.Center
 button.TextYAlignment = Enum.TextYAlignment.Center
 button.TextStrokeTransparency = 1
 button.Font = Enum.Font.GothamMedium
 button.ZIndex = 10
 end
 total = total + width
 end
 total = total + gap * (#controls - 1)
 HeaderActionLayout.Padding = UDim.new(0, gap)
 HeaderActions.Size = UDim2.fromOffset(total, 28)

 local titleLabel = Header:FindFirstChildWhichIsA("TextLabel")
 local titleWidth = math.max(0, WindowWidth - total - 48)
 if titleLabel then
 titleLabel.Size = UDim2.new(0, titleWidth, 0, 25)
 titleLabel.Visible = titleWidth >= 80
 titleLabel.TextStrokeTransparency = 1
 titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
 end
 for _, child in ipairs(Header:GetChildren()) do
 if child:IsA("TextLabel") and child ~= titleLabel then
 child.Size = UDim2.new(0, titleWidth, 0, 13)
 child.Visible = titleWidth >= 130
 child.TextStrokeTransparency = 1
 end
 end
 end
 LayoutHeaderControls()

 -- Enforce clean, unoutlined typography on every current and future hub text object.
 local function RemoveTextStroke(instance)
 if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
 instance.TextStrokeTransparency = 1
 instance.TextStrokeColor3 = Color3.new(0, 0, 0)
 end
 end
 for _, descendant in ipairs(ScreenGui:GetDescendants()) do
 RemoveTextStroke(descendant)
 end
 ScreenGui.DescendantAdded:Connect(RemoveTextStroke)

 -- Restore previously enabled/disabled toggle buttons after every control has been created.
 RestorePersistedToggleStates()

 BuildUpdatesPage(GUI.UpdatesPage, Config, CurrentAccent, ButtonDark, Border, White, Grey, Label, Corner, Stroke, Tween)
 FeedbackPanel.Name = "ComingSoonFeedbackPanel"
 FeedbackPanel.Parent = SoonPage
 FeedbackPanel.Position = UDim2.fromOffset(0, 0)
 FeedbackPanel.Size = UDim2.new(1, 0, 0, 226)
 FeedbackPanel.LayoutOrder = 4
 FeedbackPanel.BackgroundColor3 = ButtonDark
 FeedbackPanel.Visible = true
 FeedbackPanel.ZIndex = 2
 FeedbackPanel.BackgroundTransparency = 0
 FeedbackPanel.ClipsDescendants = true
 local feedbackStroke = FeedbackPanel:FindFirstChildOfClass("UIStroke")
 if feedbackStroke then feedbackStroke.Color = Border end
 FeedbackTitle.Text = "SEND FEEDBACK"
 FeedbackTitle.TextColor3 = White
 FeedbackTitle.TextStrokeTransparency = 1
 FeedbackStatus.Text = "Share an idea or report a problem. Your message goes to the private hub feedback inbox."
 FeedbackStatus.Size = UDim2.new(1, -20, 0, 30)
 FeedbackStatus.TextSize = 9
 FeedbackBox.ZIndex = 6
 FeedbackBox.TextStrokeTransparency = 1
 FeedbackSend.ZIndex = 6
 FeedbackSend.BackgroundColor3 = ButtonDark
 FeedbackSend.TextColor3 = White
 FeedbackSend.TextStrokeTransparency = 1
 FeedbackClose.Visible = false
 SelectPage("Updates"); Tween(WindowScale, { Scale = 1 }, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
 if Camera then
 GUI.ViewportConnection = Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
 if not Frame.Parent then return end
 local newViewport = Camera.ViewportSize
 WindowWidth = math.max(300, math.min(900, math.floor(newViewport.X * 0.90)))
 WindowHeight = math.max(340, math.min(680, math.floor(newViewport.Y * 0.82)))
 Frame.Size = UDim2.fromOffset(WindowWidth, WindowHeight)
 Frame.Position = UDim2.new(0.5, -WindowWidth / 2, 0.5, -WindowHeight / 2)
 SidebarWidth = GUI.SidebarCollapsed and 58 or math.min(166, WindowWidth * 0.28)
 Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -76)
 Content.Position = UDim2.new(0, SidebarWidth + 20, 0, 58)
 Content.Size = UDim2.new(1, -SidebarWidth - 30, 1, -68)
 LayoutHeaderControls()
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
