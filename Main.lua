-- ShortName Hub loader for the private GitHub repository.
-- Current release: v1.2.0

-- EARLY DIAGNOSTIC CONSOLE: create this before fetching or executing any modules.
local DiagnosticLines = {}
local RequestFunction
local GetRequestFunction
local DiagnosticGui, DiagnosticFrame, DiagnosticOutput, DiagnosticStatus, UploadKeyBox, UploadButton
local ShowDiagnosticConsole
local function IsLocalOwner()
    local player = game:GetService("Players").LocalPlayer
    return player ~= nil and player.UserId == 7867608166
end
local function GetSessionUploadKey()
    local shared = _G
    if type(getgenv) == "function" then
        local ok, value = pcall(getgenv)
        if ok and type(value) == "table" then shared = value end
    end
    if type(shared.__SHORTNAME_UPLOAD_KEY) ~= "string" then shared.__SHORTNAME_UPLOAD_KEY = "" end
    return shared
end

local function AddDiagnostic(message)
    local line = os.date("%H:%M:%S") .. "  " .. tostring(message)
    table.insert(DiagnosticLines, line)
    while #DiagnosticLines > 120 do
        table.remove(DiagnosticLines, 1)
    end
    if DiagnosticOutput then
        DiagnosticOutput.Text = table.concat(DiagnosticLines, "\\n")
        DiagnosticOutput.CursorPosition = #DiagnosticOutput.Text + 1
    end
end

local HitboxDiagnosticCaptured = false

