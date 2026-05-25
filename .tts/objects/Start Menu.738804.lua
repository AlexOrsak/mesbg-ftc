local Utils = require("utils")
local centerCircle_GUID = "51ee2f"
local quarterCircle_GUID = "51ee3f"
local inGame = false
local hideText = "Hide"
local showText = "Show"
local mat_size = 48
local half_mat = mat_size * 0.5
local deployLineHeight = 2.1
local deployLineYPos = 2.0
local deployOffset = 0
local lineScaleDefault = {x = mat_size, y = deployLineHeight, z = 0.02}
local set_objs = { deployments = {}, objectives = {}, maelstrom = {}, quarters = {}, corners = {}, centers = {}}
local DeployZonesData = {
    {
        name = "Domination",
        objectivesID = 2,
        draw = {{
            type = "line",
            color = "White",
            position = "z",
            fromCenter = 0
        }}
    }, {
        name = "To The Death",
        objectivesID = 1,
        draw = {{
            type = "line",
            color = "Teal",
            position = "-z",
            fromCenter = 12
        }, {
            type = "line",
            color = "Red",
            position = "z",
            fromCenter = 12
        }}
    }, {
        name = "Hold Ground",
        objectivesID = 2,
        draw = {}
    }, {
        name = "Lords of Battle",
        objectivesID = 1,
        draw = {{
            type = "line",
            color = "White",
            position = "z",
            fromCenter = 0
        }}
    }, {
        name = "Reconnoitre",
        objectivesID = 1,
        draw = {}
    }, {
        name = "Clash By MoonLight",
        objectivesID = 2,
        draw = {{
            type = "line",
            color = "Teal",
            position = "-z",
            fromCenter = 12
        }, {
            type = "line",
            color = "Red",
            position = "z",
            fromCenter = 12
        }}
    }, {
        name = "Seize The Prizes",
        objectivesID = 4,
        draw = {{
            type = "line",
            color = "Teal",
            position = "-z",
            fromCenter = 12
        }, {
            type = "line",
            color = "Red",
            position = "z",
            fromCenter = 12
        }}
    }, {
        name = "Contest of Champions",
        objectivesID = 1,
        draw = {{
            type = "line",
            color = "White",
            position = "z",
            fromCenter = 0
        },{
            type = "line",
            color = "Red",
            position = "z",
            fromCenter = 12
        }, {
            type = "line",
            color = "Teal",
            position = "z",
            fromCenter = -12
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Teal",
            position = "z",
            fromCenter = 3,
            rot = {x = 0, y = 270, z = 0},
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Teal",
            position = "z",
            fromCenter = 3,
            rot = {x = 0, y = 180, z = 0},
        },{
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Red",
            position = "z",
            fromCenter = 3,
            rot = {x = 0, y = 90, z = 0},
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Red",
            position = "z",
            fromCenter = 3,
            rot = {x = 0, y = 0, z = 0},
        }}
    }, {
        name = "Capture and Control",
        objectivesID = 3,
        draw = {
        {
            type = "line",
            color = "White",
            position = "z",
            fromCenter = 0
        }, {
            type = "line",
            color = "Red",
            position = "z",
            fromCenter = 12
        }, {
            type = "line",
            color = "Teal",
            position = "z",
            fromCenter = -12
        }}
    }, {
        name = "Heirloom of Ages Past ",
        objectivesID = 1,
        draw = {}
    }, {
        name = "Fog of War",
        objectivesID = 1,
        draw = {{
            type = "line",
            color = "Teal",
            position = "-z",
            fromCenter = 12
        }, {
            type = "line",
            color = "Red",
            position = "z",
            fromCenter = 12
        }}
    }, {
        name = "Storm the Camp",
        objectivesID = 1,
        draw = {{
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Teal",
            position = "z",
            fromCenter = 18,
            centerX = -24,
            centerZ = -24,
            rot = {x = 0, y = 90, z = 0},
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Red",
            position = "z",
            fromCenter = 18,
            centerX = 24,
            centerZ = 24,
            rot = {x = 0, y = 270, z = 0},
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Teal",
            position = "z",
            fromCenter = 18,
            centerX = 24,
            centerZ = -24,
            rot = {x = 0, y = 0, z = 0},
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Red",
            position = "z",
            fromCenter = 18,
            centerX = -24,
            centerZ = 24,
            rot = {x = 0, y = 180, z = 0},
        }}
    }, {
        name = "Command the Battlefield",
        objectivesID = 1,
        draw = {{
            type = "circle",
            subtype = centerCircle_GUID,
            color = "White",
            position = "z",
            fromCenter = 12
        }}
    }, {
        name = "Retrieval",
        objectivesID = 9,
        draw = {{
            type = "diagonal",
            color = "Red",
            position = "x",
            fromCenter = 3
        }, {
            type = "diagonal",
            color = "Teal",
            position = "x",
            fromCenter = -3
        }}
    }, {
        name = "Breakthrough",
        objectivesID = 5,
        draw = {{
            type = "line",
            color = "White",
            position = "z",
            fromCenter = 0
        }}
    }, {
        name = "Destroy The Supplies",
        objectivesID = 6,
        draw = {{
            type = "line",
            color = "Teal",
            position = "-z",
            fromCenter = 12
        }, {
            type = "line",
            color = "Red",
            position = "z",
            fromCenter = 12
        }}
    }, {
        name = "Divide & Conquer",
        objectivesID = 4,
        draw = {{
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Teal",
            position = "z",
            fromCenter = 12,
            rot = {x = 0, y = 270, z = 0},
            centerX = 24,
            centerZ = 24
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Red",
            position = "-z",
            fromCenter = 12,
            rot = {x = 0, y = 0, z = 0},
            centerX = 24,
            centerZ = -24
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Teal",
            position = "-z",
            fromCenter = 12,
            rot = {x = 0, y = 90, z = 0},
            centerX = -24,
            centerZ = -24
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Red",
            position = "z",
            fromCenter = 12,
            rot = {x = 0, y = 180, z = 0},
            centerX = -24,
            centerZ = 24
        }}
    }, {
        name = "Assassination",
        objectivesID = 1,
        draw = {{
            type = "line",
            color = "White",
            position = "z",
            fromCenter = 0
        }}
    }, {
        name = "Stake a Claim ",
        objectivesID = 3,
        draw = {{
            type = "line",
            color = "Teal",
            position = "-z",
            fromCenter = 12
        }, {
            type = "line",
            color = "Red",
            position = "z",
            fromCenter = 12
        }}
    }, {
        name = "Sites of Power",
        objectivesID = 7,
        draw = {}
    }, {
        name = "Treasure Horde",
        objectivesID = 8,
        draw = {{
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Red",
            position = "z",
            fromCenter = 12,
            rot = {x = 0, y = 180, z = 0},
            centerX = 0,
            centerZ = 24
        },{
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Red",
            position = "z",
            fromCenter = 12,
            rot = {x = 0, y = 270, z = 0},
            centerX = 0,
            centerZ = 24
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Teal",
            position = "z",
            fromCenter = 12,
            rot = {x = 0, y = 90, z = 0},
            centerX = 0,
            centerZ = -24
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Teal",
            position = "z",
            fromCenter = 12,
            rot = {x = 0, y = 0, z = 0},
            centerX = 0,
            centerZ = -24
        }}
    }, {
        name = "Escort the Wounded",
        objectivesID = 6,
        draw = {{
            type = "line",
            color = "Teal",
            position = "-z",
            fromCenter = 12
        }, {
            type = "line",
            color = "Red",
            position = "z",
            fromCenter = 12
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Red",
            position = "z",
            fromCenter = 12,
            rot = {x = 0, y = 270, z = 0},
            centerX = 24,
            centerZ = 24
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "White",
            position = "-z",
            fromCenter = 12,
            rot = {x = 0, y = 0, z = 0},
            centerX = 24,
            centerZ = -24
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "White",
            position = "-z",
            fromCenter = 12,
            rot = {x = 0, y = 90, z = 0},
            centerX = -24,
            centerZ = -24
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "White",
            position = "z",
            fromCenter = 12,
            rot = {x = 0, y = 180, z = 0},
            centerX = -24,
            centerZ = 24
        }}
    }, {
        name = "Lead from the Front",
        objectivesID = 4,
        draw = {{
            type = "line",
            color = "Teal",
            position = "-z",
            fromCenter = 12
        }, {
            type = "line",
            color = "Red",
            position = "z",
            fromCenter = 12
        }}
    }, {
        name = "Convergence",
        objectivesID = 5,
        draw = {{
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Teal",
            position = "z",
            fromCenter = 12,
            rot = {x = 0, y = 270, z = 0},
            centerX = 24,
            centerZ = 24
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Red",
            position = "-z",
            fromCenter = 12,
            rot = {x = 0, y = 0, z = 0},
            centerX = 24,
            centerZ = -24
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Teal",
            position = "-z",
            fromCenter = 12,
            rot = {x = 0, y = 90, z = 0},
            centerX = -24,
            centerZ = -24
        }, {
            type = "circle",
            subtype = quarterCircle_GUID,
            color = "Red",
            position = "z",
            fromCenter = 12,
            rot = {x = 0, y = 180, z = 0},
            centerX = -24,
            centerZ = 24
        }}
    }, {
        name = "None",
        objectivesID = 1,
        draw = {}
    }
}
local deploySelected = #DeployZonesData

