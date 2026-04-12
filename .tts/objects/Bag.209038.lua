local objectiveName = "Objective"
local spawnedObjectiveGUIDs = {}

function onLoad()
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
    if next(spawnedObjectiveGUIDs) ~= nil then
        return
    end
    spawnedObjectiveGUIDs = {}

    local center = {x = 0, y = 1.5, z = 0}
    local radius = 12
    local angles = {270, 330, 30, 90, 150, 210}
    local shuffledAngles = shuffleTable(angles)

    local i = 1
    for obj in self.getObjects() do
        local angle = shuffledAngles[i]
        local rad = math.rad(angle)
        local pos = {
            x = center.x + radius * math.cos(rad),
            y = center.y,
            z = center.z + radius * math.sin(rad)
        }

        self.takeObject({
            guid = objGUID,
            position = pos,
            rotation = {0, 0, 0},
            smooth = false,
            callback_function = function(obj)
                obj.setName(objectiveName)
                obj.lock()
                spawnedObjectiveGUIDs[i] = obj.getGUID()
            end
        })
        i = i + 1
    end
end

function resetObjectives()
    local count = 0
    for i = #spawnedObjectiveGUIDs, 1, -1 do
        local obj = getObjectFromGUID(spawnedObjectiveGUIDs[i])
        if obj then
            obj.unlock()
            self.putObject(obj)
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
    math.randomseed(os.clock())
    local n = #t
    for i = n, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end
