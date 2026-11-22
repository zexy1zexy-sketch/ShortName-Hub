-- FightOnABaseplateInspector.lua
-- Read-only structural inspection of selected client-visible combat objects.
-- Does not read script source, invoke remotes, or modify game state.

local Inspector = {}
Inspector.__index = Inspector

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local TARGETS = {
    { label = "RaycastHitboxV4", root = ReplicatedStorage, path = {"RaycastHitboxV4"} },
    { label = "Combat LockOn", root = Workspace, path = {"Live"} , childPath = {"Combat", "Modules", "LockOn"}, eachChild = true },
    { label = "Combat CameraShake", root = Workspace, path = {"Live"}, childPath = {"Combat", "Modules", "CameraShake"}, eachChild = true },
    { label = "ArmAimRemote", root = ReplicatedStorage, path = {"ArmAimRemote"} },
    { label = "Replicate", root = ReplicatedStorage, path = {"Replicate"} },
    { label = "Packet RemoteEvent", root = ReplicatedStorage, path = {"Packet", "RemoteEvent"} },
    { label = "FlyFX", root = ReplicatedStorage, path = {"FlyFX"} },
    { label = "BindFly", root = ReplicatedStorage, path = {"BindFly"} },
    { label = "Flying BindFly", root = ReplicatedStorage, path = {"Flying", "Events", "BindFly"} },
}

local function findChild(parent, name)
    if not parent then return nil end
    local ok, child = pcall(function() return parent:FindFirstChild(name) end)
    return ok and child or nil
end

local function resolve(root, path)
    local current = root
    for _, name in ipairs(path) do
        current = findChild(current, name)
        if not current then return nil end
    end
    return current
end

