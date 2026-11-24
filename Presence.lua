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
            universeId = game.GameId,
            executor = (function()
                local name = "Unknown / unavailable"
                pcall(function()
                    if type(identifyexecutor) == "function" then
                        local reported = identifyexecutor()
                        if type(reported) == "string" and reported ~= "" then name = reported end
                    elseif type(getexecutorname) == "function" then
                        local reported = getexecutorname()
                        if type(reported) == "string" and reported ~= "" then name = reported end
                    end
                end)
                return name
            end)()
        })
    })
end

local function OwnerHeaders(session)
    return { ["x-owner-session"] = tostring(session or "") }
end

function Presence.LoginOwner(secret)
    if type(secret) ~= "string" or secret == "" then return false, "Enter your owner secret." end
    return Send({
        Url = ENDPOINT .. "/owner-pair",
        Method = "POST",
        Timeout = 20,
        Headers = { ["x-owner-secret"] = secret },
    })
end

function Presence.GetPlayers(session)
    if type(session) ~= "string" or session == "" then return false, "Verify owner access first." end
    return Send({ Url = ENDPOINT .. "/players", Method = "GET", Timeout = 25, Headers = OwnerHeaders(session) })
end

function Presence.SetBan(session, userId, duration)
    if type(session) ~= "string" or session == "" then return false, "Verify owner access first." end
    return Send({
        Url = ENDPOINT .. "/ban", Method = "PATCH", Timeout = 20,
        Headers = { ["Content-Type"] = "application/json", ["x-owner-session"] = session },
        Body = HttpService:JSONEncode({ userId = tonumber(userId), duration = duration })
    })
end

function Presence.CheckBan()
    local player = Players.LocalPlayer
    if not player then return false, "Local player unavailable" end
    return Send({
        Url = ENDPOINT .. "/check-ban?userId=" .. tostring(player.UserId),
        Method = "GET",
        Timeout = 15
    })
end

function Presence.GetBans(session)
    if type(session) ~= "string" or session == "" then return false, "Verify owner access first." end
    return Send({
        Url = ENDPOINT .. "/bans",
        Method = "GET",
        Timeout = 25,
        Headers = OwnerHeaders(session)
    })
end

function Presence.GetSecurityEvents(session)
    if type(session) ~= "string" or session == "" then return false, "Verify owner access first." end
    return Send({
        Url = ENDPOINT .. "/security-events",
        Method = "GET",
        Timeout = 25,
        Headers = OwnerHeaders(session)
    })
end

function Presence.ReportSecurity(uploadKey, eventData)
    if type(uploadKey) ~= "string" or uploadKey == "" then return false, "Upload key unavailable." end
    if type(eventData) ~= "table" then return false, "Security event data is invalid." end
    local player = Players.LocalPlayer
    if player then
        eventData.userId = player.UserId
        eventData.username = player.Name
        eventData.placeId = game.PlaceId
    end
    return Send({
        Url = ENDPOINT .. "/security-report",
        Method = "POST",
        Timeout = 20,
        Headers = { ["Content-Type"] = "application/json", ["x-upload-key"] = uploadKey },
        Body = HttpService:JSONEncode(eventData)
    })
end

function Presence.SetRank(session, userId, rank)
    if type(session) ~= "string" or session == "" then return false, "Verify owner access first." end
    return Send({
        Url = ENDPOINT .. "/rank",
        Method = "PATCH",
        Timeout = 20,
        Headers = { ["Content-Type"] = "application/json", ["x-owner-session"] = session },
        Body = HttpService:JSONEncode({ userId = tonumber(userId), rank = rank })
    })
end

return Presence