local function DiagnoseHitboxCaster()
    local ok, err = pcall(function()
        local replicated = game:GetService("ReplicatedStorage")
        local package = replicated:FindFirstChild("RaycastHitboxV4")
        local target = package and package:FindFirstChild("HitboxCaster")

        if not package then
            AddDiagnostic("HITBOX DIAGNOSTIC: ReplicatedStorage.RaycastHitboxV4 was not found.")
            return
        end
        if not target then
            AddDiagnostic("HITBOX DIAGNOSTIC: RaycastHitboxV4 exists, but HitboxCaster was not found.")
            local names = {}
            for _, child in ipairs(package:GetChildren()) do
                table.insert(names, child.Name .. " [" .. child.ClassName .. "]")
                if #names >= 25 then break end
            end
            AddDiagnostic("HITBOX PACKAGE CHILDREN: " .. table.concat(names, ", "))
            return
        end

        AddDiagnostic("HITBOX TARGET: " .. target:GetFullName() .. " [" .. target.ClassName .. "]")
        AddDiagnostic("HITBOX PARENT: " .. (target.Parent and target.Parent:GetFullName() or "nil"))
        local children = {}
        for _, child in ipairs(target:GetChildren()) do
            table.insert(children, child.Name .. " [" .. child.ClassName .. "]")
            if #children >= 25 then break end
        end
        AddDiagnostic("HITBOX CHILDREN: " .. (#children > 0 and table.concat(children, ", ") or "(none)"))

        local sourceOk, source = pcall(function()
            if not target:IsA("LuaSourceContainer") then
                error("HitboxCaster is not a script/module")
            end
            return target.Source
        end)
        if not sourceOk or type(source) ~= "string" then
            AddDiagnostic("HITBOX SOURCE ACCESS: unavailable (" .. tostring(source):sub(1, 180) .. ")")
            return
        end

        AddDiagnostic("HITBOX SOURCE ACCESS: readable; scanning relevant lines.")
        local sourceLines = {}
        for line in (source .. "\\n"):gmatch("(.-)\\r?\\n") do
            table.insert(sourceLines, line)
        end
        local selected, seen = {}, {}
        for i, line in ipairs(sourceLines) do
            if line:find("HitboxPendingRemoval", 1, true) or line:find("OnScheduler", 1, true) then
                for j = math.max(1, i - 4), math.min(#sourceLines, i + 4) do
                    if not seen[j] then
                        seen[j] = true
                        table.insert(selected, string.format("%d: %s", j, sourceLines[j]))
                    end
                end
            end
        end
        if #selected == 0 then
            AddDiagnostic("HITBOX SOURCE SCAN: neither HitboxPendingRemoval nor OnScheduler was found.")
        else
            local excerpt = table.concat(selected, " | ")
            AddDiagnostic("HITBOX SOURCE EXCERPT: " .. excerpt:sub(1, 1800))
        end
    end)
    if not ok then
        AddDiagnostic("HITBOX DIAGNOSTIC FAILED: " .. tostring(err):sub(1, 220))
    end
end

local function BuildDiagnosticConsole()
    if not IsLocalOwner() then return end
    local ok, err = pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "ShortNameDiagnosticConsole"
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 100000
        local parented = false
        if type(gethui) == "function" then
            parented = pcall(function() gui.Parent = gethui() end)
        end
        if not parented then
            parented = pcall(function() gui.Parent = game:GetService("CoreGui") end)
        end
        if not parented then
            local player = game:GetService("Players").LocalPlayer
            if player then
                gui.Parent = player:WaitForChild("PlayerGui", 5)
                parented = gui.Parent ~= nil
            end
        end
        if not parented then error("Could not parent diagnostic console to gethui, CoreGui, or PlayerGui") end

        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromOffset(440, 300)
        frame.Position = UDim2.new(0.5, -220, 0.5, -150)
        frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        frame.BorderSizePixel = 0
        frame.Visible = false
        frame.Parent = gui

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -16, 0, 28)
        title.Position = UDim2.fromOffset(8, 5)
        title.BackgroundTransparency = 1
        title.Text = "SHORTNAME HUB  •  STARTUP CONSOLE"
        title.TextColor3 = Color3.fromRGB(205, 175, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Size = UDim2.new(1, -76, 0, 28)
        title.Active = true
        title.Parent = frame

        local minimize = Instance.new("TextButton")
        minimize.Size = UDim2.fromOffset(28, 22)
        minimize.Position = UDim2.new(1, -64, 0, 7)
        minimize.BackgroundColor3 = Color3.fromRGB(48, 48, 62)
        minimize.TextColor3 = Color3.new(1, 1, 1)
        minimize.Text = "—"
        minimize.TextSize = 16
        minimize.Font = Enum.Font.GothamBold
        minimize.Parent = frame

        local close = Instance.new("TextButton")
        close.Size = UDim2.fromOffset(28, 22)
        close.Position = UDim2.new(1, -32, 0, 7)
        close.BackgroundColor3 = Color3.fromRGB(150, 55, 65)
        close.TextColor3 = Color3.new(1, 1, 1)
        close.Text = "X"
        close.TextSize = 12
        close.Font = Enum.Font.GothamBold
        close.Parent = frame

        local output = Instance.new("TextBox")
        output.Size = UDim2.new(1, -16, 1, -104)
        output.Position = UDim2.fromOffset(8, 36)
        output.BackgroundColor3 = Color3.fromRGB(9, 9, 13)
        output.TextColor3 = Color3.fromRGB(225, 225, 235)
        output.PlaceholderText = "Waiting for startup messages..."
        output.Text = ""
        output.TextSize = 11
        output.Font = Enum.Font.Code
        output.TextXAlignment = Enum.TextXAlignment.Left
        output.TextYAlignment = Enum.TextYAlignment.Top
        output.TextWrapped = false
        output.MultiLine = true
        output.ClearTextOnFocus = false
        output.TextEditable = false
        output.Parent = frame

        local keyBox = Instance.new("TextBox")
        keyBox.Size = UDim2.new(1, -150, 0, 26)
        keyBox.Position = UDim2.new(0, 8, 1, -60)
        keyBox.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
        keyBox.TextColor3 = Color3.fromRGB(240, 240, 248)
        keyBox.PlaceholderText = "Upload key (cached for this session)"
        keyBox.Text = tostring(GetSessionUploadKey().__SHORTNAME_UPLOAD_KEY or "")
        keyBox.TextSize = 11
        keyBox.Font = Enum.Font.Gotham
        keyBox.ClearTextOnFocus = false
        keyBox.Parent = frame

        local upload = Instance.new("TextButton")
        upload.Size = UDim2.fromOffset(132, 26)
        upload.Position = UDim2.new(1, -140, 1, -60)
        upload.BackgroundColor3 = Color3.fromRGB(112, 66, 190)
        upload.TextColor3 = Color3.new(1, 1, 1)
        upload.Text = "UPLOAD REPORT"
        upload.TextSize = 10
        upload.Font = Enum.Font.GothamBold
        upload.Parent = frame

        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, -16, 0, 22)
        status.Position = UDim2.new(0, 8, 1, -29)
        status.BackgroundTransparency = 1
        status.Text = "Console started before module loading."
        status.TextColor3 = Color3.fromRGB(170, 170, 185)
        status.TextSize = 10
        status.Font = Enum.Font.Gotham
        status.TextXAlignment = Enum.TextXAlignment.Left
        status.Parent = frame

        DiagnosticGui, DiagnosticFrame, DiagnosticOutput, DiagnosticStatus = gui, frame, output, status
        UploadKeyBox, UploadButton = keyBox, upload
        keyBox.FocusLost:Connect(function()
            GetSessionUploadKey().__SHORTNAME_UPLOAD_KEY = tostring(keyBox.Text or "")
        end)

        local minimized = false
        local fullSize = UDim2.fromOffset(440, 300)
        minimize.Activated:Connect(function()
            minimized = not minimized
            output.Visible = not minimized
            keyBox.Visible = not minimized
            upload.Visible = not minimized
            status.Visible = not minimized
            frame.Size = minimized and UDim2.fromOffset(440, 38) or fullSize
            minimize.Text = minimized and "+" or "—"
        end)
        close.Activated:Connect(function()
            -- Hide rather than destroy so a later startup error can reopen the console.
            frame.Visible = false
        end)

        -- Drag the console by its title bar (mouse or touch).
        local UserInputService = game:GetService("UserInputService")
        local dragging = false
        local dragInput
        local dragStart
        local startPosition
        title.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPosition = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        title.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPosition.X.Scale, startPosition.X.Offset + delta.X,
                    startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
                )
            end
        end)

        upload.Activated:Connect(function()
            local key = tostring(keyBox.Text or "")
            GetSessionUploadKey().__SHORTNAME_UPLOAD_KEY = key
            if key == "" then
                status.Text = "Enter the upload key first."
                return
            end
            local requestFn = RequestFunction or GetRequestFunction()
            if not requestFn then
                status.Text = "Executor HTTP request API unavailable."
                return
            end
            upload.Active = false
            upload.Text = "UPLOADING..."
            status.Text = "Sending diagnostic report..."
            task.spawn(function()
                local HttpService = game:GetService("HttpService")
                DiagnoseHitboxCaster()
            local report = "SHORTNAME HUB STARTUP DIAGNOSTICS\\nCaptured: " .. os.date("!%Y-%m-%d %H:%M:%S UTC") .. "\\n\\n" .. table.concat(DiagnosticLines, "\\n")
                local sent, response = pcall(function()
                    return requestFn({
                        Url = "https://shortname-report-receive.ryft-amv.workers.dev/upload",
                        Method = "POST",
                        Timeout = 45,
                        Headers = { ["Content-Type"] = "application/json", ["x-upload-key"] = key },
                        Body = HttpService:JSONEncode({ report = report })
                    })
                end)
                local code = type(response) == "table" and (response.StatusCode or response.Status or response.status_code) or nil
                local body = type(response) == "table" and (response.Body or response.body or "") or tostring(response)
                local decodedOk, decoded = pcall(function() return HttpService:JSONDecode(body) end)
                if sent and code == 200 and decodedOk and type(decoded) == "table" and decoded.ok == true then
                    status.Text = "UPLOAD CONFIRMED — report saved."
                else
                    status.Text = "UPLOAD FAILED: HTTP " .. tostring(code) .. " — " .. tostring(body):sub(1, 100)
                end
                upload.Text = "UPLOAD REPORT"
                upload.Active = true
            end)
        end)

        AddDiagnostic("Diagnostic console initialized before loading modules.")
    end)
    if not ok then
        warn("ShortName Hub diagnostic console could not initialize: " .. tostring(err))
        print("ShortName Hub diagnostic console error: " .. tostring(err))
    end
