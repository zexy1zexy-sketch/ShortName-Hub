
-- SHORTNAME HUB | THANKSGIVING EVENT SCANNER
-- Read-only client-side discovery.
-- Does not fire remotes or modify game state.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Scanner = {}
Scanner.__index = Scanner

local KEYWORDS = {
    "thanksgiving", "turkey", "harvest", "feast",
    "corn", "pumpkin", "cranberry", "stuffing",
    "autumn", "pilgrim", "gravy", "gobble",
    "event", "reward"
}

local MAX_RESULTS = 300
local MAX_SCAN_OBJECTS = 12000

function Scanner.new()
    return setmetatable({
        Running = false,
        Results = {},
        Report = "",
        Count = 0,
        ScanToken = 0
    }, Scanner)
end

local function matches(value)
    local text = tostring(value or ""):lower()

    for _, keyword in ipairs(KEYWORDS) do
        if text:find(keyword, 1, true) then
            return true
        end
    end

    return false
end

local function safePath(object)
    local success, path = pcall(function()
        return object:GetFullName()
    end)

    return success and path or object.Name
end

function Scanner:GetCount()
    return self.Count
end

function Scanner:GetReport()
    return self.Report
end

function Scanner:Clear()
    self.Results = {}
    self.Report = ""
    self.Count = 0
end

function Scanner:Stop()
    self.Running = false
    self.ScanToken = self.ScanToken + 1
end

function Scanner:Start(onUpdate)
    if self.Running then
        return
    end

    self:Clear()
    self.Running = true
    self.ScanToken = self.ScanToken + 1

    local token = self.ScanToken

    task.spawn(function()
        local player = Players.LocalPlayer
        local inspected = 0

        local function notify(status)
            if onUpdate then
                pcall(
                    onUpdate,
                    status,
                    self.Count,
                    self.Report
                )
            end
        end

        local function add(category, detail)
            if #self.Results >= MAX_RESULTS then
                return
            end

            table.insert(
                self.Results,
                "[" .. category .. "] " .. detail
            )

            self.Count = #self.Results
        end

        local function inspect(root, category)
            if not root then
                return
            end

            local descendants = root:GetDescendants()

            for _, object in ipairs(descendants) do
                if not self.Running
                    or self.ScanToken ~= token then
                    return
                end

                inspected = inspected + 1

                if inspected > MAX_SCAN_OBJECTS
                    or #self.Results >= MAX_RESULTS then
                    return
                end

                if matches(object.Name) then
                    add(
                        category,
                        safePath(object)
                        .. " | Class: "
                        .. object.ClassName
                    )
                end

                if object:IsA("ProximityPrompt") then
                    local details =
                        object.ActionText
                        .. " "
                        .. object.ObjectText

                    if matches(details) then
                        add(
                            "PROMPT",
                            safePath(object)
                            .. " | "
                            .. details
                        )
                    end

                elseif object:IsA("TextLabel")
                    or object:IsA("TextButton")
                    or object:IsA("TextBox") then

                    local success, value = pcall(function()
                        return object.Text
                    end)

                    if success and matches(value) then
                        add(
                            "VISIBLE TEXT",
                            safePath(object)
                            .. " | Text: "
                            .. tostring(value)
                        )
                    end
                end

                if inspected % 250 == 0 then
                    notify("SCANNING")
                    task.wait()
                end
            end
        end

        notify("SCANNING WORKSPACE")
        inspect(Workspace, "WORKSPACE")

        if self.Running and self.ScanToken == token then
            notify("SCANNING REPLICATED STORAGE")
            inspect(
                ReplicatedStorage,
                "REPLICATED STORAGE"
            )
        end

        if self.Running and self.ScanToken == token and player then
            notify("SCANNING PLAYER GUI")

            inspect(
                player:FindFirstChildOfClass("PlayerGui"),
                "PLAYER GUI"
            )
        end

        if not self.Running
            or self.ScanToken ~= token then
            return
        end

        local header = {
            "========================================",
            "       SHORTNAME HUB EVENT SCANNER",
            "========================================",
            "Game: " .. tostring(game.Name),
            "Place ID: " .. tostring(game.PlaceId),
            "Player: " .. (player and player.Name or "Unknown"),
            "Objects inspected: " .. tostring(
                math.min(inspected, MAX_SCAN_OBJECTS)
            ),
            "Discoveries: " .. tostring(self.Count),
            "========================================",
            ""
        }

        self.Report =
            table.concat(header, "\n")
            .. table.concat(self.Results, "\n")

        self.Running = false

        notify("SCAN COMPLETE")

        print(self.Report)
    end)
end

return Scanner
