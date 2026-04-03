local objectIsInteractable = true
local _demotedPlayerSteamIds = {}

function isNotOnDemotedPlayerList(player)
    return _demotedPlayerSteamIds[player.steam_id] == nil
end

function tryPromotePlayer(player)
    if isNotOnDemotedPlayerList(player) then
        player.promote()
    end
end

function savePlayerPromotionState(player)
    if player.promoted or player.host then
        _demotedPlayerSteamIds[player.steam_id] = nil
    else
        _demotedPlayerSteamIds[player.steam_id] = {}
    end
end

function onLoad(saveData)
    self.interactable = objectIsInteractable

    _demotedPlayerSteamIds = {}
    if saveData ~= "" then
        _demotedPlayerSteamIds = JSON.decode(saveData)
    end

    for _, player in ipairs(Player.getPlayers()) do
        tryPromotePlayer(player)
    end
end

function onPlayerConnect(player)
    tryPromotePlayer(player)
end

function onPlayerDisconnect(player)
    savePlayerPromotionState(player)
end

function onSave()
    for _, player in ipairs(Player.getPlayers()) do
        savePlayerPromotionState(player)
    end

    saveData = JSON.encode(_demotedPlayerSteamIds)
    return saveData
end
