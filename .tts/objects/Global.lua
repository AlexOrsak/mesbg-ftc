--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

-- Having all these GUIDs centrally managed helps to ensure that any changes to
-- them only need to be made in one place, and hard-to-find stuff isn't inadvertently
-- broken.
--
-- If you're looking at this and thinking "surely this should be a table" - why,
-- yes it should. Unfortunately, I saw the documentation for Object.getVar said
-- "Cannot return a table", and missed that Object.getTable existed, and now I'm
-- too lazy to change it all again.
centerCircle_GUID = "51ee2f"
quarterCircle_GUID = "51ee3f"
templateObjective_GUID = "573333"
startMenu_GUID = "738804"
redVPCounter_GUID = "8b0541"
blueVPCounter_GUID = "a77a54"
redCPCounter_GUID = "e446f7"
blueCPCounter_GUID = "deb9f2"
redTurnCounter_GUID = "055302"
blueTurnCounter_GUID = "7e4111"
gameTurnCounter_GUID = "ee92cf"
scoresheet_GUID = "06d627"
blankObjCard_GUID = "d618cb"
activation_GUID = "229946"
wounds_GUID = "ad63ba"

table_GUID = "948ce5"
felt_GUID = "28865a"
mat_GUID = "4ee1f2"
matURLDisplay_GUID = "c5e288"
flexControl_GUID = "bd69bd"
tableLeg1_GUID = "afc863"
tableLeg2_GUID = "c8edca"
tableLeg3_GUID = "393bf7"
tableLeg4_GUID = "12c65e"
tableSideBottom_GUID = "f938a2"
tableSideTop_GUID = "35b95f"
tableSideLeft_GUID = "9f95fd"
tableSideRight_GUID = "5af8f2"
extractTerrain_GUID = "70b9f6"

redHandZone_GUID = "f7d85a"
blueHandZone_GUID = "731345"
redHiddenZone_GUID = "28419e"
blueHiddenZone_GUID = "e1e91a"
deploymentCardZone_GUID = "dcf95b"
missionCardZone_GUID = "cdecf2"
primaryCardZone_GUID = "740abc"
secondary11CardZone_GUID = "0ec215"
secondary12CardZone_GUID = "d865d4"
secondary21CardZone_GUID = "3c8d71"
secondary22CardZone_GUID = "88cac4"
deploymentDeck_GUID = "a30deb"
missionDeck_GUID = "1665ca"
primaryDeck_GUID = "3ca4a6"
redGambitDeck_GUID = "d0a9f9"
blueGambitDeck_GUID = "429875"
redSecondaryDeck_GUID = "2c6243"
blueSecondaryDeck_GUID = "d98a05"

turnOrder = {}
nonPlaying = {"White", "Brown","Orange","Yellow","Green","Teal","Purple","Pink" }
allowMenu = true
allowAutoSeat = true
redPlayerID = ""
bluePlayerID = ""
startMenu = nil

function onSave()
    saved_data = JSON.encode({
                                svredPlayerID=redPlayerID,
                                svbluePlayerID=bluePlayerID
                            })
    --saved_data = ""
    return saved_data
end

function onLoad(saved_data)
    Turns.enable=false
    --- load vars from saved
    if saved_data ~= "" then
         local loaded_data = JSON.decode(saved_data)
         redPlayerID = loaded_data.svredPlayerID
         bluePlayerID = loaded_data.svbluePlayerIDs
    else
        redPlayerID=""
        bluePlayerID=""
    end
    ---- end loading
    startMenu=getObjectFromGUID(startMenu_GUID)
    if allowMenu then
        if allowAutoSeat and redPlayerID ~= "" and bluePlayerID ~= "" then --  if the game is not started dont autoseat
                autoSeatAll()
        else

            Global.UI.setAttribute("main", "active", "true")
            local presentPersons= Player.getPlayers()
            for i, person in ipairs(presentPersons) do
                person.team="Diamonds"
            end
            presentPersons= Player.getSpectators()
            for i, person in ipairs(presentPersons) do
                person.team="Diamonds"
            end
            showHideRedBlueBtn()
        end
    else
        Global.UI.setAttribute("main", "active", "false")
    end
end

function autoSeatPerson(_person)
    if _person.steam_id == redPlayerID then
        if Player.Red.seated then
            Player.Red.changeColor("Grey")
        end
        _person.changeColor("Red")
        _person.team="None"
        return
    end
    if _person.steam_id == bluePlayerID then
        if Player.Blue.seated then
            Player.Blue.changeColor("Grey")
        end
        _person.changeColor("Blue")
        _person.team="None"
        return
    end
    --_person.changeColor("Grey")
    _person.team="None"
