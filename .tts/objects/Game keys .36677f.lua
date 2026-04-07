local savedPositions = {}

function onSave()
	return JSON.encode({
		savedPositions = savedPositions
	})
end

function onLoad(data)
	addHotkey('Save Position', savePositionClicked)
	addHotkey('Restore Position', restorePositionClicked)
	savedPositions = {}
	if data == nil or data == "" then
		return
	end
	savedPositions = JSON.decode(data)
end

function savePositionClicked(playerColor, hoverObj)
	savedPositions[playerColor] = {}
	local objects = Player[playerColor].getSelectedObjects()
	if #objects ~= 0 then
		for _, obj in ipairs(objects) do
			savePosition(playerColor, obj.getGUID(), obj.getPosition(), obj.getRotation())
		end
	elseif hoverObj ~= nil then
		savePosition(playerColor, hoverObj.getGUID(), hoverObj.getPosition(), hoverObj.getRotation())
	end
end

function restorePositionClicked(playerColor)
	for _, svObj in ipairs(savedPositions[playerColor]) do
		local obj = getObjectFromGUID(svObj.guid)
		if obj ~= nil then
			obj.setRotationSmooth(svObj.rotation, false, true)
			obj.setPositionSmooth(svObj.position, false, true)
		end
	end
end

function savePosition(playerColor, guid, position, rotation)
	savedPositions[playerColor][#savedPositions[playerColor] + 1] = {
		guid = guid,
		position = position,
		rotation = rotation
	}
end