-- ThanksgivingScanner.lua
-- Read-only event scanner. It inspects client-visible instances only.
-- It does not fire remotes, purchase items, or modify game state.

local Scanner = {}
Scanner.__index = Scanner

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Workspace = game:GetService("Workspace")

local KEYWORDS = {
    "thanksgiving", "turkey", "harvest", "feast", "corn", "pumpkin",
    "cranberry", "stuffing", "autumn", "pilgrim", "gravy", "gobble",
    "thankful", "fall event", "thanksgiving event", "hidden turkey",
    "milestone", "event quest", "event shop", "event reward"
}

local MAX_RESULTS = 500
local MAX_SCANNED_OBJECTS = 50000
local YIELD_EVERY = 250

-- These UI helper classes often contain keyword-like names but are not
-- useful game objects (for example, UICorner accidentally matching "corn").
local IGNORED_CLASSES = {
    UICorner = true,
    UIStroke = true,
    UIPadding = true,
    UIListLayout = true,
    UIGridLayout = true,
    UIPageLayout = true,
    UIAspectRatioConstraint = true,
    UISizeConstraint = true,
    UIGradient = true,
    UIFlexItem = true,
    UITextSizeConstraint = true,
}

local function safeGet(instance, property, fallback)
    local ok, value = pcall(function()
        return instance[property]
    end)
    if ok then
        return value
    end
    return fallback
end

local function safeFullName(instance)
    local ok, result = pcall(function()
        return instance:GetFullName()
    end)
    return ok and result or safeGet(instance, "Name", "Unknown")
end

local function safeText(instance)
    local className = safeGet(instance, "ClassName", "")
    if className == "TextLabel" or className == "TextButton" or className == "TextBox" then
        local value = safeGet(instance, "Text", "")
        return type(value) == "string" and value or ""
    end
    return ""
end

local function findKeyword(value)
    if type(value) ~= "string" or value == "" then
        return nil
    end
    local lowered = string.lower(value)
    for _, keyword in ipairs(KEYWORDS) do
        if string.find(lowered, keyword, 1, true) then
            return keyword
        end
    end
    return nil
end

local function getRecordType(className)
    if className == "RemoteEvent" then return "REMOTE EVENT" end
    if className == "RemoteFunction" then return "REMOTE FUNCTION" end
    if className == "BindableEvent" then return "BINDABLE EVENT" end
    if className == "BindableFunction" then return "BINDABLE FUNCTION" end
    if className == "ModuleScript" then return "MODULE SCRIPT" end
    if className == "LocalScript" then return "LOCAL SCRIPT" end
    if className == "Script" then return "SCRIPT" end
    return className
end

local function isRemote(className)
    return className == "RemoteEvent"
        or className == "RemoteFunction"
        or className == "BindableEvent"
        or className == "BindableFunction"
end

local function isScript(className)
    return className == "ModuleScript"
        or className == "LocalScript"
        or className == "Script"
end

function Scanner.new()
    local self = setmetatable({}, Scanner)
    self._running = false
    self._results = {}
    self._seen = {}
    self._scanned = 0
    self._remoteCount = 0
    self._scriptCount = 0
    self._scanId = 0
    return self
end

function Scanner:GetCount()
    return #self._results
end

