-- ShortName Hub loader for a PRIVATE GitHub repository.
-- The Cloudflare Worker reads private GitHub files using its server-side GITHUB_TOKEN.
-- Module source is served through the Cloudflare Worker; the GitHub token stays server-side.

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
        error("Your executor does not expose request/http_request. Private repository loading needs HTTP requests with headers.")
    end

    local response
    local success, requestError = pcall(function()
        response = RequestFunction({
            Url = MODULE_ENDPOINT .. name,
            Method = "GET",
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
        error("Cloudflare could not load " .. name .. " (HTTP "
            .. tostring(status) .. "): " .. tostring(source))
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

-- Disable Roblox paused notification
pcall(function()
    game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(false)
end)

-- ANIMATED LOADING SCREEN
local LoadingSuccess, LoadingResult = pcall(function()
    local LoadingScreen = LoadModule("LoadingScreen.lua")
    LoadingScreen.Start()
end)

if not LoadingSuccess then
    warn("ShortName Hub loading screen error: " .. tostring(LoadingResult))
end

-- KEY SYSTEM
local KeySystem = LoadModule("KeySystem.lua")

if not KeySystem.Start() then
    return
end

-- LOAD MODULES
local Config = LoadModule("Config.lua")
local NPC = LoadModule("NPC.lua")
local Teleport = LoadModule("Teleport.lua")
local GUI = LoadModule("GUI.lua")
local ScytheModule = LoadModule("Scythe.lua")
local Logger = LoadModule("Logger.lua")
local SpyAdapter = LoadModule("SpyAdapter.lua")
local ThanksgivingScanner = LoadModule("ThanksgivingScanner.lua")

-- CREATE CONTROLLERS
local Controller
local Scythe
local Interface

Controller = Teleport.new(Config, NPC, function(status)
    if Interface then
        Interface.SetStatus(status)
    end
end)

Scythe = ScytheModule.new()
local Scanner = ThanksgivingScanner.new()

-- TEMPORARILY DISABLED FOR CRASH TEST
local SpyStarted = false
warn("ShortName Hub: Remote Spy temporarily disabled.")

-- CREATE INTERFACE
local Success, Result = pcall(function()
    return GUI.Create(
        Config,
        Controller,
        Scythe,
        Logger,
        Scanner
    )
end)

if Success then
    Interface = Result
    print("ShortName Hub: GUI loaded successfully!")
else
    warn("ShortName Hub GUI ERROR: " .. tostring(Result))
end
