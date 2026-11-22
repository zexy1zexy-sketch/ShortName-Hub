
local BaseURL =
    "https://raw.githubusercontent.com/zexy1zexy-sketch/ShortName-Hub/refs/heads/main/"

local function LoadModule(name)
    local url = BaseURL .. name

    local success, result = pcall(function()
        local source = game:HttpGet(url)
        local chunk = loadstring(source)

        assert(chunk, "Could not compile " .. name)

        return chunk()
    end)

    if not success then
        error("ShortName Hub failed loading " .. name .. ": " .. tostring(result))
    end

    return result
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
