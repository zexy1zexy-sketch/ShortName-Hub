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
        pcall(function()
            local LoadingScreen = LoadModule("LoadingScreen.lua")
            LoadingScreen.Start()
        end)

        local KeySystem = LoadModule("KeySystem.lua")
        if not KeySystem.Start() then
            return false
        end
    end

    -- Fetch every module again so the refresh uses the newest GitHub versions.
    local Config = LoadModule("Config.lua")
    local NPC = LoadModule("NPC.lua")
    local Teleport = LoadModule("Teleport.lua")
    local GUI = LoadModule("GUI.lua")
    local ScytheModule = LoadModule("Scythe.lua")
    local Logger = LoadModule("Logger.lua")
    local SpyAdapter = (skipKey and CurrentRuntime and CurrentRuntime.SpyAdapter) or LoadModule("SpyAdapter.lua")
    local ThanksgivingScanner = LoadModule("ThanksgivingScanner.lua")

    local Interface
    local Controller = Teleport.new(Config, NPC, function(status)
        if Interface then
            Interface.SetStatus(status)
        end
    end)
    local Scythe = ScytheModule.new()
    local Scanner = ThanksgivingScanner.new()

    local success, result = pcall(function()
        return GUI.Create(
            Config,
            Controller,
            Scythe,
            Logger,
            SpyAdapter,
            Scanner,
            RefreshHub
        )
    end)

    if not success or not result then
        StopRuntime({
            Controller = Controller,
            Scythe = Scythe,
            Scanner = Scanner
        })
        error("GUI creation failed: " .. tostring(result))
    end

    Interface = result
    local previousRuntime = CurrentRuntime
    CurrentRuntime = {
        Controller = Controller,
        Scythe = Scythe,
        Scanner = Scanner,
        SpyAdapter = SpyAdapter,
        Interface = Interface
    }

    -- Only retire the previous hub after the replacement GUI was created.
    StopRuntime(previousRuntime)
    print("ShortName Hub: " .. (skipKey and "refreshed successfully!" or "GUI loaded successfully!"))
    return true
end

local success, result = pcall(function()
    return StartHub(false)
end)
if not success then
    warn("ShortName Hub startup error: " .. tostring(result))
end