local function makeToggleBtn(lbl, clickFn, x)
    return {
        label = showText .. lbl,
        click_function = clickFn,
        function_owner = self,
        position = {x, 5, 0},
        rotation = {0, 0, 0},
        height = 1500,
        width = 2600,
        font_size = 300,
        lbl_var = lbl
    }
end

local function makeNavBtn(label, clickFn, x)
    return {
        label = label,
        click_function = clickFn,
        function_owner = self,
        position = {x, 5, 1},
        rotation = {0, 0, 0},
        height = 750,
        width = 800,
        font_size = 300,
        color = {0, 0, 0},
        font_color = {1, 1, 1}
    }
end

local function makeOffsetGroup(label, upFn, downFn, x)
    return {
        menu = {label = label, click_function = "none",  function_owner = self, rotation = {0,0,0}, position = {x, 5,    0}, height = 450, width = 1000, font_size = 150, color = {0,0,0}, font_color = {1,1,1}},
        up   = {label = "+",   click_function = upFn,   function_owner = self, rotation = {0,0,0}, position = {x, 5, -1.2}, height = 450, width = 800,  font_size = 300, color = {0,0,0}, font_color = {1,1,1}},
        down = {label = "-",   click_function = downFn, function_owner = self, rotation = {0,0,0}, position = {x, 5,  1.2}, height = 450, width = 800,  font_size = 300, color = {0,0,0}, font_color = {1,1,1}},
    }
