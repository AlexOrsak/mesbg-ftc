--------------------------
-- CONFIG
--------------------------

RED_GRAVEYARD_POS  = { x = 35.47, y = 5.46, z = 24.92 }
BLUE_GRAVEYARD_POS = { x = 35.50, y = 5.46, z = -26.55 }

-- Real zone GUIDs
RED_GRAVEYARD_ZONE_GUID  = "7a8ed4"
BLUE_GRAVEYARD_ZONE_GUID = "92d8b0"

STACK_GAP = 0.2
BASE_Y_OFFSET = 0.0


--------------------------
-- INPUT HANDLER
--------------------------

function onScriptingButtonDown(index, playerColor)
    if index ~= 7 then return end

    if playerColor ~= "Red" and playerColor ~= "Blue" then
        broadcastToColor("Only Red and Blue have graveyards.", playerColor, {1, 0, 0})
        return
    end

    local targetPos = (playerColor == "Red") and RED_GRAVEYARD_POS or BLUE_GRAVEYARD_POS

    -- First: selected objects
    local selected = Player[playerColor].getSelectedObjects()
    if selected and #selected > 0 then
        local moved = sendSelectionToGraveyard(selected, targetPos, playerColor)
        if moved > 0 then scheduleGraveyardCount(playerColor) end
        return
    end

    -- Fallback: hovered model
    local hovered = Player[playerColor].getHoverObject()
    if hovered == nil then
        broadcastToColor("Select models or hover one, then press 7.", playerColor, {1, 1, 1})
        return
    end

    if hovered.getLock() then
        broadcastToColor("That object is locked and cannot be moved.", playerColor, {1, 0.5, 0})
        return
    end

    sendHoveredToGraveyard(hovered, targetPos, playerColor)
    scheduleGraveyardCount(playerColor)
end


--------------------------
-- MOVE: SELECTION
--------------------------

function sendSelectionToGraveyard(objects, basePos, playerColor)
    local currentHeight = 0
    local movedCount = 0

    for _, obj in ipairs(objects) do
        if not obj.getLock() then
            local bounds = obj.getBounds()
            local height = (bounds and bounds.size and bounds.size.y) or 1

            local target = {
                basePos.x,
                basePos.y + BASE_Y_OFFSET + currentHeight + height/2,
                basePos.z
            }

            obj.setPositionSmooth(target, false, false)
            obj.setRotationSmooth({0,180,0}, false, false)

            currentHeight = currentHeight + height + STACK_GAP
            movedCount   = movedCount + 1
        end
    end

    return movedCount
end


--------------------------
-- MOVE: HOVERED
--------------------------

function sendHoveredToGraveyard(obj, basePos, playerColor)
    local bounds = obj.getBounds()
    local height = (bounds and bounds.size and bounds.size.y) or 1

    local target = {
        basePos.x,
        basePos.y + height/2,
        basePos.z
    }

    obj.setPositionSmooth(target, false, false)
    obj.setRotationSmooth({0,180,0}, false, false)
end


--------------------------
-- DEAD PILE COUNTING
--------------------------

function scheduleGraveyardCount(playerColor)
    Wait.time(function() graveyardCountNow(playerColor) end, 2)
end

function graveyardCountNow(playerColor)
    local zoneGuid = (playerColor == "Red") and RED_GRAVEYARD_ZONE_GUID or BLUE_GRAVEYARD_ZONE_GUID
    local zone = getObjectFromGUID(zoneGuid)

    if not zone then
        printToColor("Dead pile zone missing for " .. playerColor .. ".", playerColor)
        return
    end

    local objs = zone.getObjects()
    local count = 0

    -- Count **only unlocked**
    for _, obj in ipairs(objs) do
        if not obj.getLock() then
            count = count + 1
        end
    end

    -- ✔ PRINT TO CHAT ONLY (no on-screen popup)
    printToColor(playerColor .. " dead pile: " .. tostring(count), playerColor)
end
