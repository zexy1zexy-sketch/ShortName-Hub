-- ShortName Hub: bounded, passive client-side remote/bindable call logger.
-- Captures calls made by this client only; it cannot see server-only or other clients' traffic.
local RemoteLogger = {}
RemoteLogger.__index = RemoteLogger

local MAX_ENTRIES = 250
local MAX_ARGUMENTS = 24
local MAX_DEPTH = 3

local function safePath(instance)
    local ok, result = pcall(function() return instance:GetFullName() end)
    return ok and result or tostring(instance)
end

local function serialize(value, depth, budget)
    depth = depth or 0
    budget = budget or {left = MAX_ARGUMENTS}
    budget.left = budget.left - 1
    if budget.left < 0 then return "… argument limit" end
    if depth >= MAX_DEPTH then return "…" end
    local kind = typeof(value)
    if kind == "Instance" then return safePath(value) end
    if kind == "table" then
        local result, n = {}, 0
        for key, item in pairs(value) do
            n = n + 1
            if n > 20 then result["…"] = "more entries omitted"; break end
            result[tostring(key)] = serialize(item, depth + 1, budget)
        end
        return result
    end
    local result = tostring(value)
    if #result > 240 then result = result:sub(1, 240) .. "…" end
    return result
end

local function classify(instance)
    for _, className in ipairs({
        "UnreliableRemoteEvent", "RemoteEvent", "RemoteFunction",
        "BindableEvent", "BindableFunction"
    }) do
        local ok, matches = pcall(function() return instance:IsA(className) end)
        if ok and matches then return className end
    end
    return nil
end

function RemoteLogger.new()
    return setmetatable({
        Enabled = false,
        HookInstalled = false,
        Entries = {},
        Total = 0,
        Dropped = 0,
        Connections = {},
        Connected = {},
        Status = "READY",
        LastCapture = "No calls captured yet",
        _scanGeneration = 0
    }, RemoteLogger)
end

function RemoteLogger:_record(instance, method, args, direction)
    if not self.Enabled then return end
    local className = classify(instance)
    if not className then return end
    local entry = {
        Time = os.date("%H:%M:%S"),
        Name = instance.Name,
        Path = safePath(instance),
        Class = className,
        Method = method,
        Direction = direction or "CLIENT",
        Arguments = serialize(args or {})
    }
    if #self.Entries >= MAX_ENTRIES then
        table.remove(self.Entries, 1)
        self.Dropped = self.Dropped + 1
    end
    table.insert(self.Entries, entry)
    self.Total = self.Total + 1
    self.LastCapture = method .. " | " .. entry.Path
end

function RemoteLogger:_watchIncoming(instance)
    if self.Connected[instance] then return end
    local className = classify(instance)
    if className ~= "RemoteEvent" and className ~= "UnreliableRemoteEvent" then return end
    self.Connected[instance] = true
    local ok, connection = pcall(function()
        return instance.OnClientEvent:Connect(function(...)
            self:_record(instance, "OnClientEvent", {...}, "SERVER → CLIENT")
        end)
    end)
    if ok and connection then
        table.insert(self.Connections, connection)
    else
        self.Connected[instance] = nil
    end
end

function RemoteLogger:Start()
    if self.Enabled then return true, "ALREADY RUNNING" end
    if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then
        self.Status = "UNSUPPORTED EXECUTOR: NAMECALL HOOK API MISSING"
        return false, self.Status
    end

    if not self.HookInstalled then
        local original
        local hook = function(target, ...)
            local method
            pcall(function() method = getnamecallmethod() end)
            if self.Enabled and classify(target) then
                if method == "FireServer" or method == "InvokeServer"
                    or method == "Fire" or method == "Invoke" then
                    self:_record(target, method, {...}, "CLIENT")
                end
            end
            return original(target, ...)
        end
        if type(newcclosure) == "function" then hook = newcclosure(hook) end
        local ok, result = pcall(function()
            return hookmetamethod(game, "__namecall", hook)
        end)
        if not ok or type(result) ~= "function" then
            self.Status = "HOOK INSTALL FAILED: " .. tostring(result)
            return false, self.Status
        end
        original = result
        self.HookInstalled = true
    end

    self.Enabled = true
    self._scanGeneration = self._scanGeneration + 1
    local generation = self._scanGeneration
    self.Status = "STARTING"
    task.spawn(function()
        local descendants = game:GetDescendants()
        for index, instance in ipairs(descendants) do
            if not self.Enabled or generation ~= self._scanGeneration then return end
            self:_watchIncoming(instance)
            if index % 180 == 0 then task.wait() end
        end
        if self.Enabled and generation == self._scanGeneration then
            self.Status = "RUNNING"
        end
    end)
    local addedConnection = game.DescendantAdded:Connect(function(instance)
        if self.Enabled then self:_watchIncoming(instance) end
    end)
    table.insert(self.Connections, addedConnection)
    return true, "STARTING (INITIAL REMOTE ATTACHMENT IS CHUNKED)"
end

function RemoteLogger:Stop()
    self.Enabled = false
    self._scanGeneration = self._scanGeneration + 1
    for _, connection in ipairs(self.Connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(self.Connections)
    table.clear(self.Connected)
    self.Status = "STOPPED"
    return true
end

function RemoteLogger:GetEntries(limit)
    local result = {}
    local first = math.max(1, #self.Entries - (tonumber(limit) or 20) + 1)
    for index = #self.Entries, first, -1 do
        table.insert(result, self.Entries[index])
    end
    return result
end

function RemoteLogger:GetStats()
    local counts = {Total = self.Total, Stored = #self.Entries, Dropped = self.Dropped, MainRemote = 0, Other = 0}
    for _, entry in ipairs(self.Entries) do
        if entry.Name == "MainRemote" then counts.MainRemote = counts.MainRemote + 1
        else counts.Other = counts.Other + 1 end
    end
    return counts
end

function RemoteLogger:GetReport()
    local lines = {
        "SHORTNAME HUB REMOTE OBSERVATION",
        "Place: " .. tostring(game.PlaceId) .. " | " .. tostring(game.Name),
        "Scope: calls made by this client + RemoteEvent/UnreliableRemoteEvent deliveries to this client",
        "Total captured: " .. tostring(self.Total) .. " | Stored: " .. tostring(#self.Entries) .. " | Oldest dropped: " .. tostring(self.Dropped),
        ""
    }
    for _, entry in ipairs(self:GetEntries(MAX_ENTRIES)) do
        local ok, encoded = pcall(function()
            return game:GetService("HttpService"):JSONEncode(entry.Arguments)
        end)
        table.insert(lines, "[" .. entry.Time .. "] " .. entry.Direction .. " " .. entry.Class .. "." .. entry.Method .. " | " .. entry.Path .. "\nArgs: " .. (ok and encoded or tostring(entry.Arguments)))
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