function Scanner:GetReport()
    local lines = {
        "SHORTNAME HUB - THANKSGIVING SCAN REPORT",
        "Results: " .. tostring(#self._results),
        "Objects inspected: " .. tostring(self._scanned),
        "Remote objects found: " .. tostring(self._remoteCount),
        "Script/module objects found: " .. tostring(self._scriptCount),
        "Scan limit: " .. tostring(MAX_SCANNED_OBJECTS),
        "----------------------------------------",
    }

    for index, result in ipairs(self._results) do
        table.insert(lines, string.format(
            "%d. [%s] (%s) %s",
            index,
            result.keyword or "event object",
            result.className,
            result.path
        ))
        if result.text and result.text ~= "" then
            table.insert(lines, "   Text: " .. result.text)
        end
    end

    if #self._results == 0 then
        table.insert(lines, "No matching event objects or remote objects were found.")
    end

    table.insert(lines, "----------------------------------------")
    table.insert(lines, "Notes:")
    table.insert(lines, "- Remote objects are listed by name and path only; they are not called.")
    table.insert(lines, "- Script source is not read or executed.")
    table.insert(lines, "- Only client-visible/locally replicated content can be found.")
    return table.concat(lines, "\n")
end

function Scanner:Clear()
    self._results = {}
    self._seen = {}
    self._scanned = 0
    self._remoteCount = 0
    self._scriptCount = 0
    return true
end

function Scanner:Stop()
    self._running = false
    self._scanId += 1
    self:ClearTurkeyHighlights()
    return true
end

function Scanner:Start(onUpdate)
    if self._running then
        return "ALREADY SCANNING"
    end

    self:Clear()
    self._running = true
    self._scanId += 1
    local thisScan = self._scanId

    local function notify(status)
        if type(onUpdate) == "function" then
            pcall(onUpdate, status, #self._results)
        end
    end

    local roots = { Workspace, ReplicatedStorage, ReplicatedFirst }
    local player = Players.LocalPlayer
    if player then
        local playerGui = safeGet(player, "PlayerGui")
        if playerGui then
            table.insert(roots, playerGui)
        end
    end

    task.spawn(function()
        notify("SCANNING")
        for _, root in ipairs(roots) do
            if not self._running or self._scanId ~= thisScan then
                return
            end

            local ok, descendants = pcall(function()
                return root:GetDescendants()
            end)

            if ok and descendants then
                for _, instance in ipairs(descendants) do
                    if not self._running or self._scanId ~= thisScan then
                        return
                    end

                    self._scanned += 1
                    local name = safeGet(instance, "Name", "")
                    local className = safeGet(instance, "ClassName", "Unknown")
                    local path = safeFullName(instance)
                    local visibleText = safeText(instance)
                    local ignored = IGNORED_CLASSES[className] == true
                    local keyword

                    if not ignored then
                        keyword = findKeyword(name)
                            or findKeyword(visibleText)
                            or findKeyword(path)
                    end

                    local remote = isRemote(className)
                    local scriptObject = isScript(className)

                    if remote then
                        self._remoteCount += 1
                    elseif scriptObject and keyword then
                        self._scriptCount += 1
                    end

                    -- Include all discovered remote/bindable objects so their
                    -- exact names can be reviewed, plus event-related objects.
                    local shouldRecord = remote or (keyword ~= nil)
                    if shouldRecord and not self._seen[path] then
                        self._seen[path] = true
                        local record = {
                            keyword = keyword or (remote and "remote"),
                            className = getRecordType(className),
                            path = path,
                            text = visibleText,
                        }

                        if remote or scriptObject then
                            -- Prioritize remotes and event-related scripts/modules
                            -- so ordinary keyword matches cannot hide useful entries.
                            if remote then
                                table.insert(self._results, 1, record)
                                notify("REMOTE FOUND")
                            else
                                local insertAt = math.min(self._remoteCount + 1, #self._results + 1)
                                table.insert(self._results, insertAt, record)
                                notify("SCRIPT/MODULE FOUND")
                            end

                            if #self._results > MAX_RESULTS then
                                table.remove(self._results)
                            end
                        elseif #self._results < MAX_RESULTS then
                            table.insert(self._results, record)
                            notify("EVENT MATCH FOUND")
                        end
                    end

                    if self._scanned >= MAX_SCANNED_OBJECTS then
                        self._running = false
                        notify("SCAN LIMIT REACHED")
                        return
                    end

                    if self._scanned % YIELD_EVERY == 0 then
                        notify("SCANNING")
                        task.wait()
                    end

                end
            end
        end

        if self._scanId == thisScan then
            self._running = false
            notify("SCAN COMPLETE")
        end
    end)

    return "SCANNING"
end


-- Upload the current report to the ShortName Hub Cloudflare receiver.
-- The upload key is supplied at runtime through the GUI and is not stored in this file.
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

    if not requestFunction then
        return false, "HTTP REQUEST API UNAVAILABLE"
    end

    local HttpService = game:GetService("HttpService")
    local payload = HttpService:JSONEncode({
        report = self:GetReport()
    })

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

    if not ok then
        return false, "REQUEST FAILED: " .. tostring(response)
    end

    if type(response) ~= "table" then
        return false, "INVALID RESPONSE FROM UPLOAD SERVER"
    end

    local statusCode = response.StatusCode or response.Status or response.status_code
    local responseBody = response.Body or response.body or ""

    if statusCode ~= 200 then
        return false, "HTTP " .. tostring(statusCode) .. ": " .. tostring(responseBody)
    end

    local decodeOk, decoded = pcall(function()
        return HttpService:JSONDecode(responseBody)
    end)

    if not decodeOk or type(decoded) ~= "table" or decoded.ok ~= true or decoded.github ~= "saved" then
        return false, "SERVER DID NOT CONFIRM GITHUB SAVE: " .. tostring(responseBody)
    end

    return true, "UPLOADED TO GITHUB"
end


-- Turkey Finder: locate client-visible turkey objects without changing game state.
local function turkeyPosition(instance)
    local className = safeGet(instance, "ClassName", "")
    if className == "Model" then
        local ok, pivot = pcall(function() return instance:GetPivot() end)
        if ok then return pivot.Position end
    elseif className == "BasePart" then
        return safeGet(instance, "Position")
    end
    return nil
end

function Scanner:ScanTurkeys()
    self:ClearTurkeyHighlights()
    self._turkeyResults = {}
    local seen = {}
    local ok, descendants = pcall(function() return Workspace:GetDescendants() end)
    if not ok or type(descendants) ~= "table" then
        return false, "Could not inspect Workspace"
    end
    for _, instance in ipairs(descendants) do
        local name = safeGet(instance, "Name", "")
        local className = safeGet(instance, "ClassName", "")
        local lower = string.lower(tostring(name))
        if string.find(lower, "turkey", 1, true) and (className == "Model" or className == "BasePart") then
            local path = safeFullName(instance)
            if not seen[path] and #self._turkeyResults < 30 then
                seen[path] = true
                table.insert(self._turkeyResults, {
                    name = tostring(name),
                    path = path,
                    instance = instance,
                    position = turkeyPosition(instance),
                })
            end
        end
    end
    table.sort(self._turkeyResults, function(a, b)
        return string.lower(a.path) < string.lower(b.path)
    end)
    return true, #self._turkeyResults
end

function Scanner:GetTurkeyResults()
    return self._turkeyResults or {}
end

function Scanner:GetTurkeyReport()
    local results = self._turkeyResults or {}
    local lines = {
        "SHORTNAME HUB - THANKSGIVING TURKEY FINDER",
        "Located: " .. tostring(#results) .. "/30",
        "Note: located means the object is visible to the client; it does not confirm collection.",
        "----------------------------------------",
    }
    for i, result in ipairs(results) do
        table.insert(lines, string.format("%02d. %s | %s", i, result.name, result.path))
    end
    if #results == 0 then
        table.insert(lines, "No client-visible objects with 'turkey' in their name were found.")
    end
    return table.concat(lines, "\n")
end

function Scanner:HighlightTurkeys()
    self:ClearTurkeyHighlights()
    self._turkeyHighlights = {}
    for _, result in ipairs(self._turkeyResults or {}) do
        local instance = result.instance
        if instance and instance.Parent then
            local ok, highlight = pcall(function()
                local item = Instance.new("Highlight")
                item.Name = "ShortNameTurkeyHighlight"
                item.Adornee = instance
                item.FillColor = Color3.fromRGB(255, 190, 55)
                item.OutlineColor = Color3.fromRGB(255, 245, 190)
                item.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                item.Parent = Workspace
                return item
            end)
            if ok and highlight then table.insert(self._turkeyHighlights, highlight) end
        end
    end
    return #self._turkeyHighlights
end

function Scanner:ClearTurkeyHighlights()
    for _, highlight in ipairs(self._turkeyHighlights or {}) do
        pcall(function() highlight:Destroy() end)
    end
    self._turkeyHighlights = {}
    return true
end


return Scanner
