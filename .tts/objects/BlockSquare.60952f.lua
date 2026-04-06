local MODEL_BAG_GUID = '24f6d0'
local NOTE_NAME = "ArmyList"
local bag = nil
local Utils = require("utils")

function onLoad()
	self.createButton({
		label = "Spawn Army",
		click_function = "spawnFromNotebook",
		function_owner = self,
		position = {0, 5, 0},
		rotation = {0, 180, 0},
		width = 1800,
		height = 400,
		font_size = 250
	})
    bag = getObjectFromGUID(MODEL_BAG_GUID)
end

function spawnFromNotebook(obj, playerColor)
    local notebooks = getNotebookTabs()
    for i, tab in ipairs(notebooks) do
        if tab.title == NOTE_NAME then
            processList(tab.body, playerColor)
            return
        end
    end
    broadcastToColor("ArmyList page not found. Add a page named 'ArmyList' to the Notebook.", playerColor, {1, 0, 0})
end

local psu = {}
local contents = nil
function processList(text, color)
	if bag == nil then
		broadcastToColor("Error: Model bag not found!", color, {1, 0, 0})
		return
	end
    
	contents = bag.getData().ContainedObjects
    local basePos = {
		x = self.getPosition().x,
		y = self.getPosition().y + 2,
		z = self.getPosition().z + 4
	}
	local rowSpacing, colSpacing, warbandsPerRow = 10, 8, 6
	local modelIndex, warbandIndex = 0, 0
    local row, col = 0, 0
    local totalModels = 0
    local heroPos = {
        x = basePos.x,
        y = basePos.y,
        z = basePos.z
    }
    local unit_pos = {
        x = heroPos.x,
        y = heroPos.y,
        z = heroPos.z + 1.5
    }
    local floor = math.floor
    local hasHero = false

	for line in text:gmatch("%(%s*(.-)%s*%)") do
        local count, name, wargear = line:match("^(%d*)x*%s*(.+:)%s*( *[%S ]*)%s*")
        if name and count ~= "0" then
            if count ~= "" then
                if not hasHero then
                    broadcastToColor("Error: \"" .. name .. "\" found before any hero.", color, {1, 0, 0})
                else
                    spawnNextFromQueue(name .. wargear, unit_pos, color)
                    totalModels = totalModels + 1
                    modelIndex = modelIndex + 1
                    unit_pos.x = heroPos.x + (modelIndex % 6) * 1.1
                    unit_pos.z = heroPos.z + floor(modelIndex / 6) * 1.1
                end
            else
                hasHero = true
                spawnNextFromQueue(name .. wargear, heroPos, color)
                warbandIndex = warbandIndex + 1
                row = floor(warbandIndex / warbandsPerRow)
                col = warbandIndex % warbandsPerRow
                heroPos.x = basePos.x + row * rowSpacing
                heroPos.z = basePos.z + col * colSpacing
                unit_pos.x = heroPos.x
                unit_pos.z = heroPos.z + 1.5
                totalModels = totalModels + 1
                modelIndex = 0
            end
        end
	end
	broadcastToColor(totalModels .. " Models | " .. floor(totalModels / 2) + 1 .. " Break | " .. floor(totalModels / 4) .. " Remaining", color, {0.2, 1, 0.2})
    contents = nil
    for _, obj in ipairs(psu) do
        if obj then
            obj.destruct()
        end
    end
    psu = {}
end

local waitSpawning = false
function spawnNextFromQueue(name, pos, color)
    broadcastToAll("Spawning: " .. name .. " at position: " .. pos.x .. ", " .. pos.y .. ", " .. pos.z, color, {0.2, 1, 0.2})
	if name == "" or not pos then
		return
	end
    name = name:lower()
    if psu[name] then
        spawnObjectData({data = psu[name],position = pos,})
        return
    end
	for _, obj in ipairs(contents) do
		if obj["Nickname"]:lower() == name then
            spawnObjectData({data = obj, position = pos,})
            psu[name] = obj
			return
		end
	end
	broadcastToColor("Could not find: " .. name, color, {1, 0.5, 0})
end
