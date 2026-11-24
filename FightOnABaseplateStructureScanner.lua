-- UniversalStructureScanner.lua (legacy filename)
-- Lightweight, read-only game discovery. Prioritizes player data/UI and network
-- folders, skips bulky asset/admin-command trees, and never invokes remotes.

local Scanner = {}
Scanner.__index = Scanner

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")

local MAX_SCAN = 18000
local MAX_REMOTE = 250
local MAX_MODULE = 180
local MAX_MATCH = 250
local MAX_VALUE = 350
local MAX_UI = 220
local YIELD_EVERY = 200

local TERMS = {
    "currency","coin","cash","money","oof","rune","enchant","upgrade","prestige",
    "noob","mineral","ore","pickaxe","shovel","mine","mining","capsule","minion",
    "realm","trial","wave","boss","mob","damage","health","weapon","sword",
    "scythe","quest","reward","inventory","playerdata","profile","data","tree",
    "star","chip","turkey","thanksgiving","pumpkin","harvest","rank","level",
    "shop","collect","claim","teleport","spawn","prompt","interact","controller",
    "service","manager","config","system","network","remote","replicate"
}

local function safe(instance, property, fallback)
    local ok, value = pcall(function() return instance[property] end)
    if ok then return value end
    return fallback
end

local function pathOf(instance)
    local ok, value = pcall(function() return instance:GetFullName() end)
    return ok and value or tostring(safe(instance, "Name", "Unknown"))
end

local function containsTerm(value)
    local lower = string.lower(tostring(value or ""))
    for _, term in ipairs(TERMS) do
        if string.find(lower, term, 1, true) then return term end
    end
    return nil
end

local function isRemote(className)
    return className == "RemoteEvent" or className == "RemoteFunction"
        or className == "UnreliableRemoteEvent"
end

local function isValue(className)
    return className == "StringValue" or className == "BoolValue"
        or className == "IntValue" or className == "NumberValue"
end

local function isUiText(className)
    return className == "TextLabel" or className == "TextButton"
        or className == "TextBox"
end

local function cleanText(value, limit)
    local text = tostring(value or ""):gsub("[%c]", " ")
    return text:sub(1, limit or 120)
end

local function shouldSkipPath(path)
    return string.find(path, ".Assets.", 1, true) ~= nil
        or string.find(path, ".CmdrClient.", 1, true) ~= nil
end

function Scanner.new()
    return setmetatable({
        _running = false,
        _scanId = 0,
        _report = "No universal discovery scan run yet.",
        _count = 0,
        _scanned = 0
    }, Scanner)
end

function Scanner:GetReport() return self._report end
function Scanner:GetCount() return self._count end

function Scanner:Clear()
    self._report = "No universal discovery scan run yet."
    self._count = 0
    self._scanned = 0
    return true
end

function Scanner:Stop()
    self._running = false
    self._scanId += 1
    return true
end