end

ShowDiagnosticConsole = function()
    if not IsLocalOwner() then return end
    if DiagnosticGui and DiagnosticFrame then
        DiagnosticGui.Enabled = true
        DiagnosticFrame.Visible = true
    end
end

pcall(BuildDiagnosticConsole)

pcall(function()
    game:GetService("LogService").MessageOut:Connect(function(message, messageType)
        if messageType == Enum.MessageType.MessageError then
            AddDiagnostic("ERROR: " .. tostring(message))
            if not HitboxDiagnosticCaptured and tostring(message):find("HitboxPendingRemoval", 1, true) then
                HitboxDiagnosticCaptured = true
                AddDiagnostic("Detected the RaycastHitboxV4 HitboxPendingRemoval error; collecting module diagnostics.")
                DiagnoseHitboxCaster()
            end
            ShowDiagnosticConsole()
        end
    end)
end)
-- Refresh downloads fresh module source from the Cloudflare Worker and rebuilds the hub in-place.

local MODULE_ENDPOINT = "https://shortname-report-receive.ryft-amv.workers.dev/module?name="

GetRequestFunction = function()
    if type(request) == "function" then
        return request
    end
    if type(http_request) == "function" then
        return http_request
    end
    if syn and type(syn.request) == "function" then
        return syn.request
    end
    if http and type(http.request) == "function" then
        return http.request
    end
    if fluxus and type(fluxus.request) == "function" then
        return fluxus.request
    end
    return nil
