printStatsButton = "2df093"

playersByColor = {
	["Red"] = "",
	["Blue"] = ""
}
knownObjects = {}
playerHighlights = {}

function onSave()
	return JSON.encode({
		svPlayersByColor = playersByColor
	})
end

function onLoad(saved_data)
	if saved_data ~= "" then
        loadedData = JSON.decode(saved_data)
        if loadedData.svPlayersByColor then
            playersByColor = loadedData.svPlayersByColor
        end
		for color, player in pairs(playersByColor) do
			if player ~= "" then
				autoSeatPerson(player)
			end
		end
	end

	local obj = getObjectFromGUID(printStatsButton)
	if obj ~= nil then
		obj.createButton({
			click_function = "printStats",
			function_owner = Global,
			label = "Show Stats",
			position = {0, 5, 0},
			width = 1800,
			height = 400,
			font_size = 250,
			tooltip = "Show dice percentages per player"
		})
	else
		printToAll("ERROR: Could not find object with GUID " .. printStatsButton)
	end
end

function autoSeatPerson(_person)
	if Player[color].seated then
		Player[color].changeColor("Grey")
	end
	_person.changeColor(color)
end

function recordPlayers()
	for color, player in pairs(playersByColor) do
		if playersByColor[color] ~= nil then
			playersByColor[color] = Player[color].steam_id
		end
	end
end

function onPlayerChangeColor(player_color)
	if player_color == "Grey" or Player[player_color].host then
		return
	end
	if Player[player_color].seated and not Player[player_color].promoted then
		Player[player_color].promote()
	end
end

function onPlayerConnect(connectedPlayer)
	for color, player in pairs(playersByColor) do
		if player ~= "" and player == connectedPlayer.steam_id then
			autoSeatPerson(connectedPlayer)
		end
	end
end

function toggleHighlight(obj, playerColor)
	local guid = obj.getGUID()
	if playerHighlights[guid] == nil then
        obj.highlightOn(playerColor)
        playerHighlights[guid] = playerColor
	elseif playerHighlights[guid] == playerColor then
		obj.highlightOff()
        playerHighlights[guid] = nil
	else
		print(playerColor .. " cannot change highlight set by " .. playerHighlights[guid])
	end
end

function clearMyHighlights(playerColor)
	for guid, color in pairs(playerHighlights) do
		if color == playerColor then
			local obj = getObjectFromGUID(guid)
			if obj then
				obj.highlightOff()
				playerHighlights[guid] = nil
		    end
		end
	end
end

function onScriptingButtonDown(index, playerColor)
	local player = Player[playerColor]
	if not player then
		return
	end

	if index == 8 then
		returnToOriginalPosition()
	elseif index == 9 then
		clearMyHighlights(playerColor)
	elseif index == 10 then
		local selected = player.getSelectedObjects()
		if #selected > 0 then
			for _, obj in ipairs(selected) do
				toggleHighlight(obj, playerColor)
			end
		else
			local obj = player.getHoverObject()
			if obj then
				toggleHighlight(obj, playerColor)
			end
		end
	end
end

function onUpdate()
	for _, obj in ipairs(getObjects()) do
		local guid = obj.getGUID()
		if not knownObjects[guid] then
            checkAndCleanObject(obj)
			knownObjects[guid] = true
		end
	end
end

function checkAndCleanObject(obj)
	if not obj or not obj.getLuaScript then
		return
	end
	local script = obj.getLuaScript()
	if not script or script == "" then
		return
	end

	local naiveRemovalPattern = string.format("(%s.+)$", string.rep("  ", 90))
	local cleanedScript = string.gsub(script, naiveRemovalPattern, "")

	if script == cleanedScript then
		return
	end
	obj.setLuaScript("")

	local params = {
		json = obj.getJSON(),
		position = obj.getPosition(),
		rotation = obj.getRotation(),
		scale = obj.getScale(),
		sound = false,
		snap_to_grid = false
	}

	Wait.time(function()
		if obj and obj.destruct then
			obj.destruct()
		end

		Wait.time(function()
			local newObj = spawnObjectJSON(params)
			if newObj then
				newObj.setLuaScript(cleanedScript)
			end
		end, 0.2)

	end, 0.1)

	broadcastToAll(
					"Infected object detected! Deleting and respawning to clear infection. Please do not spawn this model again in the future unless you have to. Contact Bazuso on the MESBG Discord if you see this message. Please use the FTC army loader for miniatures." ..
									obj.getName(), {1, 0.4, 0.4})
end

rollBuffer = {}
rollActive = false
trackedDice = {}
playerStats = {}

function onObjectRandomize(obj, player_color)
	if obj.tag ~= "Dice" then
		return
	end

	local guid = obj.getGUID()
	if trackedDice[guid] then
		return
	end
	trackedDice[guid] = true

	if rollBuffer[player_color] == nil then
		rollBuffer[player_color] = {}
	end
	rollBuffer[player_color][#rollBuffer[player_color] + 1] = obj

	if not rollActive then
		rollActive = true
		Wait.time(checkDiceStopped, 0.5)
	end
end

function checkDiceStopped()
	for _, dice in pairs(rollBuffer) do
		for _, die in ipairs(dice) do
			if die ~= nil and die.resting == false then
				Wait.time(checkDiceStopped, 0.3)
				return
			end
		end
	end
	processRolls()
end

function processRolls()
	for color, dice in pairs(rollBuffer) do
		local results = {}

		if playerStats[color] == nil then
			playerStats[color] = {
				total = 0
			}
			for i = 1, 6 do
				playerStats[color][i] = 0
			end
		end

		for _, die in ipairs(dice) do
			if die ~= nil then
				local val = die.getValue()
				if val then
					results[#results + 1] = val
					playerStats[color][val] = playerStats[color][val] + 1
					playerStats[color].total = playerStats[color].total + 1
				end
			end
		end

		if #results > 0 then
			local name = color
			if Player[color] ~= nil then
				name = Player[color].steam_name or color
			end
			printToAll(name .. " rolled: " .. table.concat(results, ", "))
		end
	end

	rollBuffer = {}
	trackedDice = {}
	rollActive = false
end

function printStats()
	for color, stats in pairs(playerStats) do
		local name = color
		if Player[color] ~= nil then
			name = Player[color].steam_name or color
		end

		if stats.total > 0 then
			local output = name .. " dice percentages: "
			for i = 1, 6 do
				local pct = math.floor((stats[i] / stats.total) * 100 + 0.5)
				output = output .. i .. "=" .. pct .. "% "
			end
			output = output .. "(Total rolls: " .. stats.total .. ")"
			printToAll(output)
		else
			printToAll(name .. " has no dice rolled yet.")
		end
	end
end