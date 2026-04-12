savedPositions = {}

function onSave()
	return JSON.encode({
		savedPositions = savedPositions
	})
end

function onLoad(data)
	addHotkey('Save Position', savePositionClicked)
	addHotkey('Restore Position', restorePositionClicked)
	restoreSavedData(data)
end

function restoreSavedData(data)
	if data == nil then return end
	savedPositions = JSON.decode(data).savedPositions
end

function savePositionClicked(playerColor, hoverObj)
	savedPositions[playerColor] = {}
	if #Player[playerColor].getSelectedObjects() ~= 0 then
		local objects = Player[playerColor].getSelectedObjects()
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
    if savedPositions[playerColor] == nil then
        savedPositions[playerColor] = {}
    end
	savedPositions[playerColor][#savedPositions[playerColor] + 1] = {
		guid = guid,
		position = position,
		rotation = rotation
	}
end