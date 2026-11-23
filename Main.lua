-- ShortName Hub loader for the private GitHub repository.
-- Refresh downloads fresh module source from the Cloudflare Worker and rebuilds the hub in-place.

local MODULE_ENDPOINT = "https://shortname-report-receive.ryft-amv.workers.dev/module?name="

local function GetRequestFunction()
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

local RequestFunction = GetRequestFunction()

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
        error("Could not compile " .. name .. ": " .. tostring(compileError))
    end
    local moduleSuccess, moduleResult = pcall(chunk)
    if not moduleSuccess then
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
        print("ShortName Hub: " .. (skipKey and "refreshed successfully!" or "GUI loaded successfully!"))
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
        error(result)
    end
    return result
end

local success, result = pcall(function()
    return StartHub(false)
end)
if not success then
    warn("ShortName Hub startup error: " .. tostring(result))
end