end

local function makeUpDown(baseFn, upName, downName)
    _G[upName]   = function() baseFn(true) end
    _G[downName] = function() baseFn(false) end
end

local deployMenuBtn = {
	label = "Select Deployment Zones",
	click_function = "none",
	function_owner = self,
	position = {-18, 5, -1},
	rotation = {0, 0, 0},
	height = 750,
	width = 8000,
	font_size = 500,
	color = {0, 0, 0},
	font_color = {1, 1, 1}
}
local scenarioDisplay = {
	click_function = "none",
	function_owner = self,
	position = {-18, 5, 1},
	rotation = {0, 0, 0},
	height = 750,
	width = 6000,
	font_size = 400
}
local deployUpBtn   = makeNavBtn("->", "deployUp",   -10.5)
local deployDownBtn = makeNavBtn("<-", "deployDown",  -25.5)
local deployOffsetBtns = makeOffsetGroup("Deploy\nHeight", "deployOffsetUp", "deployOffsetDown", -28.5)
local deployIngameLbl = "\nDeployment\nZones"
local deployIngameBtn = {
	label = showText .. "/" .. hideText .. deployIngameLbl,
	click_function = "showHideIngameDeployment",
	function_owner = self,
	position = {0, 5, 0},
	rotation = {0, 0, 0},
	height = 1500,
	width = 2600,
	font_size = 300
}
local objectivesOffset = 0
local objectivesData = { -- (x, z) coordinates of objectives, relative to center of the board)
    [1] = {}, -- no objectives
    [2] = {{0, 0}}, -- one objective in the center
    [3] = {{0, 0}, {12, 0}, {0, -12}, {0, 12}, {-12, 0}},
    [4] = {{-12, 0}, {12, 0}, {0, 0}},
    [5] = {{0, -12}, {0, 12}, {12, 0}, {-12, 0}},
    [6] = {{12, -12}, {0, -12}, {-12, -12}, {12, 12}, {0, 12}, {-12, 12}},
    [7] = {{12, -12}, {-12, -12}, {12, 12}, {-12, 12}},
    [8] = {{12, -6}, {0, -6}, {-12, -6}, {12, 6}, {0, 6}, {-12, 6}},
    [9] = {{-9.84, -9.84}, {9.84, 9.84}}
}
local objectivesOffsetBtns = makeOffsetGroup("Obj.\nHeight", "objectivesOffsetUp", "objectivesOffsetDown", -8)
local quartersBtn  = makeToggleBtn("\nTable Quarters", "showHideQuarters", 9)
local maelstromBtn = makeToggleBtn("\nMaelstrom", "showHideMaelstrom", 27)
local cornersBtn   = makeToggleBtn("\nCorners", "showHideCorners", 21)
local centersBtn   = makeToggleBtn("\nCenter", "showHideCenters", 15)

