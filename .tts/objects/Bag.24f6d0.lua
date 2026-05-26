local NOTE_NAME = "ArmyList"
local Utils = require("utils")
local modelScripts = require("modelScripts")

local SPAWN_BATCH_SIZE = 1

local NO_SPAWN = {
    ["king's champion group:"] = true,
    ["sharkey & worm:"]        = true,
    ["shank & wrot, orc scavengers:"] = true,
    ["no hero sharkey:"]       = true,
    ["no hero spider:"]        = true,
    ["howdah:"]                = true,
    ["bard's family:"]         = true,
    ["vault warden team:"]     = true,
    ["howdah great beast:"]    = true,
    ["mumak:"]                 = true,
}

function onLoad()
	self.createButton({
		label = "Spawn Army",
		click_function = "spawnFromNotebook",
		function_owner = self,
		position = {12, -104, -20},
		rotation = {0, 90, 0},
		width = 1800,
		height = 400,
		font_size = 250
	})
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
local spawnQueue = {}

function processList(text, color)
	contents = self.getData().ContainedObjects
    local basePos = {
		x = 70,
		y = 1,
		z = -17
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
    local warbandBase = {x = basePos.x, z = basePos.z}
    local unit_pos = {
        x = basePos.x,
        y = basePos.y,
        z = basePos.z + 1.5
    }
    local floor = math.floor
    local hasHero = false
    local nextWarriorHeroPos = nil

	spawnQueue = {}
	for line in text:gmatch("%(%s*(.-)%s*%)") do --TODO fix gmatch bug here
        local count, name, wargear = line:match("^(%d*)x*%s*(.+:)%s*( *[%S ]*)%s*") --TODO check for match bug here
        if name and count ~= "0" then
            local fullName = wargear ~= "" and name .. " " .. wargear or name
            local fullNameLower = fullName:lower()
            if count ~= "" then
                if not hasHero then
                    broadcastToColor("Error: \"" .. name .. "\" found before any hero.", color, {1, 0, 0})
                elseif not NO_SPAWN[fullNameLower] then
                    for i = 1, tonumber(count) do
                        if nextWarriorHeroPos then
                            spawnQueue[#spawnQueue + 1] = {name = fullName, pos = nextWarriorHeroPos, color = color}
                            nextWarriorHeroPos = nil
                        else
                            spawnQueue[#spawnQueue + 1] = {name = fullName, pos = {x = unit_pos.x, y = unit_pos.y, z = unit_pos.z}, color = color}
                            modelIndex = modelIndex + 1
                            unit_pos.x = warbandBase.x + (modelIndex % 6) * 1.1
                            unit_pos.z = warbandBase.z + floor(modelIndex / 6) * 1.1
                        end
                        totalModels = totalModels + 1
                    end
                end
            else
                hasHero = true
                if NO_SPAWN[fullNameLower] then
                    nextWarriorHeroPos = {x = heroPos.x, y = heroPos.y, z = heroPos.z}
                else
                    spawnQueue[#spawnQueue + 1] = {name = fullName, pos = {x = heroPos.x, y = heroPos.y, z = heroPos.z}, color = color}
                    totalModels = totalModels + 1
                end
                warbandBase.x = heroPos.x
                warbandBase.z = heroPos.z + 1.5
                warbandIndex = warbandIndex + 1
                row = floor(warbandIndex / warbandsPerRow)
                col = warbandIndex % warbandsPerRow
                heroPos.x = basePos.x + row * rowSpacing
                heroPos.z = basePos.z + col * colSpacing
                unit_pos.x = warbandBase.x
                unit_pos.z = warbandBase.z
                modelIndex = 0
            end
        end
	end
	broadcastToColor(totalModels .. " Models | " .. floor(totalModels / 2) + 1 .. " Break | " .. floor(totalModels / 4) .. " Remaining", color, {0.2, 1, 0.2})
    startLuaCoroutine(self, "spawnCoroutine")
end

function spawnCoroutine()
    local i = 1
    while i <= #spawnQueue do
        for b = 1, SPAWN_BATCH_SIZE do
            if i > #spawnQueue then break end
            local task = spawnQueue[i]
            spawnNextFromQueue(task.name, task.pos, task.color)
            i = i + 1
        end
        coroutine.yield(0)
    end
    spawnQueue = {}
    contents = nil
    psu = {}
    return 1
end

function spawnNextFromQueue(name, pos, color)
	if name == "" or not pos then
		return
	end
    local displayName = name
    local nameLower = name:lower()
    local colonIdx = nameLower:find(":")
    local baseName = colonIdx and nameLower:sub(1, colonIdx) or nameLower

    local template = psu[nameLower] or psu[baseName]
    if not template then
        local baseMatch = nil
        for _, obj in ipairs(contents) do
            local objLower = obj["Nickname"]:lower()
            if objLower == nameLower then
                obj.LuaScript = modelScripts.getScript(obj.Tags)
                psu[nameLower] = obj
                template = obj
                break
            end
            if not baseMatch then
                local objColon = objLower:find(":")
                local objBase = objColon and objLower:sub(1, objColon) or objLower
                if objBase == baseName then
                    baseMatch = obj
                end
            end
        end
        if not template and baseMatch then
            baseMatch.LuaScript = modelScripts.getScript(baseMatch.Tags)
            psu[baseName] = baseMatch
            template = baseMatch
        end
    end

    if not template then
        broadcastToColor("Could not find: " .. displayName, color, {1, 0.5, 0})
        return
    end

    spawnObjectData({
        data = template,
        position = pos,
        callback_function = function(spawned)
            spawned.setName(displayName)
        end
    })
end