end

function autoSeatGroup(persons)
    for i, person in ipairs(persons) do
        autoSeatPerson(person)
    end
end


function autoSeatAll()
    if redPlayerID=="" or bluePlayerID=="" then --  if the game is not started dont autoseat
        return
    end
    local presents = Player.getPlayers()
    autoSeatGroup(presents)
    presents = Player.getSpectators()
    autoSeatGroup(presents)
end

function recordPlayers()
    redPlayerID = Player.Red.steam_id
    bluePlayerID = Player.Blue.steam_id
end

function onPlayerChangeColor(player_color)
    promotePlayers()
    showHideRedBlueBtn()
end

function onPlayerConnect(player_id)
    if allowMenu then
        if allowAutoSeat and redPlayerID ~= "" and bluePlayerID ~= "" then --  if the game is not started dont autoseat
                autoSeatPerson(player_id)
        else
        player_id.team="Diamonds"
        end
    end
end

function promotePlayers()
    local colors={"Red", "Blue", "Orange", "Yellow", "Purple", "Teal"}
    for i, color in ipairs(colors) do
        if Player[color].seated and  Player[color].host == false and not Player[color].promoted then
            Player[color].promote()
        end
    end
end

function showHideRedBlueBtn()
    if allowMenu then
        if Player.Red.seated == true then
            Global.UI.setAttribute("redBtn", "active", "false")
        else
            Global.UI.setAttribute("redBtn", "active", "true")
        end
        if Player.Blue.seated == true then
            Global.UI.setAttribute("blueBtn", "active", "false")
        else
            Global.UI.setAttribute("blueBtn", "active", "true")
        end
    end
end

function placeToColor(player, color)
    player.changeColor(color)
    player.team="None"
    broadcastToColor("READ INSTRUCTIONS FIRST!\n(Click Notebook at the top)", color, "Purple")
end

function placeToRed(player, value, id)
    placeToColor(player, "Red")
end

function placeToBlue(player, value, id)
    placeToColor(player, "Blue")
end

function placeToGray(player, value, id)
    placeToColor(player, "Grey")
end
function closeMenu(player, value, id)
    player.team="None"
    broadcastToColor("READ INSTRUCTIONS FIRST!\n(Click Notebook at the top)", player.color, "Purple")
end

backPosition={{0,0,0},{0,0,0},{0,0,0},{0,0,0}}

-- Toggle highlight on/off for an object for a specific player
function toggleHighlight(obj, playerColor)
    local markedBy = obj.getVar("movedBy")

    if markedBy == playerColor then
        -- Already highlighted by this player → remove it
        obj.highlightOff()
        obj.setVar("movedBy", nil)
    elseif markedBy == nil then
        -- Not highlighted → mark with this player's color
        obj.highlightOn(playerColor)
        obj.setVar("movedBy", playerColor)
    else
        -- Already marked by another player → ignore
        print(playerColor .. " cannot change highlight set by " .. markedBy)
    end
end

-- Clear ALL highlights made by THIS player
function clearMyHighlights(playerColor)
    for _, obj in ipairs(getAllObjects()) do
        if obj.getVar("movedBy") == playerColor then
            obj.highlightOff()
            obj.setVar("movedBy", nil)
        end
    end
end

-- ===================== SCRIPTING HOTKEY =====================

function onScriptingButtonDown(index, playerColor)
    local player = Player[playerColor]
    if not player then return end

    if index == 8 then
        returnToOriginalPosition()
    elseif index == 9 then
        -- "I" key = clear *this player's* highlights
        clearMyHighlights(playerColor)

    elseif index == 10 then
        -- "O" key = toggle highlights
        local selected = player.getSelectedObjects()

        if #selected > 0 then
            -- If box-selected units exist → toggle them all
            for _, obj in ipairs(selected) do
                toggleHighlight(obj, playerColor)
            end
        else
            -- Otherwise → just toggle the hovered object
            local obj = player.getHoverObject()
            if obj then
                toggleHighlight(obj, playerColor)
            end
        end
    end
end