local lockInBtn = {
	label = "Lock Scenario",
	click_function = "startGame",
	function_owner = self,
	position = {0, 5, -1},
	rotation = {0, 0, 0},
	height = 750,
	width = 5000,
	font_size = 500,
	color = {0, 0.6, 0},
	font_color = {1, 1, 1}
}

local function clearObjects(key)
    for _, obj in ipairs(set_objs[key]) do obj.destroy() end
    set_objs[key] = {}
end

local function showHideObjects(key, btn, spawnFn)
    if #set_objs[key] == 0 then
        btn.label = hideText .. btn.lbl_var
        spawnFn()
    else
        btn.label = showText .. btn.lbl_var
        clearObjects(key)
    end
    writeMenus()
end

function onLoad(saved_data)
	if saved_data ~= "" then
		local jsd = JSON.decode(saved_data)
        inGame = jsd.svInGame or false
		deploySelected = jsd.svDeploySelected
		Notes.setNotes(jsd.svNotes or "")
	end
	writeMenus()
	if not inGame then
		printToAll("Welcome to MESBG FTC", "Yellow")
	end
end

function onSave()
	local saved_data = JSON.encode({
		svInGame = inGame,
		svDeploySelected = deploySelected,
		svNotes = getNotes(),
	})
	return saved_data
end

function writeMenus()
	self.clearButtons()
	if inGame == false then
		self.createButton(lockInBtn)
		if DeployZonesData[deploySelected] ~= nil then
			if deploySelected == #DeployZonesData then
				scenarioDisplay.label = "-"
			else
				scenarioDisplay.label = "Scenario " .. deploySelected .. " - " .. DeployZonesData[deploySelected].name
			end
		end
		self.createButton(scenarioDisplay)
		self.createButton(deployUpBtn)
		self.createButton(deployDownBtn)
		self.createButton(deployMenuBtn)
		self.createButton(objectivesOffsetBtns.down)
		self.createButton(objectivesOffsetBtns.up)
		self.createButton(objectivesOffsetBtns.menu)
    else
        self.createButton(deployIngameBtn)
	end
	if #set_objs.deployments > 0 then
		deployIngameBtn.label = hideText .. deployIngameLbl
	end
	if #set_objs.centers > 0 then
		centersBtn.label = hideText .. centersBtn.lbl_var
	end
	self.createButton(centersBtn)
	self.createButton(quartersBtn)
	self.createButton(maelstromBtn)
	self.createButton(cornersBtn)
	self.createButton(deployOffsetBtns.menu)
	self.createButton(deployOffsetBtns.up)
	self.createButton(deployOffsetBtns.down)
end

