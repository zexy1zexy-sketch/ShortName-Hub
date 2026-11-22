
-- SHORTNAME HUB - REMOTE SPY ADAPTER

local SpyAdapter = {}

local Logger
local Enabled = false
local HookInstalled = false

local Hooked = {}
local Connections = {}
local OriginalNamecall

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

    pcall(function()
        Logger:Record(remote, method, args)
    end)
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
        local method = getnamecallmethod()

        if Enabled and IsRemote(self) then
            if method == "FireServer"
                or method == "InvokeServer" then
                Record(self, method, {...})
            end
        end

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

    OriginalNamecall = result
    HookInstalled = true

    return true
end

function SpyAdapter.Start(LoggerModule)
    if Enabled then
        return true
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
