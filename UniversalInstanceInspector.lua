-- UniversalInstanceInspector.lua
-- Read-only, game-independent inspection of client-visible Roblox instances.
-- Does not read or execute script source and never invokes remotes/bindables.

local Inspector = {}
Inspector.__index = Inspector

local ROOTS = {
    game:GetService("Workspace"),
    game:GetService("ReplicatedStorage"),
    game:GetService("ReplicatedFirst"),
    game:GetService("StarterGui"),
    game:GetService("StarterPlayer"),
    game:GetService("Lighting"),
    game:GetService("SoundService"),
}

local MAX_OBJECTS = 25000
local MAX_DETAILS = 600

local function safe(instance, property, fallback)
    local ok, value = pcall(function() return instance[property] end)
    return ok and value or fallback
end

local function pathOf(instance)
    local ok, value = pcall(function() return instance:GetFullName() end)
    return ok and value or tostring(safe(instance, "Name", "Unknown"))
end

local function isNetwork(className)
    return className == "RemoteEvent" or className == "RemoteFunction"
        or className == "BindableEvent" or className == "BindableFunction"
end

function Inspector.new()
    return setmetatable({_report = "No universal inspection run yet.", _count = 0}, Inspector)
end

function Inspector:GetReport() return self._report end
function Inspector:GetCount() return self._count end
function Inspector:Clear()
    self._report = "No universal inspection run yet."
    self._count = 0
    return true
end

function Inspector:Inspect(onUpdate)
    local lines = {
        "SHORTNAME HUB - UNIVERSAL INSTANCE INSPECTION",
        "Mode: READ-ONLY / GAME-INDEPENDENT",
        "Roots: Workspace, ReplicatedStorage, ReplicatedFirst, StarterGui, StarterPlayer, Lighting, SoundService",
        "----------------------------------------"
    }
    local counts, network, scripts, ui = {}, {}, {}, {}
    local seen, inspected = {}, 0
    for _, root in ipairs(ROOTS) do
        local ok, descendants = pcall(function() return root:GetDescendants() end)
        if ok and descendants then
            for _, item in ipairs(descendants) do
                inspected += 1
                local className = tostring(safe(item, "ClassName", "Unknown"))
                local name = tostring(safe(item, "Name", "Unknown"))
                local path = pathOf(item)
                counts[className] = (counts[className] or 0) + 1
                if isNetwork(className) and #network < 250 then
                    table.insert(network, string.format("[%s] %s", className, path))
                elseif (className == "Script" or className == "LocalScript" or className == "ModuleScript") and #scripts < 200 then
                    table.insert(scripts, string.format("[%s] %s", className, path))
                elseif (className == "ScreenGui" or className == "TextLabel" or className == "TextButton" or className == "TextBox") and #ui < 150 then
                    local text = tostring(safe(item, "Text", ""))
                    if text ~= "" then text = " | Text=" .. text:gsub("[%c]", " "):sub(1, 100) end
                    table.insert(ui, string.format("[%s] %s%s", className, path, text))
                end
                if inspected >= MAX_OBJECTS then break end
            end
        end
        if inspected >= MAX_OBJECTS then break end
    end
    table.insert(lines, "Objects inspected: " .. tostring(inspected))
    table.insert(lines, "Unique instance classes: " .. tostring((function() local n=0 for _ in pairs(counts) do n+=1 end return n end)()))
    table.insert(lines, "")
    table.insert(lines, "INSTANCE CLASS COUNTS")
    for className, count in pairs(counts) do table.insert(lines, string.format("%s: %d", className, count)) end
    table.insert(lines, "")
    table.insert(lines, "REMOTE / BINDABLE INVENTORY (NEVER INVOKED)")
    for _, value in ipairs(network) do table.insert(lines, value) end
    if #network == 0 then table.insert(lines, "No client-visible remote or bindable instances found.") end
    table.insert(lines, "")
    table.insert(lines, "SCRIPT / MODULE INVENTORY (SOURCE NOT READ)")
    for _, value in ipairs(scripts) do table.insert(lines, value) end
    table.insert(lines, "")
    table.insert(lines, "VISIBLE UI INVENTORY")
    for _, value in ipairs(ui) do table.insert(lines, value) end
    table.insert(lines, "")
    table.insert(lines, "Safety / coverage:")
    table.insert(lines, "- No script source is read or executed.")
    table.insert(lines, "- No RemoteEvent, RemoteFunction, BindableEvent, or BindableFunction is invoked.")
    table.insert(lines, "- Only client-visible instances and selected metadata are inspected.")
    table.insert(lines, "- This is a general inventory, not proof of server behavior or exploitability.")
    table.insert(lines, "- Object cap: " .. tostring(MAX_OBJECTS))
    self._count = inspected
    self._report = table.concat(lines, "\n")
    if type(onUpdate) == "function" then pcall(onUpdate, "INSPECTION COMPLETE", inspected) end
    return true, inspected
end

return Inspector