function Scanner:Start(onUpdate)
    if self._running then return "ALREADY SCANNING" end
    self:Clear()
    self._running = true
    self._scanId += 1
    local scanId = self._scanId

    task.spawn(function()
        local player = Players.LocalPlayer
        local roots = {}
        local function addRoot(instance)
            if instance then table.insert(roots, instance) end
        end

        -- High-value, smaller roots first.
        if player then
            addRoot(safe(player, "PlayerGui"))
            addRoot(safe(player, "PlayerScripts"))
            addRoot(safe(player, "Backpack"))
            addRoot(safe(player, "Character"))
        end
        addRoot(safe(ReplicatedStorage, "__Net"))
        addRoot(safe(ReplicatedStorage, "Framework"))
        addRoot(ReplicatedStorage)
        addRoot(ReplicatedFirst)
        addRoot(Workspace)
        addRoot(StarterGui)
        addRoot(StarterPlayer)

        local remotes, modules, matches, values, ui, prompts = {}, {}, {}, {}, {}, {}
        local seen = {}
        local scanned = 0

        local function notify(status)
            if type(onUpdate) == "function" then
                pcall(onUpdate, status, scanned)
            end
        end

        local function record(item)
            local className = tostring(safe(item, "ClassName", "Unknown"))
            local name = tostring(safe(item, "Name", "Unknown"))
            local path = pathOf(item)
            if shouldSkipPath(path) then return end

            if isRemote(className) and #remotes < MAX_REMOTE then
                table.insert(remotes, "[" .. className .. "] " .. path)
            elseif className == "ModuleScript" and #modules < MAX_MODULE then
                local term = containsTerm(name) or containsTerm(path)
                if term then
                    table.insert(modules, "[" .. className .. "] term=" .. term .. " | " .. path)
                end
            end

            local term = containsTerm(name) or containsTerm(path)
            if term and #matches < MAX_MATCH then
                table.insert(matches, "[" .. className .. "] term=" .. term .. " | " .. path)
            end

            if isValue(className) and #values < MAX_VALUE then
                local value = safe(item, "Value", "")
                local lowerName = string.lower(name)
                if string.find(lowerName, "token", 1, true)
                    or string.find(lowerName, "secret", 1, true)
                    or string.find(lowerName, "password", 1, true)
                    or string.find(lowerName, "key", 1, true) then
                    value = "[REDACTED]"
                elseif type(value) == "string" then
                    value = cleanText(value, 100)
                end
                table.insert(values, "[" .. className .. "] " .. path .. " = " .. tostring(value))
            end

            if isUiText(className) and #ui < MAX_UI then
                local text = cleanText(safe(item, "Text", ""), 120)
                if text ~= "" then
                    table.insert(ui, "[" .. className .. "] " .. path .. " | " .. text)
                end
            end

            if (className == "ProximityPrompt" or className == "ClickDetector") and #prompts < 180 then
                local action = cleanText(safe(item, "ActionText", ""), 60)
                local object = cleanText(safe(item, "ObjectText", ""), 60)
                table.insert(prompts, "[" .. className .. "] " .. path
                    .. " | Action=" .. action .. " | Object=" .. object)
            end
        end

        notify("SCANNING PLAYER UI / DATA")
        for _, root in ipairs(roots) do
            if not self._running or self._scanId ~= scanId then return end
            local stack = {}
            local ok, children = pcall(function() return root:GetChildren() end)
            if ok and children then
                for i = #children, 1, -1 do table.insert(stack, children[i]) end
            end

            while #stack > 0 do
                if not self._running or self._scanId ~= scanId then return end
                local item = table.remove(stack)
                if item and not seen[item] then
                    seen[item] = true
                    scanned += 1
                    record(item)

                    local path = pathOf(item)
                    if not shouldSkipPath(path) then
                        local childOk, childList = pcall(function() return item:GetChildren() end)
                        if childOk and childList then
                            for i = #childList, 1, -1 do
                                table.insert(stack, childList[i])
                            end
                        end
                    end

                    if scanned % YIELD_EVERY == 0 then
                        notify("SCANNING")
                        task.wait(0.03)
                    end
                    if scanned >= MAX_SCAN then break end
                end
            end
            if scanned >= MAX_SCAN then break end
        end

        if not self._running or self._scanId ~= scanId then return end
        self._running = false

        local lines = {
            "SHORTNAME HUB - UNIVERSAL GAME DISCOVERY REPORT",
            "Mode: PASSIVE / READ-ONLY",
            "Game: " .. tostring(safe(game, "Name", "Unknown")),
            "PlaceId: " .. tostring(safe(game, "PlaceId", "Unknown")),
            "UniverseId: " .. tostring(safe(game, "GameId", "Unknown")),
            "Player: " .. tostring(player and player.Name or "Unknown"),
            "Objects inspected: " .. tostring(scanned),
            "Scan limit: " .. tostring(MAX_SCAN),
            "Remote objects: " .. tostring(#remotes),
            "Relevant modules: " .. tostring(#modules),
            "System matches: " .. tostring(#matches),
            "Value objects: " .. tostring(#values),
            "Visible UI text entries: " .. tostring(#ui),
            "Interactable prompts: " .. tostring(#prompts),
            "----------------------------------------",
            "REMOTE INVENTORY (NAMES / PATHS ONLY)"
        }
        for i, item in ipairs(remotes) do table.insert(lines, tostring(i) .. ". " .. item) end
        if #remotes == 0 then table.insert(lines, "No client-visible remotes found.") end

        table.insert(lines, "")
        table.insert(lines, "RELEVANT MODULE INVENTORY (SOURCE NOT READ)")
        for i, item in ipairs(modules) do table.insert(lines, tostring(i) .. ". " .. item) end

        table.insert(lines, "")
        table.insert(lines, "PROGRESSION / SYSTEM PATH MATCHES")
        for i, item in ipairs(matches) do table.insert(lines, tostring(i) .. ". " .. item) end

        table.insert(lines, "")
        table.insert(lines, "VISIBLE VALUE OBJECTS")
        for i, item in ipairs(values) do table.insert(lines, tostring(i) .. ". " .. item) end

        table.insert(lines, "")
        table.insert(lines, "VISIBLE UI TEXT")
        for i, item in ipairs(ui) do table.insert(lines, tostring(i) .. ". " .. item) end

        table.insert(lines, "")
        table.insert(lines, "INTERACTABLES")
        for i, item in ipairs(prompts) do table.insert(lines, tostring(i) .. ". " .. item) end

        table.insert(lines, "")
        table.insert(lines, "COVERAGE / SAFETY")
        table.insert(lines, "- Prioritizes PlayerGui, PlayerScripts, Backpack, Character, and ReplicatedStorage network folders.")
        table.insert(lines, "- Large replicated asset folders and CmdrClient command-definition folders are skipped to reduce noise.")
        table.insert(lines, "- No remote or bindable is invoked; no script source is read or executed.")
        table.insert(lines, "- Only client-visible objects are inspected; server-only logic and data are unavailable.")
        table.insert(lines, "- String values with token/secret/password/key names are redacted.")
        table.insert(lines, "- A reached scan limit means later objects may not be included.")
        self._scanned = scanned
        self._count = #remotes + #modules + #matches + #values + #ui + #prompts
        self._report = table.concat(lines, "\n")
        if #self._report > 90000 then
            self._report = string.sub(self._report, 1, 89000) .. "\n[REPORT TRUNCATED TO STAY WITHIN UPLOAD SIZE LIMIT]"
        end
        notify(scanned >= MAX_SCAN and "SCAN LIMIT REACHED" or "SCAN COMPLETE")
    end)
    return "SCANNING"
end

function Scanner:UploadReport(uploadKey)
    if type(uploadKey) ~= "string" or uploadKey == "" then
        return false, "UPLOAD KEY REQUIRED"
    end
    local requestFunction
    if type(request) == "function" then
        requestFunction = request
    elseif type(http_request) == "function" then
        requestFunction = http_request
    elseif syn and type(syn.request) == "function" then
        requestFunction = syn.request
    elseif http and type(http.request) == "function" then
        requestFunction = http.request
    elseif fluxus and type(fluxus.request) == "function" then
        requestFunction = fluxus.request
    end
    if not requestFunction then return false, "HTTP REQUEST API UNAVAILABLE" end

    local HttpService = game:GetService("HttpService")
    local payload = HttpService:JSONEncode({ report = self:GetReport() })
    local ok, response = pcall(function()
        return requestFunction({
            Url = "https://shortname-report-receive.ryft-amv.workers.dev/upload",
            Method = "POST",
            Timeout = 45,
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-upload-key"] = uploadKey
            },
            Body = payload
        })
    end)
    if not ok then return false, "REQUEST FAILED: " .. tostring(response) end
    if type(response) ~= "table" then return false, "INVALID RESPONSE FROM UPLOAD SERVER" end
    local statusCode = response.StatusCode or response.Status or response.status_code
    local responseBody = response.Body or response.body or ""
    if statusCode ~= 200 then
        return false, "HTTP " .. tostring(statusCode) .. ": " .. tostring(responseBody)
    end
    local decodeOk, decoded = pcall(function() return HttpService:JSONDecode(responseBody) end)
    if not decodeOk or type(decoded) ~= "table" or decoded.ok ~= true or decoded.github ~= "saved" then
        return false, "SERVER DID NOT CONFIRM GITHUB SAVE: " .. tostring(responseBody)
    end
    return true, "UNIVERSAL DISCOVERY REPORT UPLOADED TO GITHUB"
end

return Scanner