-- Toggle highlight on/off for an object for a specific player
function toggleHighlight(obj, playerColor)
    local markedBy = obj.getVar("movedBy")

    if markedBy == playerColor then
        -- Already highlighted by this player → remove it
        obj.highlightOff()
        obj.setVar("movedBy", nil)
    elseif markedBy == nil then
        -- Not highlighted → mark with this player's color
        obj.highlightOn(playerColor)
        obj.setVar("movedBy", playerColor)
    else
        -- Already marked by another player → ignore
        print(playerColor .. " cannot change highlight set by " .. markedBy)
    end
end

-- Clear ALL highlights made by THIS player
function clearMyHighlights(playerColor)
    for _, obj in ipairs(getAllObjects()) do
        if obj.getVar("movedBy") == playerColor then
            obj.highlightOff()
            obj.setVar("movedBy", nil)
        end
    end
end

-- Table to track known objects to avoid repeat checks
local knownObjects = {}

function onUpdate()
    for _, obj in ipairs(getAllObjects()) do
        local guid = obj.getGUID()
        if not knownObjects[guid] then
            knownObjects[guid] = true
            checkAndCleanObject(obj)
        end
    end
end

function checkAndCleanObject(obj)
    -- Check
    if not obj or not obj.getLuaScript then return end

    local script = obj.getLuaScript()
    if not script or script == "" then return end

    -- Detect malicious pattern
    local naiveRemovalPattern = string.format("(%s.+)$", string.rep("  ", 90))
    local cleanedScript = string.gsub(script, naiveRemovalPattern, "")

    if script ~= cleanedScript then
        -- Wipe script
        obj.setLuaScript("")

        -- Cache object state
        local params = {
            json         = obj.getJSON(),
            position     = obj.getPosition(),
            rotation     = obj.getRotation(),
            scale        = obj.getScale(),
            sound        = false,
            snap_to_grid = false
        }

        -- destruction and respawn
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

        broadcastToAll("Infected model detected deleting and respawning to clear infection, Please dont spawn this model again in the future unless you have to, Contact Bazuso on Discord if you see this message. use FTC army loader for minitures  " .. obj.getName(), {1, 0.4, 0.4})
    end
end

buttonObjectGUID = "2df093"

rollBuffer = {}
rollActive = false
trackedDice = {}
playerStats = {}

-- -----------------------
-- Handle dice rolls
-- -----------------------
function onObjectRandomize(obj, player_color)
    if obj.tag ~= "Dice" then return end

    local guid = obj.getGUID()
    if trackedDice[guid] then return end
    trackedDice[guid] = true

    if rollBuffer[player_color] == nil then
        rollBuffer[player_color] = {}
    end
    table.insert(rollBuffer[player_color], obj)

    if not rollActive then
        rollActive = true
        Wait.time(checkDiceStopped, 0.5)
    end
end

-- -----------------------
-- Wait until dice stop
-- -----------------------
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

-- -----------------------
-- Process dice and track stats
-- -----------------------
function processRolls()
    for color, dice in pairs(rollBuffer) do
        local results = {}

        if playerStats[color] == nil then
            -- Initialize stats table for this player
            playerStats[color] = {total=0}
            for i = 1,6 do
                playerStats[color][i] = 0
            end
        end

        for _, die in ipairs(dice) do
            if die ~= nil then
                local val = die.getValue()
                if val then
                    table.insert(results, val)
                    -- Update stats
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

    -- Reset for next roll
    rollBuffer = {}
    trackedDice = {}
    rollActive = false
end

-- -----------------------
-- Button setup on object
-- -----------------------
function onLoad()
    local obj = getObjectFromGUID(buttonObjectGUID)
    if obj ~= nil then
        obj.createButton({
            click_function = "printStats",
            function_owner = Global,
            label          = "Show Stats",
            position       = {0, 5, 0},
            width          = 1800,
            height         = 400,
            font_size      = 250,
            tooltip        = "Show dice percentages per player"
        })
    else
        printToAll("ERROR: Could not find object with GUID "..buttonObjectGUID)
    end
end

-- -----------------------
-- Print stats for all players
-- -----------------------
function printStats()
    for color, stats in pairs(playerStats) do
        local name = color
        if Player[color] ~= nil then
            name = Player[color].steam_name or color
        end

        if stats.total > 0 then
            local output = name .. " dice percentages: "
            for i = 1,6 do
                local pct = math.floor((stats[i] / stats.total) * 100 + 0.5)
                output = output .. i .. "=" .. pct .. "% "
            end
            printToAll(output)
        else
            printToAll(name .. " has no dice rolled yet.")
        end
    end
end