end

RequestFunction = GetRequestFunction()
AddDiagnostic("Executor HTTP request API: " .. (RequestFunction and "available" or "not found"))

local function LoadModule(name)
    if not name:match("^[%w_%-]+%.lua$") then
        error("Invalid module filename: " .. tostring(name))
    end
    if not RequestFunction then
        error("Your executor does not expose request/http_request.")
    end

    local response
    local success, requestError = pcall(function()
        local moduleUrl = MODULE_ENDPOINT .. name
    if name == "GUI.lua" then
        moduleUrl = "https://raw.githubusercontent.com/zexy1zexy-sketch/ShortName-Hub/refs/heads/main/GUI.lua"
        AddDiagnostic("Loading GUI.lua directly from main branch.")
    end
    response = RequestFunction({
            Url = moduleUrl,
            Method = "GET",
            Headers = {
                ["Cache-Control"] = "no-cache",
                ["Pragma"] = "no-cache"
            }
        })
    end)
    if not success then
        error("Cloudflare request failed for " .. name .. ": " .. tostring(requestError))
    end
    local status = type(response) == "table" and (response.StatusCode or response.Status or response.status_code) or nil
    local source = type(response) == "table" and (response.Body or response.body) or nil

    -- The new universal observer can fall back to the public repository while
    -- an older deployed Worker is waiting for its allowlist update.
    if name == "UniversalLiveObserver.lua" and status ~= 200 then
        local fallbackUrl = "https://raw.githubusercontent.com/zexy1zexy-sketch/ShortName-Hub/refs/heads/main/" .. name
        local fallbackResponse
        local fallbackOk, fallbackError = pcall(function()
            fallbackResponse = RequestFunction({
                Url = fallbackUrl,
                Method = "GET",
                Headers = { ["Cache-Control"] = "no-cache", ["Pragma"] = "no-cache" }
            })
        end)
        if fallbackOk and type(fallbackResponse) == "table" then
            local fallbackStatus = fallbackResponse.StatusCode or fallbackResponse.Status or fallbackResponse.status_code
            local fallbackSource = fallbackResponse.Body or fallbackResponse.body
            if fallbackStatus == 200 and type(fallbackSource) == "string" and fallbackSource ~= "" then
                status = fallbackStatus
                source = fallbackSource
                AddDiagnostic("Loaded UniversalLiveObserver.lua using GitHub fallback.")
            else
                error("Cloudflare denied UniversalLiveObserver.lua and GitHub fallback failed (HTTP "
                    .. tostring(fallbackStatus) .. "): " .. tostring(fallbackSource))
            end
        else
            error("Cloudflare denied UniversalLiveObserver.lua and GitHub fallback request failed: "
                .. tostring(fallbackError))
        end
    end

    if type(response) ~= "table" and status ~= 200 then
        error("Invalid response while loading " .. name)
    end
    if status ~= 200 then
        error("Cloudflare could not load " .. name .. " (HTTP " .. tostring(status) .. "): " .. tostring(source))
    end
    if type(source) ~= "string" or source == "" then
        error("Cloudflare returned an empty module: " .. name)
    end

    local chunk, compileError = loadstring(source)
    if not chunk then
        AddDiagnostic("COMPILE ERROR in " .. name .. ": " .. tostring(compileError))
        error("Could not compile " .. name .. ": " .. tostring(compileError))
    end
    local moduleSuccess, moduleResult = pcall(chunk)
    if not moduleSuccess then
        AddDiagnostic("MODULE ERROR in " .. name .. ": " .. tostring(moduleResult))
        error("Module execution failed for " .. name .. ": " .. tostring(moduleResult))
    end
    return moduleResult
