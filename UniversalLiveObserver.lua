-- UniversalLiveObserver.lua
-- Lightweight, passive observer for client-visible UI text and ValueBase changes.
-- It never invokes remotes, reads script source, or watches text-entry/chat fields.

local Observer = {}
Observer.__index = Observer

local Players = game:GetService("Players")
local MAX_WATCHED = 350
local MAX_LOG = 120
local YIELD_EVERY = 100
local EXCLUDED = {"chat", "message", "input", "password", "token", "secret", "email", "textbox"}

local function safeGet(instance, property)
    local ok, value = pcall(function() return instance[property] end)
    if ok then return value end
    return nil
end

local function clean(value, limit)
    local text = tostring(value == nil and "nil" or value):gsub("[%c]", " ")
    return text:sub(1, limit or 100)
end

local function isExcludedPath(path)
    local lower = string.lower(path)
    for _, term in ipairs(EXCLUDED) do
        if string.find(lower, term, 1, true) then return true end
    end
    return false
end

local function watchedProperty(instance)
    local ok, isValue = pcall(function() return instance:IsA("ValueBase") end)
    if ok and isValue then return "Value" end
    local className = tostring(safeGet(instance, "ClassName") or "")
    if className == "TextLabel" or className == "TextButton" then
        return "Text"
    end
    return nil
end

function Observer.new()
    return setmetatable({
        _running = false,
        _scanId = 0,
        _connections = {},
        _watched = {},
        _log = {},
        _count = 0,
        _report = "No live observation started yet."
    }, Observer)
end

function Observer:GetCount()
    return self._count
end

function Observer:GetReport()
    local player = Players.LocalPlayer
    local lines = {
        "SHORTNAME HUB - UNIVERSAL LIVE CHANGE OBSERVATION",
        "Mode: PASSIVE / READ-ONLY",
        "Game: " .. clean(game.Name, 80),
        "PlaceId: " .. tostring(game.PlaceId),
        "UniverseId: " .. tostring(game.GameId),
        "Player: " .. clean(player and player.Name or "Unknown", 40),
        "Watched properties: " .. tostring(self._count),
        "Recorded changes: " .. tostring(#self._log),
        "Status: " .. (self._running and "RUNNING" or "STOPPED"),
        "----------------------------------------",
        "RECENT CHANGES (OLDEST FIRST)"
    }
    if #self._log == 0 then
        table.insert(lines, "No changes captured yet.")
    else
        for i, entry in ipairs(self._log) do
            table.insert(lines, tostring(i) .. ". " .. entry)
        end
    end
    table.insert(lines, "")
    table.insert(lines, "Privacy/safety: TextBox, chat, message, input, password, token, secret, and email paths are excluded.")
    table.insert(lines, "This observer does not inspect server-only objects, script source, remote traffic, or remote arguments.")
    self._report = table.concat(lines, "\n")
    return self._report
end

function Observer:Clear()
    table.clear(self._log)
    return true
end

function Observer:Stop()
    self._running = false
    self._scanId += 1
    for _, connection in ipairs(self._connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(self._connections)
    table.clear(self._watched)
    return true
end

function Observer:Start(onUpdate)
    if self._running then return "ALREADY OBSERVING" end
    local player = Players.LocalPlayer
    local playerGui = player and safeGet(player, "PlayerGui")
    if not playerGui then return "PLAYER GUI NOT AVAILABLE" end

    self:Stop()
    self._running = true
    self._scanId += 1
    local scanId = self._scanId
    table.clear(self._log)
    self._count = 0

    local function notify(status)
        if type(onUpdate) == "function" then
            pcall(onUpdate, status, self._count, #self._log)
        end
    end

    local function attach(instance)
        if not self._running or self._scanId ~= scanId then return end
        if self._count >= MAX_WATCHED or self._watched[instance] then return end
        local property = watchedProperty(instance)
        if not property then return end
        local path
        local okPath, result = pcall(function() return instance:GetFullName() end)
        path = okPath and result or clean(safeGet(instance, "Name") or "Unknown", 80)
        if isExcludedPath(path) then return end

        local initial = safeGet(instance, property)
        self._watched[instance] = {property = property, path = path, last = initial, lastAt = 0}
        self._count += 1
        local ok, connection = pcall(function()
            return instance:GetPropertyChangedSignal(property):Connect(function()
                if not self._running or self._scanId ~= scanId then return end
                local record = self._watched[instance]
                if not record then return end
                local now = os.clock()
                if now - record.lastAt < 0.2 then return end
                local current = safeGet(instance, property)
                if current == record.last then return end
                local oldText = clean(record.last, 80)
                local newText = clean(current, 80)
                record.last = current
                record.lastAt = now
                local entry = os.date("%H:%M:%S") .. " [" .. tostring(safeGet(instance, "ClassName") or "Instance")
                    .. "] " .. record.path .. " | " .. property .. ": " .. oldText .. " -> " .. newText
                table.insert(self._log, entry)
                while #self._log > MAX_LOG do table.remove(self._log, 1) end
                notify("CHANGE DETECTED")
            end)
        end)
        if ok and connection then
            table.insert(self._connections, connection)
        end
    end

    notify("SCANNING PLAYER UI")
    task.spawn(function()
        local ok, descendants = pcall(function() return playerGui:GetDescendants() end)
        if ok and type(descendants) == "table" then
            for index, instance in ipairs(descendants) do
                if not self._running or self._scanId ~= scanId then return end
                attach(instance)
                if index % YIELD_EVERY == 0 then
                    notify("MAPPING UI / VALUES")
                    task.wait(0.03)
                end
                if self._count >= MAX_WATCHED then break end
            end
        end

        if not self._running or self._scanId ~= scanId then return end
        local addedOk, addedConnection = pcall(function()
            return playerGui.DescendantAdded:Connect(attach)
        end)
        if addedOk and addedConnection then
            table.insert(self._connections, addedConnection)
        end
        notify("OBSERVING " .. tostring(self._count) .. " PROPERTIES")
    end)

    return "OBSERVATION STARTED"
end

return Observer
