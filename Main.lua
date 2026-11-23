-- ShortName Hub loader for the private GitHub repository.
-- Current release: v1.0.2

-- EARLY DIAGNOSTIC CONSOLE: create this before fetching or executing any modules.
local DiagnosticLines = {}
local RequestFunction
local GetRequestFunction
local DiagnosticGui, DiagnosticFrame, DiagnosticOutput, DiagnosticStatus, UploadKeyBox, UploadButton
local ShowDiagnosticConsole

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

local function BuildDiagnosticConsole()
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
        title.Parent = frame

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
        keyBox.PlaceholderText = "Upload key (required)"
        keyBox.Text = ""
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
        upload.Activated:Connect(function()
            local key = tostring(keyBox.Text or "")
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
        response = RequestFunction({
            Url = MODULE_ENDPOINT .. name,
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
    if type(response) ~= "table" then
        error("Invalid response while loading " .. name)
    end

    local status = response.StatusCode or response.Status or response.status_code
    local source = response.Body or response.body
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
local RUNTIME_KEY = "__SHORTNAME_HUB_RUNTIME"

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
        if runtime.Scanner and type(runtime.Scanner.Stop) == "function" then
            runtime.Scanner:Stop()
        end
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
    local total = 16
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
        local GUI = LoadTracked("GUI.lua", "Loaded interface code")
        local ScytheModule = LoadTracked("Scythe.lua", "Loaded weapon systems")
        local ThanksgivingScanner = LoadTracked("ThanksgivingScanner.lua", "Loaded event scanner")
        local FightScannerModule = LoadTracked("FightOnABaseplateScanner.lua", "Loaded combat scanner")
        local FightInspectorModule = LoadTracked("FightOnABaseplateInspector.lua", "Loaded combat inspector")
        local FightStructureScannerModule = LoadTracked("FightOnABaseplateStructureScanner.lua", "Loaded structure scanner")

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
        local Scanner = ThanksgivingScanner.new()
        Step("Initialized event scanner")
        local FightScanner = FightScannerModule.new()
        Step("Initialized combat scanner")
        local FightInspector = FightInspectorModule.new()
        Step("Initialized combat inspector")
        local FightStructureScanner = FightStructureScannerModule.new()
        Step("Initialized structure scanner")

        local guiSuccess, guiResult = pcall(function()
            return GUI.Create(
                Config,
                Controller,
                Scythe,
                Scanner,
                FightScanner,
                FightInspector,
                FightStructureScanner,
                RefreshHub
            )
        end)

        if not guiSuccess or not guiResult then
            StopRuntime({
                Controller = Controller,
                Scythe = Scythe,
                Scanner = Scanner,
                FightScanner = FightScanner,
                FightInspector = FightInspector,
                FightStructureScanner = FightStructureScanner
            })
            error("GUI creation failed: " .. tostring(guiResult))
        end

        Interface = guiResult
        Step("Built main interface")

        local previousRuntime = CurrentRuntime
        CurrentRuntime = {
            Controller = Controller,
            Scythe = Scythe,
            Scanner = Scanner,
            FightScanner = FightScanner,
            FightInspector = FightInspector,
            FightStructureScanner = FightStructureScanner,
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