end

pcall(function()
    game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(false)
end)

local CurrentRuntime
local Refreshing = false
local StartHub

local function GetSharedEnvironment()
    if type(getgenv) == "function" then
        local ok, env = pcall(getgenv)
        if ok and type(env) == "table" then
            return env
        end
    end
    return _G
end

local SharedEnvironment = GetSharedEnvironment()
SharedEnvironment.__SHORTNAME_SHOW_DIAGNOSTICS = ShowDiagnosticConsole

-- Optional executor-supported auto-load after teleport/rejoin.
-- The preference is stored locally so the queue can be renewed in each session.
local AUTOLOAD_FILE = "ShortNameHub_AutoLoad.txt"
local LOADER_URL = "https://raw.githubusercontent.com/zexy1zexy-sketch/ShortName-Hub/refs/heads/main/Main.lua"
local function GetQueueOnTeleport()
    if type(queue_on_teleport) == "function" then return queue_on_teleport end
    if type(queueonteleport) == "function" then return queueonteleport end
    if syn and type(syn.queue_on_teleport) == "function" then return syn.queue_on_teleport end
    if fluxus and type(fluxus.queue_on_teleport) == "function" then return fluxus.queue_on_teleport end
    return nil
end
local function ReadAutoLoadPreference()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then return false end
    local ok, exists = pcall(isfile, AUTOLOAD_FILE)
    if not ok or not exists then return false end
    local readOk, value = pcall(readfile, AUTOLOAD_FILE)
    return readOk and tostring(value):lower() == "true"