function startGame()
	Global.call("recordPlayers")
	inGame = true
	for key in pairs(set_objs) do clearObjects(key) end
	writeMenus()
end

function objectivesOffsetUpDown(upDown)
	if upDown then
		objectivesOffset = objectivesOffset + 0.5
		if objectivesOffset > 25 then
			objectivesOffset = 25
		end
	else
		objectivesOffset = objectivesOffset - 0.5
		if objectivesOffset < 0 then
			objectivesOffset = 0
		end
	end
	writeMenus()
	local pos = {x = 0, y = 0, z = 0}
	for _, obj in ipairs(set_objs.objectives) do
		pos = obj.getPosition()
		obj.setPosition({x = pos.x, y = 1.0 + objectivesOffset, z = pos.z})
	end
end
makeUpDown(objectivesOffsetUpDown, "objectivesOffsetUp", "objectivesOffsetDown")

function drawDiagonal(drawData, type)
	local rot = {x = 0, y = 45, z = 0}
    local sqrt2 = 1.414213562373 -- sqrt(2)
	local edgeLoss = drawData.fromCenter / 0.707106781187 -- sin(atan(1)) or cos(atan(1))
    local scale = lineScaleDefault
    scale.x = sqrt2 * (mat_size - math.abs(edgeLoss))
    local calc = edgeLoss / 2
    local pos = {x = calc, y = deployLineYPos, z = calc}
	if drawData.position == "-z" then
		pos.x = -pos.x
		pos.z = -pos.z
	end
	spawnLine(pos, rot, scale, type, drawData.color)
end

function drawLine(drawData, type)
	local pos = {
		x = drawData.fromCenter,
		y = deployLineYPos,
		z = 0
	}
	local rot = {x = 0, y = 90, z = 0}
	if drawData.position == "-x" then
		pos.x = -pos.x
	elseif drawData.position == "z" then
		rot.y = 0
		pos.z = pos.x
		pos.x = 0
	elseif drawData.position == "-z" then
		rot.y = 0
		pos.z = -pos.x
		pos.x = 0
	end
	spawnLine(pos, rot, lineScaleDefault, type, drawData.color)
end

function drawCircle(drawData, type)
    local pos = {x = drawData.centerX or 0, y = deployLineYPos, z = drawData.centerZ or 0}
    local scale = {x = drawData.fromCenter, y = lineScaleDefault.y, z = drawData.fromCenter}
    local rot = drawData.rot
    local callback = function(obj)
        obj.setLock(true)
        obj.setColorTint(drawData.color or "White")
        obj.interactable = false
        obj.setName("")
        obj.getComponent("MeshCollider").set("enabled", false)
    end
    local circ = drawData.circ or centerCircle_GUID
    set_objs[type][#set_objs[type] + 1] = Utils.cloneObjectNoSound(getObjectFromGUID(circ).getData(), pos, rot, scale, callback)
end

function spawnLine(pos, rot, scale, type, color)
	set_objs[type][#set_objs[type] + 1] = spawnObject({
		type = "BlockSquare",
		position = pos,
		rotation = rot,
		scale = scale,
        sound = false,
        callback_function = function(spawned_obj)
            spawned_obj.setLock(true)
            spawned_obj.setColorTint(color or "White")
            spawned_obj.setName("")
            spawned_obj.getComponent("BoxCollider").set("enabled", false)
        end
	})
end

local draw_types = {
	["line"] = drawLine,
	["diagonal"] = drawDiagonal,
	["circle"] = drawCircle
}
function drawDeployZone(zone)
	destroyDeployZones()
	deployIngameBtn.label = showText .. deployIngameLbl
    if #zone.draw == 0 then
        return
    end
	for _, drawData in ipairs(zone.draw) do
		if draw_types[drawData.type] ~= nil then
            drawData.circ = drawData.subtype
			draw_types[drawData.type](drawData, "deployments")
			deployIngameBtn.label = hideText .. deployIngameLbl
		end
	end
end

