
-- SHORTNAME HUB | THANKSGIVING SCANNER
-- Read-only client-side inspection
-- Does not fire remotes or modify the game.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Results = {}
local MAX_RESULTS = 300

local Keywords = {
    "thanksgiving", "turkey", "thank", "harvest",
    "feast", "corn", "pumpkin", "event",
    "cranberry", "stuffing", "autumn", "reward"
}

local function matches(text)
    text = tostring(text):lower()
    for _, word in ipairs(Keywords) do
        if text:find(word, 1, true) then
            return true
        end
    end
    return false
end

local function add(category, text)
    if #Results >= MAX_RESULTS then return end
    table.insert(Results, "[" .. category .. "] " .. text)
end

local function getPath(obj)
    local success, result = pcall(function()
        return obj:GetFullName()
    end)
    return success and result or obj.Name
end

local function inspect(root, category)
    local descendants = root:GetDescendants()

    for _, obj in ipairs(descendants) do
        if #Results >= MAX_RESULTS then break end

        if matches(obj.Name) then
            add(category, getPath(obj) ..
                " | Class: " .. obj.ClassName)
        end

        if obj:IsA("ProximityPrompt") then
            local info = obj.Name ..
                " | Parent: " .. getPath(obj.Parent) ..
                " | Action: " .. obj.ActionText ..
                " | Object: " .. obj.ObjectText ..
                " | Distance: " .. obj.MaxActivationDistance

            if matches(info) then
                add("PROMPT", info)
            end
        end

        if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            if matches(obj.Name) then
                add("WORLD GUI", getPath(obj))
            end
        end

        if obj:IsA("TextLabel")
        or obj:IsA("TextButton")
        or obj:IsA("TextBox") then
            local success, value = pcall(function()
                return obj.Text
            end)

            if success and matches(value) then
                add("VISIBLE TEXT",
                    getPath(obj) .. " | Text: " .. value)
            end
        end
    end
end

print("Starting ShortName Hub Scanner...")

add("PLAYER", Player.Name)

-- Inspect visible game world
inspect(Workspace, "WORKSPACE")

-- Inspect locally replicated game objects
inspect(ReplicatedStorage, "REPLICATED STORAGE")

-- Inspect the player's visible interface
local playerGui = Player:FindFirstChildOfClass("PlayerGui")
if playerGui then
    inspect(playerGui, "PLAYER GUI")
end

local report = table.concat(Results, "\n")

local header = [[
========================================
       SHORTNAME HUB EVENT SCANNER
========================================
Game: ]] .. game.Name .. [[
Place ID: ]] .. game.PlaceId .. [[
Player: ]] .. Player.Name .. [[

Results: ]] .. #Results .. [[
========================================

]]

report = header .. report

print(report)

if setclipboard then
    local success = pcall(function()
        setclipboard(report)
    end)

    if success then
        print("REPORT COPIED TO CLIPBOARD!")
    else
        warn("Clipboard unavailable. Copy the output manually.")
    end
else
    warn("Clipboard unavailable. Copy the output manually.")
end

print("SCAN COMPLETE!")
