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
        table.insert(lines, label .. ": NOT FOUND / NOT REPLICATED")
        return
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
        local shown = math.min(#children, 24)
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
        "Mode: READ-ONLY INSTANCE METADATA",
        "----------------------------------------",
    }
    local inspected = 0

    for _, target in ipairs(TARGETS) do
        if target.eachChild then
            local parent = resolve(target.root, target.path)
            if not parent then
                inspectInstance(target.label, nil, lines)
            else
                local ok, models = pcall(function() return parent:GetChildren() end)
                local found = 0
                if ok then
                    for _, model in ipairs(models) do
                        local targetInstance = resolve(model, target.childPath)
                        if targetInstance then
                            found += 1
                            inspected += 1
                            inspectInstance(target.label .. " [" .. model.Name .. "]", targetInstance, lines)
                        end
                    end
                end
                if found == 0 then
                    inspectInstance(target.label, nil, lines)
                end
            end
        else
            local instance = resolve(target.root, target.path)
            if instance then inspected += 1 end
            inspectInstance(target.label, instance, lines)
        end
        if type(onUpdate) == "function" then
            pcall(onUpdate, "INSPECTING " .. target.label, inspected)
        end
    end

    table.insert(lines, "----------------------------------------")
    table.insert(lines, "Objects inspected: " .. tostring(inspected))
    table.insert(lines, "Notes:")
    table.insert(lines, "- Only instance names, classes, paths, and child counts are inspected.")
    table.insert(lines, "- Script source is not read or executed.")
    table.insert(lines, "- RemoteEvents and RemoteFunctions are never invoked.")
    table.insert(lines, "- Missing objects may be server-only or not replicated to this client.")

    self._count = inspected
    self._report = table.concat(lines, "\n")
    if type(onUpdate) == "function" then
        pcall(onUpdate, "INSPECTION COMPLETE", inspected)
    end
    return true, inspected
end

return Inspector