end
local function SetAutoLoadPreference(enabled)
    if type(writefile) ~= "function" then
        return false, "This executor does not support writefile."
    end
    local ok, err = pcall(writefile, AUTOLOAD_FILE, enabled and "true" or "false")
    if not ok then return false, "Could not save auto-load preference: " .. tostring(err) end
    if not enabled then return true, "AUTO-LOAD DISABLED" end
    local queue = GetQueueOnTeleport()
    if not queue then return false, "Saved, but this executor has no queue-on-teleport API." end
    local queued, queueError = pcall(queue, 'loadstring(game:HttpGet("' .. LOADER_URL .. '"))()')
    if not queued then return false, "Could not queue auto-load: " .. tostring(queueError) end
    return true, "AUTO-LOAD ENABLED — WILL RUN AFTER REJOIN"
end
SharedEnvironment.__SHORTNAME_SET_AUTOLOAD = SetAutoLoadPreference
SharedEnvironment.__SHORTNAME_AUTOLOAD_ACTIVE = ReadAutoLoadPreference()
if ReadAutoLoadPreference() then
    local queue = GetQueueOnTeleport()
    if queue then
        pcall(queue, 'loadstring(game:HttpGet("' .. LOADER_URL .. '"))()')
    end
end

local RUNTIME_KEY = "__SHORTNAME_HUB_RUNTIME"

local function DestroyNamedGuiInstances(guiName)
    local roots = {}
    local function addRoot(root)
        if root then table.insert(roots, root) end
    end
    pcall(function()
        if type(gethui) == "function" then addRoot(gethui()) end
    end)
    pcall(function() addRoot(game:GetService("CoreGui")) end)
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if player then addRoot(player:FindFirstChildOfClass("PlayerGui")) end
    end)
    local seen = {}
    for _, root in ipairs(roots) do
        if not seen[root] then
            seen[root] = true
            pcall(function()
                for _, item in ipairs(root:GetDescendants()) do
                    if item:IsA("ScreenGui") and item.Name == guiName then
                        item:Destroy()
                    end
                end
                local direct = root:FindFirstChild(guiName)
                if direct and direct:IsA("ScreenGui") then direct:Destroy() end
            end)
        end
    end
end

-- A fresh execution of the loader must retire the previous execution's GUI
-- and loops. Refreshes within this execution are handled by RefreshHub below.
pcall(function()
    local previous = SharedEnvironment[RUNTIME_KEY]
    if type(previous) == "table" and type(previous.Shutdown) == "function" then
        previous.Shutdown()
    elseif type(previous) == "table" and previous.ScreenGui then
        previous.ScreenGui:Destroy()
    end
end)
SharedEnvironment[RUNTIME_KEY] = nil

local function StopRuntime(runtime)
    if not runtime then
        return
    end
    pcall(function()
        if runtime.Controller and type(runtime.Controller.Stop) == "function" then
            runtime.Controller.Stop()
        end
    end)
    pcall(function()
        if runtime.Scythe and type(runtime.Scythe.Stop) == "function" then
            runtime.Scythe.Stop()
        end
    end)
    pcall(function()
    end)
    pcall(function()
        if runtime.FightScanner and type(runtime.FightScanner.Stop) == "function" then
            runtime.FightScanner:Stop()
        end
    end)
    pcall(function()
        if runtime.FightStructureScanner and type(runtime.FightStructureScanner.Stop) == "function" then
            runtime.FightStructureScanner:Stop()
        end
    end)
    pcall(function()
        if runtime.LiveObserver and type(runtime.LiveObserver.Stop) == "function" then
            runtime.LiveObserver:Stop()
        end
    end)
    pcall(function()
        if runtime.RemoteLogger and type(runtime.RemoteLogger.Stop) == "function" then
            runtime.RemoteLogger:Stop()
        end
    end)
    pcall(function()
        if runtime.Interface and runtime.Interface.ScreenGui then
            runtime.Interface.ScreenGui:Destroy()
        end
    end)
end

