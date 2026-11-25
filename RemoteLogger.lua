-- ShortName Hub: lightweight client-side remote/bindable call logger.
-- Outgoing calls only. No game-wide scans and no incoming-event connections.
local RemoteLogger = {}
RemoteLogger.__index = RemoteLogger

local MAX_ENTRIES = 120
local MAX_ARGUMENTS = 10
local MAX_DEPTH = 2
local HOOK_KEY = "__SHORTNAME_HUB_REMOTE_LOGGER_HOOK_V2"

local SharedEnvironment = _G
if type(getgenv) == "function" then
    local ok, env = pcall(getgenv)
    if ok and type(env) == "table" then
        SharedEnvironment = env
    end
end

local function safePath(instance)
    local ok, result = pcall(function()
        return instance:GetFullName()
    end)
    return ok and result or tostring(instance)
end

local function serialize(value, depth, budget)
    depth = depth or 0
    budget = budget or {left = MAX_ARGUMENTS}
    budget.left = budget.left - 1

    if budget.left < 0 then return "… argument limit" end
    if depth >= MAX_DEPTH then return "…" end

    local kind = typeof(value)
    if kind == "Instance" then
        return safePath(value)
    elseif kind == "table" then
        local result, count = {}, 0
        for key, item in pairs(value) do
            count = count + 1
            if count > 8 then
                result["…"] = "entries omitted"
                break
            end
            result[tostring(key)] = serialize(item, depth + 1, budget)
        end
        return result
    end

    local result = tostring(value)
    if #result > 160 then
        result = result:sub(1, 160) .. "…"
    end
    return result
end

local function isSupportedCall(method)
    return method == "FireServer"
        or method == "InvokeServer"
        or method == "Fire"
        or method == "Invoke"
end

local function classify(instance)
    local ok, result = pcall(function()
        if instance:IsA("RemoteEvent") then return "RemoteEvent" end
        if instance:IsA("UnreliableRemoteEvent") then return "UnreliableRemoteEvent" end
        if instance:IsA("RemoteFunction") then return "RemoteFunction" end
        if instance:IsA("BindableEvent") then return "BindableEvent" end
        if instance:IsA("BindableFunction") then return "BindableFunction" end
        return nil
    end)
    return ok and result or nil
end

function RemoteLogger.new()
    return setmetatable({
        Enabled = false,
        HookInstalled = false,
        Entries = {},
        Total = 0,
        Dropped = 0,
        Status = "READY",
        LastCapture = "No calls captured yet",
        _hookRegistry = nil
    }, RemoteLogger)
end

function RemoteLogger:_record(instance, method, args)
    if not self.Enabled then return end

    local className = classify(instance)
    if not className then return end

    local entry = {
        Time = os.date("%H:%M:%S"),
        Name = instance.Name,
        Path = safePath(instance),
        Class = className,
        Method = method,
        Direction = "CLIENT",
        Arguments = serialize(args or {})
    }

    if #self.Entries >= MAX_ENTRIES then
        table.remove(self.Entries, 1)
        self.Dropped = self.Dropped + 1
    end

    self.Entries[#self.Entries + 1] = entry
    self.Total = self.Total + 1
    self.LastCapture = method .. " | " .. entry.Path
end

function RemoteLogger:Start()
    if self.Enabled then
        return true, "ALREADY RUNNING"
    end

    if type(hookmetamethod) ~= "function"
        or type(getnamecallmethod) ~= "function" then
        self.Status = "UNSUPPORTED EXECUTOR: NAMECALL HOOK API MISSING"
        return false, self.Status
    end

    local registry = SharedEnvironment[HOOK_KEY]

    if type(registry) ~= "table" or registry.Installed ~= true then
        registry = {
            ActiveLogger = nil,
            Installed = false
        }

        local original
        local hook = function(target, ...)
            local method
            local methodOK = pcall(function()
                method = getnamecallmethod()
            end)

            local active = registry.ActiveLogger
            -- Filter by method first. Avoid inspecting arbitrary game objects.
            if methodOK and isSupportedCall(method)
                and active and active.Enabled then
                active:_record(target, method, {...})
            end

            return original(target, ...)
        end

        if type(newcclosure) == "function" then
            hook = newcclosure(hook)
        end

        local ok, result = pcall(function()
            return hookmetamethod(game, "__namecall", hook)
        end)

        if not ok or type(result) ~= "function" then
            self.Status = "HOOK INSTALL FAILED: " .. tostring(result)
            return false, self.Status
        end

        original = result
        registry.Installed = true
        SharedEnvironment[HOOK_KEY] = registry
    end

    registry.ActiveLogger = self
    self._hookRegistry = registry
    self.HookInstalled = true
    self.Enabled = true
    self.Status = "RUNNING — OUTGOING CALLS ONLY"

    return true, self.Status
end

function RemoteLogger:Stop()
    self.Enabled = false

    if self._hookRegistry
        and self._hookRegistry.ActiveLogger == self then
        self._hookRegistry.ActiveLogger = nil
    end

    self.Status = "STOPPED"
    return true
end

function RemoteLogger:GetEntries(limit)
    local result = {}
    local amount = math.max(1, math.min(tonumber(limit) or 20, MAX_ENTRIES))
    local first = math.max(1, #self.Entries - amount + 1)

    for index = #self.Entries, first, -1 do
        result[#result + 1] = self.Entries[index]
    end

    return result
end

function RemoteLogger:GetStats()
    local counts = {
        Total = self.Total,
        Stored = #self.Entries,
        Dropped = self.Dropped,
        MainRemote = 0,
        Other = 0
    }

    for _, entry in ipairs(self.Entries) do
        if entry.Name == "MainRemote" then
            counts.MainRemote = counts.MainRemote + 1
        else
            counts.Other = counts.Other + 1
        end
    end

    return counts
end

function RemoteLogger:GetReport()
    local lines = {
        "SHORTNAME HUB REMOTE OBSERVATION",
        "Place: " .. tostring(game.PlaceId) .. " | " .. tostring(game.Name),
        "Scope: outgoing calls made by this client only",
        "Total captured: " .. tostring(self.Total)
            .. " | Stored: " .. tostring(#self.Entries)
            .. " | Dropped: " .. tostring(self.Dropped),
        ""
    }

    for _, entry in ipairs(self:GetEntries(MAX_ENTRIES)) do
        local ok, encoded = pcall(function()
            return game:GetService("HttpService"):JSONEncode(entry.Arguments)
        end)

        lines[#lines + 1] = "[" .. entry.Time .. "] CLIENT "
            .. entry.Class .. "." .. entry.Method .. " | " .. entry.Path
            .. "\nArgs: " .. (ok and encoded or tostring(entry.Arguments))
    end

    return table.concat(lines, "\n")
end

function RemoteLogger:Clear()
    table.clear(self.Entries)
    self.Total = 0
    self.Dropped = 0
    self.LastCapture = "No calls captured yet"
    return true
end

return RemoteLogger
