
-- SHORTNAME HUB - REMOTE SPY ADAPTER

local SpyAdapter = {}

local Logger
local Enabled = false
local HookInstalled = false

local Hooked = {}
local Connections = {}
local OriginalNamecall
local CaptureCount = 0
local LastCapture = "No remote calls captured yet"
local LastError = nil

local function IsRemote(instance)
    if typeof(instance) ~= "Instance" then
        return false
    end

    return instance:IsA("RemoteEvent")
        or instance:IsA("RemoteFunction")
end

local function Record(remote, method, args)
    if not Enabled or not Logger then
        return
    end

    local ok, err = pcall(function()
        Logger:Record(remote, method, args)
    end)
    if ok then
        CaptureCount = CaptureCount + 1
        LastCapture = method .. " | " .. remote:GetFullName()
    else
        LastError = tostring(err)
        warn("ShortName Hub logger record error: " .. LastError)
    end
end

local function ConnectIncoming(remote)
    if not Enabled or Hooked[remote] then
        return
    end

    if not remote:IsA("RemoteEvent") then
        return
    end

    Hooked[remote] = true

    local success, connection = pcall(function()
        return remote.OnClientEvent:Connect(function(...)
            Record(remote, "OnClientEvent", {...})
        end)
    end)

    if success and connection then
        table.insert(Connections, connection)
    else
        Hooked[remote] = nil
    end
end

local function InstallHook()
    if HookInstalled then
        return true
    end

    if type(hookmetamethod) ~= "function"
        or type(getnamecallmethod) ~= "function" then
        warn("ShortName Hub: Required hook functions unavailable")
        return false
    end

    local function NamecallHook(self, ...)
        local args = {...}
        pcall(function()
            local method = getnamecallmethod()
            if Enabled and IsRemote(self)
                and (method == "FireServer" or method == "InvokeServer") then
                Record(self, method, args)
            end
        end)
        return OriginalNamecall(self, ...)
    end

    if type(newcclosure) == "function" then
        NamecallHook = newcclosure(NamecallHook)
    end

    local success, result = pcall(function()
        return hookmetamethod(
            game,
            "__namecall",
            NamecallHook
        )
    end)

    if not success then
        warn("ShortName Hub: Namecall hook failed:", result)
        return false
    end

    if type(result) ~= "function" then
        warn("ShortName Hub: Hook did not return the original namecall function")
        return false
    end
    OriginalNamecall = result
    HookInstalled = true

    return true
end

function SpyAdapter.SetLogger(LoggerModule)
    if type(LoggerModule) ~= "table" or type(LoggerModule.Record) ~= "function" then
        return false
    end
    Logger = LoggerModule
    return true
end

function SpyAdapter.GetDiagnostics()
    return {
        Enabled = Enabled,
        HookInstalled = HookInstalled,
        Captures = CaptureCount,
        LastCapture = LastCapture,
        LastError = LastError
    }
end

function SpyAdapter.Start(LoggerModule)
    if type(LoggerModule) == "table" then
        Logger = LoggerModule
    end
    if Enabled then
        return Logger ~= nil
    end

    if type(LoggerModule) ~= "table"
        or type(LoggerModule.Record) ~= "function" then
        warn("ShortName Hub: Invalid Logger module")
        return false
    end

    Logger = LoggerModule

    if not InstallHook() then
        Logger = nil
        return false
    end

    Enabled = true

    for _, instance in ipairs(game:GetDescendants()) do
        ConnectIncoming(instance)
    end

    local connection = game.DescendantAdded:Connect(function(instance)
        ConnectIncoming(instance)
    end)

    table.insert(Connections, connection)

    print("ShortName Hub: Remote Logger started!")
    return true
end

function SpyAdapter.IsRunning()
    return Enabled
end

function SpyAdapter.Stop()
    Enabled = false

    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(Connections)
    table.clear(Hooked)

    Logger = nil

    print("ShortName Hub: Remote Logger stopped!")
    return true
end

return SpyAdapter
