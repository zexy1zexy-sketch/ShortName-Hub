-- SHORTNAME HUB PRESENCE CLIENT
-- Presence reports automatically while ShortName Hub is running.
local Presence = {}
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ENDPOINT = "https://shortname-report-receive.ryft-amv.workers.dev"

local function GetRequest()
    if type(request) == "function" then return request end
    if type(http_request) == "function" then return http_request end
    if syn and type(syn.request) == "function" then return syn.request end
    if http and type(http.request) == "function" then return http.request end
    if fluxus and type(fluxus.request) == "function" then return fluxus.request end
    return nil
end

local function Send(options)
    local requestFunction = GetRequest()
    if not requestFunction then return false, "HTTP request API unavailable" end
    local ok, response = pcall(function() return requestFunction(options) end)
    if not ok or type(response) ~= "table" then return false, tostring(response) end
    local code = response.StatusCode or response.Status or response.status_code
    local body = response.Body or response.body or ""
    local decodedOk, decoded = pcall(function() return HttpService:JSONDecode(body) end)
    if code ~= 200 or not decodedOk or type(decoded) ~= "table" or decoded.ok ~= true then
        return false, decodedOk and tostring(decoded.error or "Request failed") or ("HTTP " .. tostring(code))
    end
    return true, decoded
end

function Presence.Report()
    local player = Players.LocalPlayer
    if not player then return false, "Local player unavailable" end
    local gameName = "Unknown experience"
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        if info and type(info.Name) == "string" then gameName = info.Name end
    end)
    return Send({
        Url = ENDPOINT .. "/presence",
        Method = "POST",
        Timeout = 20,
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({
            userId = player.UserId,
            username = player.Name,
            displayName = player.DisplayName,
            gameName = gameName,
            placeId = game.PlaceId,
            universeId = game.GameId
        })
    })
end

function Presence.GetPlayers(adminKey)
    if type(adminKey) ~= "string" or adminKey == "" then return false, "Enter the owner admin key." end
    return Send({
        Url = ENDPOINT .. "/players",
        Method = "GET",
        Timeout = 25,
        Headers = { ["x-admin-key"] = adminKey }
    })
end

function Presence.SetRank(adminKey, userId, rank)
    if type(adminKey) ~= "string" or adminKey == "" then return false, "Enter the owner admin key." end
    return Send({
        Url = ENDPOINT .. "/rank",
        Method = "PATCH",
        Timeout = 20,
        Headers = { ["Content-Type"] = "application/json", ["x-admin-key"] = adminKey },
        Body = HttpService:JSONEncode({ userId = tonumber(userId), rank = rank })
    })
end

return Presence
