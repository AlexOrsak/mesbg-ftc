local SCENARIO_BAG_GUID = "4f682e"

local scenarioPools = {
    {"Domination", "Capture & Control", "Breakthrough", "Stake a Claim"},
    {"To The Death", "Lords of Battle", "Assassination", "Contest of Champions"},
    {"Hold Ground", "Heirlooms of Ages Past", "Sites of Power", "Command the Battlefield"},
    {"Destroy the Supplies", "Retrieval", "Seize the Prizes", "Treasure Hoard"},
    {"Reconnoitre", "Storm the Camp", "Divide & Conquer", "Escort the Wounded"},
    {"Fog of War", "Clash by Moonlight", "Lead from the Front", "Convergence"}
}

local layout = {
    scale = 0.50,
    offsetX = 0,
    offsetZ = 0,

    uiHeight = 2,

    xSpacing = 6.0,
    ySpacing = 0.45,
    rowSpacing = 4.5,
    startX = -6.0,
    startZ = -4,

    slotWidth = 2400,
    slotHeight = 100,
    fontSize = 100,
    slotColor = {0, 0, 0, 0.0},

    randomButtonWidth = 2400,
    randomButtonHeight = 120,
    randomButtonOffset = -2.6,
    randomButtonFont = 100,
    randomButtonColor = {0.1, 0.4, 0.1, 1},

    spawnAllButtonWidth = 2400,
    spawnAllButtonHeight = 120,
    spawnAllButtonOffset = -0.5,
    spawnAllButtonFont = 100,
    spawnAllButtonColor = {0.2, 0.2, 0.6, 1},
}

function onLoad()
    createAllButtons()
end

function createAllButtons()
    self.clearButtons()
    for i, pool in ipairs(scenarioPools) do
        local isTopRow = (i > 3)
        local rowOffset = isTopRow and 0 or -layout.rowSpacing
        local colIndex = ((i - 1) % 3)
        local baseX = (layout.startX + colIndex * layout.xSpacing) * layout.scale + layout.offsetX
        local baseZ = (layout.startZ + rowOffset) * layout.scale + layout.offsetZ

        local zOffset = 0
        for scIndex = #pool, 1, -1 do
            local scName = pool[scIndex]
            local funcName = string.format("spawn_%d_%d", i, scIndex)
            self.setVar(funcName, function(_, _) spawnScenario(scName) end)

            self.createButton({
                label = "",
                position = {baseX, layout.uiHeight, baseZ - zOffset * layout.scale},
                width = layout.slotWidth * layout.scale,
                height = layout.slotHeight * layout.scale,
                font_size = layout.fontSize * layout.scale,
                click_function = funcName,
                function_owner = self,
                color = layout.slotColor,
                font_color = {1, 1, 1, 1}
            })
            zOffset = zOffset + layout.ySpacing
        end

        local randFunc = "rand_pool_" .. i
        self.setVar(randFunc, function(_, _) randomFromPool(i) end)
        self.createButton({
            label = "Random Pool " .. i,
            position = {baseX, layout.uiHeight, baseZ - (zOffset + layout.randomButtonOffset) * layout.scale},
            width = layout.randomButtonWidth * layout.scale,
            height = layout.randomButtonHeight * layout.scale,
            font_size = layout.randomButtonFont * layout.scale,
            click_function = randFunc,
            function_owner = self,
            color = layout.randomButtonColor,
            font_color = {1, 1, 1, 1}
        })

        local spawnAllFunc = "spawn_all_pool_" .. i
        self.setVar(spawnAllFunc, function(_, _) spawnAllFromPool(i) end)
        self.createButton({
            label = "Spawn All From Pool " .. i,
            position = {baseX, layout.uiHeight, baseZ - (zOffset + layout.randomButtonOffset + layout.spawnAllButtonOffset) * layout.scale},
            width = layout.spawnAllButtonWidth * layout.scale,
            height = layout.spawnAllButtonHeight * layout.scale,
            font_size = layout.spawnAllButtonFont * layout.scale,
            click_function = spawnAllFunc,
            function_owner = self,
            color = layout.spawnAllButtonColor,
            font_color = {1, 1, 1, 1}
        })
    end

    self.setVar("full_random", function(_, _) randomFromAll() end)
    self.createButton({
        label = "FULL RANDOM",
        position = {layout.offsetX, layout.uiHeight, (layout.startZ - layout.rowSpacing * 2.4) * layout.scale + layout.offsetZ},
        width = 3200 * layout.scale,
        height = 220 * layout.scale,
        font_size = 150 * layout.scale,
        color = {0.6, 0.1, 0.1, 1},
        font_color = {1, 1, 1, 1},
        click_function = "full_random",
        function_owner = self
    })
end

function spawnScenario(name)
    local bag = getObjectFromGUID(SCENARIO_BAG_GUID)
    if not bag then
        broadcastToAll("Scenario bag not found!", {1,0,0})
        return
    end

    for _, obj in ipairs(bag.getObjects()) do
        if string.lower(obj.name) == string.lower(name) then
            bag.takeObject({
                guid = obj.guid,
                position = self.positionToWorld({0, 2, 0}),
                smooth = false
            })
            broadcastToAll("Spawned: " .. name, {0,1,0})
            return
        end
    end
    broadcastToAll(name .. "' not found in bag!", {1,0.5,0})
end

function randomFromPool(i)
    local pool = scenarioPools[i]
    if not pool then return end
    spawnScenario(pool[math.random(#pool)])
end

function randomFromAll()
    local all = {}
    for _, pool in ipairs(scenarioPools) do
        for _, s in ipairs(pool) do table.insert(all, s) end
    end
    spawnScenario(all[math.random(#all)])
end

function spawnAllFromPool(i)
    local pool = scenarioPools[i]
    if not pool then return end
    for _, scName in ipairs(pool) do
        spawnScenario(scName)
    end
end