function deployUpDown(upDown)
	if upDown then
		deploySelected = deploySelected + 1
		if deploySelected > #DeployZonesData then
			deploySelected = 1
		end
	else
		deploySelected = deploySelected - 1
		if deploySelected < 1 then
			deploySelected = #DeployZonesData
		end
	end
	drawDeployZone(DeployZonesData[deploySelected])
	clearObjects("objectives")
	if DeployZonesData[deploySelected] ~= nil then
		local template = getObjectFromGUID("573333")
		if template == nil then
			broadcastToAll("Error: Objective template object not found", {1, 0, 0})
			return
		end
		template = template.getData()
        local callback = function(spawned) spawned.setLock(true) end
        local pos = {}
        local y = 1.0 + objectivesOffset
		for i, obj in ipairs(objectivesData[DeployZonesData[deploySelected].objectivesID]) do
			pos = {x = obj[1], y = y, z = obj[2]}
            set_objs.objectives[i] = Utils.cloneObjectNoSound(template, pos, {x = 0, y = 270, z = 180}, nil, callback)
		end
	end
	writeMenus()
end
makeUpDown(deployUpDown, "deployUp", "deployDown")

function deployOffsetUpDown(upDown)
	local amt = 1
	if not upDown then
		amt = -1
	end
	deployOffset = deployOffset + amt
	if deployOffset > 25 then
		deployOffset = 25
	end
	if deployOffset < 0 then
		deployOffset = 0
	end
    lineScaleDefault.y = deployLineHeight + deployOffset
    drawDeployZone(DeployZonesData[deploySelected])
	writeMenus()
end
makeUpDown(deployOffsetUpDown, "deployOffsetUp", "deployOffsetDown")

function showHideIngameDeployment()
	if #set_objs.deployments == 0 then
		if DeployZonesData[deploySelected] ~= nil then
			drawDeployZone(DeployZonesData[deploySelected])
		else
			broadcastToAll("Error: No deployment data found for selected scenario", {1, 0, 0})
		end
	else
		destroyDeployZones()
	end
	writeMenus()
end
function destroyDeployZones()
	deployIngameBtn.label = showText .. deployIngameLbl
	clearObjects("deployments")
end

function showHideCenters()
    showHideObjects("centers", centersBtn, function()
        drawCircle({fromCenter = 6}, "centers")
        drawCircle({fromCenter = 3}, "centers")
    end)
end

function showHideQuarters()
    showHideObjects("quarters", quartersBtn, function()
        spawnLine({x = 0, y = deployLineYPos, z = 0}, {x = 0, y = 0, z = 0}, lineScaleDefault, "quarters")
        spawnLine({x = 0, y = deployLineYPos, z = 0}, {x = 0, y = 90, z = 0}, lineScaleDefault, "quarters")
    end)
end

function showHideMaelstrom()
    showHideObjects("maelstrom", maelstromBtn, function()
        spawnLine({x = 0, y = deployLineYPos, z = half_mat - 6}, {x = 0, y = 0,  z = 0}, lineScaleDefault, "maelstrom")
        spawnLine({x = 0, y = deployLineYPos, z = -(half_mat - 6)},{x = 0, y = 0,  z = 0}, lineScaleDefault, "maelstrom")
        spawnLine({x = half_mat - 6,  y = deployLineYPos, z = 0}, {x = 0, y = 90, z = 0}, lineScaleDefault, "maelstrom")
        spawnLine({x = -(half_mat - 6), y = deployLineYPos, z = 0},{x = 0, y = 90, z = 0}, lineScaleDefault, "maelstrom")
    end)
end

function showHideCorners()
    showHideObjects("corners", cornersBtn, function()
        local drawData = {fromCenter = 12, circ = quarterCircle_GUID}
        drawData.rot = {x = 0, y = 270, z = 0}
        drawData.centerX = half_mat
        drawData.centerZ = half_mat
        drawCircle(drawData, "corners")
        drawData.rot.y = 0
        drawData.centerZ = -half_mat
        drawCircle(drawData, "corners")
        drawData.rot.y = 90
        drawData.centerX = -half_mat
        drawCircle(drawData, "corners")
        drawData.rot.y = 180
        drawData.centerZ = half_mat
        drawCircle(drawData, "corners")
    end)
end

function none() end
