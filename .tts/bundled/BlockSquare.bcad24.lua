local bagGUID = "209038"
local objectiveGUIDsToSpawn = {
    "54fe7f", "9bbc73", "f6b634", "9ae601", "9b07ac", "71360b"
}
local objectiveName = "Objective"
local spawnedObjectiveGUIDs = {}

function onLoad()
    -- Better random seed (mix OS time + this object's GUID hash)
    local guid = self.getGUID() or ""
    local hash = 0
    for i = 1, #guid do
        hash = hash + string.byte(guid, i)
    end
    math.randomseed(os.time() + hash)

    self.createButton({
        click_function = "placeHeirloomsObjectives",
        function_owner = self,
        label = "Place Heirlooms Objectives",
        position = {-4, 3, 0},
        width = 4400,
        height = 900,
        font_size = 350
    })

    self.createButton({
        click_function = "resetObjectives",
        function_owner = self,
        label = "Reset Objectives",
        position = {4, 3, 0},
        width = 2600,
        height = 700,
        font_size = 250
    })

    self.createButton({
        click_function = "raiseObjectives",
        function_owner = self,
        label = "+",
        position = {8.1, 3, 0},
        width = 800,
        height = 700,
        font_size = 400
    })

    self.createButton({
        click_function = "lowerObjectives",
        function_owner = self,
        label = "–",
        position = {9.6, 3, 0},
        width = 800,
        height = 700,
        font_size = 400
    })
end

function placeHeirloomsObjectives()
    local bag = getObjectFromGUID(bagGUID)
    if not bag then
        print("Error: Bag with GUID " .. bagGUID .. " not found.")
        return
    end

    spawnedObjectiveGUIDs = {}

    local center = {x = 0, y = 1.5, z = 0}
    local radius = 12 -- 6 inches
    local angles = {270, 330, 30, 90, 150, 210}
    local shuffledAngles = shuffleTable(angles)

    for i, objGUID in ipairs(objectiveGUIDsToSpawn) do
        local angle = shuffledAngles[i]
        local rad = math.rad(angle)
        local pos = {
            x = center.x + radius * math.cos(rad),
            y = center.y,
            z = center.z + radius * math.sin(rad)
        }

        bag.takeObject({
            guid = objGUID,
            position = pos,
            rotation = {0, 0, 0},
            smooth = false,
            callback_function = function(obj)
                obj.setName(objectiveName)
                obj.lock()
                table.insert(spawnedObjectiveGUIDs, obj.getGUID())
            end
        })
    end
end

function resetObjectives()
    local bag = getObjectFromGUID(bagGUID)
    if not bag then
        print("Error: Bag with GUID " .. bagGUID .. " not found.")
        return
    end

    local count = 0
    for i = #spawnedObjectiveGUIDs, 1, -1 do
        local obj = getObjectFromGUID(spawnedObjectiveGUIDs[i])
        if obj then
            obj.unlock()
            bag.putObject(obj)
            count = count + 1
        end
        table.remove(spawnedObjectiveGUIDs, i)
    end

    print(count .. " objectives returned to the bag.")
end

function raiseObjectives()
    moveObjectivesVertical(0.5)
end

function lowerObjectives()
    moveObjectivesVertical(-0.5)
end

function moveObjectivesVertical(offsetY)
    for _, guid in ipairs(spawnedObjectiveGUIDs) do
        local obj = getObjectFromGUID(guid)
        if obj then
            local pos = obj.getPosition()
            obj.setPosition({pos.x, pos.y + offsetY, pos.z})
        end
    end
end

function shuffleTable(t)
    local n = #t
    for i = n, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end