local function RefreshHub()
    if Refreshing then
        return false, "Refresh is already running."
    end

    Refreshing = true

    -- Retire the current GUI before rebuilding. Previously the old interface
    -- was only destroyed after the new GUI succeeded, so a failed refresh
    -- left the previous window alive behind the failed loading screen.
    local previousRuntime = CurrentRuntime
    CurrentRuntime = nil
    StopRuntime(previousRuntime)
    SharedEnvironment[RUNTIME_KEY] = nil
    DestroyNamedGuiInstances("ShortNameHub")
    DestroyNamedGuiInstances("ShortNameLoadingScreen")

    local ok, result = pcall(function()
        return StartHub(true)
    end)
    Refreshing = false

    if not ok then
        warn("ShortName Hub refresh error: " .. tostring(result))
        return false, result
    end
    if result ~= true then
        return false, "The updated hub could not be created."
    end
    return true
end

StartHub = function(skipKey)
    if not skipKey then
        local KeySystem = LoadModule("KeySystem.lua")
        if not KeySystem.Start() then
            return false
        end
    end

    -- Remove stale loading screens left by an interrupted prior execution.
    DestroyNamedGuiInstances("ShortNameLoadingScreen")

    -- The loading screen is intentionally created only after key verification.
    local Loading = nil
    local loadingOk, loadingModule = pcall(function()
        return LoadModule("LoadingScreen.lua")
    end)
    if loadingOk and loadingModule and type(loadingModule.Start) == "function" then
        local screenOk, screen = pcall(loadingModule.Start)
        if screenOk then
            Loading = screen
        else
            warn("ShortName Hub loading screen error: " .. tostring(screen))
        end
    end

    local completed = 0
    local total = 18
    local function Step(message)
        completed = completed + 1
        if Loading and type(Loading.SetProgress) == "function" then
            Loading.SetProgress(completed, total, message)
        end
    end

    local function LoadTracked(name, message)
        local module = LoadModule(name)
        Step(message or ("Loaded " .. name))
        return module
    end

    local success, result = pcall(function()
        -- Each step completes only after the module has been fetched,
        -- compiled, and executed successfully.
        local Config = LoadTracked("Config.lua", "Loaded configuration")
        local NPC = LoadTracked("NPC.lua", "Loaded NPC systems")
        local Teleport = LoadTracked("Teleport.lua", "Loaded movement systems")
        local ThemeModule
        local themeLoaded, themeResult = pcall(function()
            return LoadTracked("Theme.lua", "Loaded theme foundation")
        end)
        if themeLoaded then
            ThemeModule = themeResult
        else
            AddDiagnostic("Theme module unavailable; using built-in fallback: " .. tostring(themeResult))
            Step("Using built-in theme fallback")
        end
        local GUI = LoadTracked("GUI.lua", "Loaded interface code")
        local PresenceModule
        local presenceLoaded, presenceResult = pcall(function()
            return LoadTracked("Presence.lua", "Loaded community presence")
        end)
        if presenceLoaded then
            PresenceModule = presenceResult
            if PresenceModule and type(PresenceModule.CheckBan) == "function" then
                local banCheckOk, banAllowed, banResult = pcall(PresenceModule.CheckBan)
                if banCheckOk and banAllowed and type(banResult) == "table" and banResult.banned == true then
                    local ban = banResult.ban or {}
                    local untilText = ban.expiresAt and os.date("%b %d, %Y %I:%M %p", ban.expiresAt / 1000) or "PERMANENTLY"
                    error("SHORTNAME HUB ACCESS RESTRICTED UNTIL " .. untilText)
                elseif not banCheckOk or not banAllowed then
                    AddDiagnostic("Ban status could not be verified: " .. tostring(banCheckOk and banResult or banAllowed))
                end
            end
        else
            AddDiagnostic("Presence module unavailable: " .. tostring(presenceResult))
            Step("Presence service unavailable")
        end
        local ScytheModule = LoadTracked("Scythe.lua", "Loaded weapon systems")
        local FightScannerModule = LoadTracked("FightOnABaseplateScanner.lua", "Loaded universal object scanner")
        local FightInspectorModule = LoadTracked("FightOnABaseplateInspector.lua", "Loaded universal instance inspector")
        local FightStructureScannerModule = LoadTracked("FightOnABaseplateStructureScanner.lua", "Loaded universal structure scanner")
        local LiveObserverModule = LoadTracked("UniversalLiveObserver.lua", "Loaded universal live observer")
        local RemoteLoggerModule = LoadTracked("RemoteLogger.lua", "Loaded universal remote logger")

        if Loading and type(Loading.SetProgress) == "function" then
            Loading.SetProgress(completed, total, "Initializing hub systems...")
        end
        local Interface
        local Controller = Teleport.new(Config, NPC, function(status)
            if Interface then
                Interface.SetStatus(status)
            end
        end)
        Step("Initialized movement controller")

        local Scythe = ScytheModule.new()
        Step("Initialized weapon systems")
        local FightScanner = FightScannerModule.new()
        Step("Initialized combat scanner")
        local FightInspector = FightInspectorModule.new()
        Step("Initialized combat inspector")
        local FightStructureScanner = FightStructureScannerModule.new()
        Step("Initialized structure scanner")
        local LiveObserver = LiveObserverModule.new()
        Step("Initialized universal live observer")
        local RemoteLogger = RemoteLoggerModule.new()
        Step("Initialized universal remote logger")

        local guiSuccess, guiResult = pcall(function()
            return GUI.Create(
                Config,
                Controller,
                Scythe,
                FightScanner,
                FightInspector,
                FightStructureScanner,
                LiveObserver,
                RemoteLogger,
                RefreshHub,
                PresenceModule,
                ThemeModule
            )
        end)

        if not guiSuccess or not guiResult then
            StopRuntime({
                Controller = Controller,
                Scythe = Scythe,
                FightScanner = FightScanner,
                FightInspector = FightInspector,
                FightStructureScanner = FightStructureScanner,
                LiveObserver = LiveObserver,
                RemoteLogger = RemoteLogger
            })
            error("GUI creation failed: " .. tostring(guiResult))
        end

        Interface = guiResult
        Step("Built main interface")

        local previousRuntime = CurrentRuntime
        CurrentRuntime = {
            Controller = Controller,
            Scythe = Scythe,
            FightScanner = FightScanner,
            FightInspector = FightInspector,
            FightStructureScanner = FightStructureScanner,
            LiveObserver = LiveObserver,
            RemoteLogger = RemoteLogger,
            Interface = Interface
        }

        SharedEnvironment[RUNTIME_KEY] = {
            ScreenGui = Interface.ScreenGui,
            Shutdown = function()
                local active = CurrentRuntime
                CurrentRuntime = nil
                StopRuntime(active)
            end
        }

        StopRuntime(previousRuntime)
        print("ShortName Hub v" .. tostring(Config.Version or "1.0.0") .. ": " .. (skipKey and "refreshed successfully!" or "GUI loaded successfully!"))
        return true
    end)

    if Loading then
        if success and result == true then
            Loading.Finish()
        elseif type(Loading.Fail) == "function" then
            Loading.Fail(tostring(result))
        else
            Loading.Finish()
        end
    end

    if not success then
        -- GUI.Create can fail after creating its ScreenGui but before returning
        -- it to the runtime manager. Sweep that partial interface as well.
        DestroyNamedGuiInstances("ShortNameHub")
        AddDiagnostic("STARTUP FAILED: " .. tostring(result))
        error(result)
    else
        AddDiagnostic("Startup completed successfully.")
    end
    return result
end

local success, result = pcall(function()
    return StartHub(false)
end)
if not success then
    AddDiagnostic("FATAL LOADER ERROR: " .. tostring(result))
    ShowDiagnosticConsole()
    warn("ShortName Hub startup error: " .. tostring(result))
end
