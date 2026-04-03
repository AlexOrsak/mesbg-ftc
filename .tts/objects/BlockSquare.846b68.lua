-- === MESBG Scenario Selector (Editable Layout Version v2) ===
-- Bag GUID that contains all scenario cards
local SCENARIO_BAG_GUID = "4f682e"

-- === SCENARIO POOLS ===
local scenarioPools = {
    {"Domination", "Capture & Control", "Breakthrough", "Stake a Claim"},
    {"To The Death", "Lords of Battle", "Assassination", "Contest of Champions"},
    {"Hold Ground", "Heirlooms of Ages Past", "Sites of Power", "Command the Battlefield"},
    {"Destroy the Supplies", "Retrieval", "Seize the Prizes", "Treasure Hoard"},
    {"Reconnoitre", "Storm the Camp", "Divide & Conquer", "Escort the Wounded"},
    {"Fog of War", "Clash by Moonlight", "Lead from the Front", "Convergence"}
}

-- === EASY LAYOUT SETTINGS ===
-- ↓↓↓ Only edit this section ↓↓↓
local layout = {
    scale = 0.50,         -- 🔧 Overall size multiplier (0.75 = 25% smaller)
    offsetX = 0,          -- 🔧 Move all buttons left/right
    offsetZ = 0,          -- 🔧 Move all buttons forward/backward

    -- 🆙 HEIGHT CONTROL
    uiHeight = 2,         -- 🔧 Raise/lower ALL buttons above the surface (increase to float higher)

    xSpacing = 6.0,       -- 🔧 Horizontal spacing between columns
    ySpacing = 0.45,      -- 🔧 Vertical spacing between scenario buttons
    rowSpacing = 4.5,     -- 🔧 Distance between top and bottom row
    startX = -6.0,        -- 🔧 Leftmost column starting X
    startZ = -4,          -- 🔧 Z position of top row

    slotWidth = 2400,     -- 🔧 Width of scenario boxes
    slotHeight = 100,     -- 🔧 Height of scenario boxes
    fontSize = 100,       -- 🔧 Font size for scenario boxes
    slotColor = {0, 0, 0, 0.0},  -- transparent black

    -- 🎲 RANDOM BUTTON SETTINGS
    randomButtonWidth = 2400,
    randomButtonHeight = 120,
    randomButtonOffset = -2.6,   -- how far below the last scenario it appears
    randomButtonFont = 100,
    randomButtonColor = {0.1, 0.4, 0.1, 1},

    -- 📜 SPAWN ALL BUTTON SETTINGS (NEW)
    spawnAllButtonWidth = 2400,      -- width of "Spawn All" button
    spawnAllButtonHeight = 120,      -- height of "Spawn All" button
    spawnAllButtonOffset = -0.5,      -- distance BELOW the Random Pool button
    spawnAllButtonFont = 100,        -- font size for "Spawn All" button
    spawnAllButtonColor = {0.2, 0.2, 0.6, 1},  -- blue
}
-- ↑↑↑ Only edit this section ↑↑↑

-- === INTERNALS ===
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

        -- 🎲 Random Pool Button
        local randFunc = "rand_pool_" .. i
        self.setVar(randFunc, function(_, _) randomFromPool(i) end)
        self.createButton({
            label = "🎲 Random Pool " .. i,
            position = {baseX, layout.uiHeight, baseZ - (zOffset + layout.randomButtonOffset) * layout.scale},
            width = layout.randomButtonWidth * layout.scale,
            height = layout.randomButtonHeight * layout.scale,
            font_size = layout.randomButtonFont * layout.scale,
            click_function = randFunc,
            function_owner = self,
            color = layout.randomButtonColor,
            font_color = {1, 1, 1, 1}
        })

        -- 📜 Spawn All From Pool Button (below random button)
        local spawnAllFunc = "spawn_all_pool_" .. i
        self.setVar(spawnAllFunc, function(_, _) spawnAllFromPool(i) end)
        self.createButton({
            label = "📜 Spawn All From Pool " .. i,
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

    -- 🎲 FULL RANDOM button (centered below)
    self.setVar("full_random", function(_, _) randomFromAll() end)
    self.createButton({
        label = "🎲 FULL RANDOM",
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

-- === Scenario Spawn Logic ===
function spawnScenario(name)
    local bag = getObjectFromGUID(SCENARIO_BAG_GUID)
    if not bag then
        broadcastToAll("❌ Scenario bag not found!", {1,0,0})
        return
    end

    for _, obj in ipairs(bag.getObjects()) do
        if string.lower(obj.name) == string.lower(name) then
            bag.takeObject({
                guid = obj.guid,
                position = self.positionToWorld({0, 2, 0}),
                smooth = false
            })
            broadcastToAll("📜 Spawned: " .. name, {0,1,0})
            return
        end
    end
    broadcastToAll("⚠️ '" .. name .. "' not found in bag!", {1,0.5,0})
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

-- 📜 Spawn All From Pool Function (NEW)
function spawnAllFromPool(i)
    local pool = scenarioPools[i]
    if not pool then return end
    for _, scName in ipairs(pool) do
        spawnScenario(scName)
    end
end