local function inspectInstance(label, instance, lines)
    if not instance then
        table.insert(lines, label .. ": NOT FOUND IN CLIENT REPLICATED DATA")
        return false
    end

    local okName, fullName = pcall(function() return instance:GetFullName() end)
    local okClass, className = pcall(function() return instance.ClassName end)
    local okChildren, children = pcall(function() return instance:GetChildren() end)
    local okDesc, descendants = pcall(function() return instance:GetDescendants() end)

    table.insert(lines, label .. ": " .. (okClass and className or "Unknown"))
    table.insert(lines, "  Path: " .. (okName and fullName or label))
    table.insert(lines, "  Direct children: " .. tostring(okChildren and #children or "unavailable"))
    table.insert(lines, "  Descendants: " .. tostring(okDesc and #descendants or "unavailable"))

    if okChildren and children then
        local shown = math.min(#children, 30)
        for index = 1, shown do
            local child = children[index]
            local childOk, childClass = pcall(function() return child.ClassName end)
            local nameOk, childName = pcall(function() return child.Name end)
            table.insert(lines, string.format("    - %s (%s)",
                nameOk and childName or "Unknown",
                childOk and childClass or "Unknown"))
        end
        if #children > shown then
            table.insert(lines, "    ... " .. tostring(#children - shown) .. " more direct children")
        end
    end

    table.insert(lines, "")
    return true
end

local function findNamedInstances(roots, targetName, limit)
    local matches = {}
    for _, root in ipairs(roots) do
        local ok, descendants = pcall(function() return root:GetDescendants() end)
        if ok and descendants then
            for _, instance in ipairs(descendants) do
                local nameOk, name = pcall(function() return instance.Name end)
                if nameOk and name == targetName then
                    table.insert(matches, instance)
                    if #matches >= limit then return matches end
                end
            end
        end
    end
    return matches
end

local function inspectTarget(label, root, path, fallbackName, lines)
    local instance = resolve(root, path)
    if instance then
        return inspectInstance(label, instance, lines) and 1 or 0
    end

    local matches = findNamedInstances({root}, fallbackName or path[#path], 12)
    if #matches == 0 then
        inspectInstance(label, nil, lines)
        return 0
    end

    local count = 0
    for index, match in ipairs(matches) do
        if inspectInstance(label .. " [match " .. tostring(index) .. "]", match, lines) then
            count += 1
        end
    end
    return count
end

function Inspector.new()
    return setmetatable({ _report = "No inspection run yet.", _count = 0 }, Inspector)
end

function Inspector:GetReport()
    return self._report
end

function Inspector:GetCount()
    return self._count
end

function Inspector:Clear()
    self._report = "No inspection run yet."
    self._count = 0
    return true
end

function Inspector:Inspect(onUpdate)
    local lines = {
        "SHORTNAME HUB - FIGHT ON A BASEPLATE SYSTEM INSPECTION",
        "Mode: READ-ONLY RECURSIVE INSTANCE DISCOVERY",
        "----------------------------------------",
    }
    local inspected = 0

    local targets = {
        { "RaycastHitboxV4", ReplicatedStorage, {"RaycastHitboxV4"}, "RaycastHitboxV4" },
        { "ArmAimRemote", ReplicatedStorage, {"ArmAimRemote"}, "ArmAimRemote" },
        { "Replicate", ReplicatedStorage, {"Replicate"}, "Replicate" },
        { "Packet RemoteEvent", ReplicatedStorage, {"Packet", "RemoteEvent"}, "RemoteEvent" },
        { "FlyFX", ReplicatedStorage, {"FlyFX"}, "FlyFX" },
        { "BindFly", ReplicatedStorage, {"BindFly"}, "BindFly" },
        { "Flying BindFly", ReplicatedStorage, {"Flying", "Events", "BindFly"}, "BindFly" },
    }

    for _, target in ipairs(targets) do
        inspected += inspectTarget(target[1], target[2], target[3], target[4], lines)
        if type(onUpdate) == "function" then
            pcall(onUpdate, "SEARCHING " .. target[1], inspected)
        end
    end

    local live = findNamedInstances({Workspace}, "Live", 1)
    if #live > 0 then
        local liveRoot = live[1]
        local ok, models = pcall(function() return liveRoot:GetChildren() end)
        local found = 0
        if ok and models then
            for _, model in ipairs(models) do
                local combat = findChild(model, "Combat")
                local modules = findChild(combat, "Modules")
                if modules then
                    for _, moduleName in ipairs({"LockOn", "CameraShake"}) do
                        local moduleInstance = findChild(modules, moduleName)
                        if moduleInstance then
                            found += inspectInstance("Combat " .. moduleName .. " [" .. model.Name .. "]", moduleInstance, lines) and 1 or 0
                        end
                    end
                end
            end
        end
        if found == 0 then
            for _, moduleName in ipairs({"LockOn", "CameraShake"}) do
                local matches = findNamedInstances({liveRoot}, moduleName, 20)
                for index, match in ipairs(matches) do
                    found += inspectInstance("Combat " .. moduleName .. " [recursive match " .. tostring(index) .. "]", match, lines) and 1 or 0
                end
            end
        end
        inspected += found
        if found == 0 then
            table.insert(lines, "Combat LockOn / CameraShake: NOT FOUND UNDER Workspace.Live")
        end
    else
        table.insert(lines, "Workspace.Live: NOT FOUND IN CLIENT REPLICATED DATA")
    end

    table.insert(lines, "----------------------------------------")
    table.insert(lines, "Objects inspected: " .. tostring(inspected))
    table.insert(lines, "Notes:")
    table.insert(lines, "- Searches exact paths first, then recursively searches by instance name.")
    table.insert(lines, "- Only names, classes, paths, and child counts are inspected.")
    table.insert(lines, "- Script source is not read or executed.")
    table.insert(lines, "- RemoteEvents and RemoteFunctions are never invoked.")
    table.insert(lines, "- Objects not replicated to this client cannot be inspected.")

    self._count = inspected
    self._report = table.concat(lines, "\n")
    if type(onUpdate) == "function" then
        pcall(onUpdate, "INSPECTION COMPLETE", inspected)
    end
    return true, inspected
end

return Inspector
