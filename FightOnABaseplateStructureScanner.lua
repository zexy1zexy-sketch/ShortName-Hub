-- FightOnABaseplateStructureScanner.lua
-- Passive inventory of client-visible combat-related instances and remotes.
-- Never reads/executes script source and never invokes any remote or bindable.

local Scanner = {}
Scanner.__index = Scanner

local roots = {
    game:GetService("ReplicatedStorage"),
    game:GetService("ReplicatedFirst"),
    game:GetService("Workspace"),
}

local TERMS = {
    "combat", "fight", "attack", "hitbox", "hurtbox", "damage", "melee",
    "weapon", "sword", "punch", "kick", "block", "parry", "guard",
    "stun", "ragdoll", "knockback", "dash", "dodge", "roll", "combo",
    "cooldown", "ability", "skill", "ultimate", "lockon", "lock on",
    "target", "aim", "projectile", "bullet", "health", "shield",
    "arm", "swing", "slash", "hit", "anim", "replicate", "packet"
}
local MAX_SCAN = 50000
local MAX_REMOTE = 300
local MAX_MATCH = 400
local YIELD_EVERY = 300

local function safe(instance, property, fallback)
    local ok, value = pcall(function() return instance[property] end)
    return ok and value or fallback
end

local function pathOf(instance)
    local ok, value = pcall(function() return instance:GetFullName() end)
    return ok and value or tostring(safe(instance, "Name", "Unknown"))
end

local function hasTerm(value)
    value = string.lower(tostring(value or ""))
    for _, term in ipairs(TERMS) do
        if string.find(value, term, 1, true) then return term end
    end
    return nil
end

local function isRemote(className)
    return className == "RemoteEvent" or className == "RemoteFunction"
end

function Scanner.new()
    return setmetatable({
        _running = false, _scanId = 0, _report = "No structure scan run yet.",
        _count = 0, _scanned = 0
    }, Scanner)
end

function Scanner:GetReport() return self._report end
function Scanner:GetCount() return self._count end
function Scanner:Clear()
    self._report = "No structure scan run yet."
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
        local remotes, matches, seen = {}, {}, {}
        local scanned = 0
        local function notify(status)
            if type(onUpdate) == "function" then
                pcall(onUpdate, status, #remotes + #matches)
            end
        end
        notify("SCANNING CLIENT-VISIBLE OBJECTS")

        for _, root in ipairs(roots) do
            if not self._running or self._scanId ~= scanId then return end
            local ok, descendants = pcall(function() return root:GetDescendants() end)
            if ok and descendants then
                for _, instance in ipairs(descendants) do
                    if not self._running or self._scanId ~= scanId then return end
                    scanned += 1
                    local name = safe(instance, "Name", "")
                    local className = safe(instance, "ClassName", "Unknown")
                    local path = pathOf(instance)
                    local key = className .. "|" .. path
                    if not seen[key] then
                        seen[key] = true
                        if isRemote(className) and #remotes < MAX_REMOTE then
                            table.insert(remotes, {
                                className = className, name = name, path = path
                            })
                            notify("REMOTE DISCOVERED")
                        else
                            local term = hasTerm(name) or hasTerm(path)
                            if term and #matches < MAX_MATCH then
                                local children = safe(instance, "GetChildren", nil)
                                local childCount = 0
                                if type(children) == "function" then
                                    local childOk, list = pcall(function() return instance:GetChildren() end)
                                    if childOk and list then childCount = #list end
                                end
                                table.insert(matches, {
                                    className = className, name = name, path = path,
                                    term = term, children = childCount
                                })
                            end
                        end
                    end
                    if scanned >= MAX_SCAN then break end
                    if scanned % YIELD_EVERY == 0 then
                        notify("SCANNING")
                        task.wait()
                    end
                end
            end
            if scanned >= MAX_SCAN then break end
        end

        if self._scanId ~= scanId then return end
        self._running = false
        local lines = {
            "SHORTNAME HUB - FIGHT ON A BASEPLATE STRUCTURE SCAN",
            "Mode: PASSIVE / READ-ONLY",
            "Objects inspected: " .. tostring(scanned),
            "RemoteEvents/RemoteFunctions found: " .. tostring(#remotes),
            "Combat-related name/path matches: " .. tostring(#matches),
            "Scan limit: " .. tostring(MAX_SCAN),
            "----------------------------------------",
            "REMOTE INVENTORY (NAMES AND PATHS ONLY)"
        }
        for i, item in ipairs(remotes) do
            table.insert(lines, string.format("%d. [%s] %s", i, item.className, item.path))
        end
        if #remotes == 0 then table.insert(lines, "No RemoteEvents or RemoteFunctions found in scanned roots.") end
        table.insert(lines, "")
        table.insert(lines, "COMBAT-RELATED INSTANCE MATCHES")
        for i, item in ipairs(matches) do
            table.insert(lines, string.format(
                "%d. [%s] term=%s children=%d | %s",
                i, item.className, item.term, item.children, item.path
            ))
        end
        if #matches == 0 then table.insert(lines, "No combat-related name/path matches found.") end
        table.insert(lines, "----------------------------------------")
        table.insert(lines, "Safety notes:")
        table.insert(lines, "- No RemoteEvent, RemoteFunction, BindableEvent, or BindableFunction is invoked.")
        table.insert(lines, "- Script source is not read or executed.")
        table.insert(lines, "- Only names, classes, paths, and direct-child counts are inspected.")
        table.insert(lines, "- Results are limited to objects replicated to this client.")
        self._scanned = scanned
        self._count = #remotes + #matches
        self._report = table.concat(lines, "\n")
        notify(scanned >= MAX_SCAN and "SCAN LIMIT REACHED" or "SCAN COMPLETE")
    end)
    return "SCANNING"
end

-- Upload the generated structure report through the existing authenticated receiver.
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
    return true, "STRUCTURE REPORT UPLOADED TO GITHUB"
end

return Scanner
