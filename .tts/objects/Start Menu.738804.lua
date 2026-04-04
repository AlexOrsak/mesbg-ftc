local Utils = require("utils")
local centerCircle_GUID = "51ee2f"
local quarterCircle_GUID = "51ee3f"
local templateObjective_GUID = "573333"
local mat_GUID = "4ee1f2"
local inGame = false
local hideText = "Hide"
local showText = "Show"
local mat_size = 48

function onLoad(saved_data)
	self.setRotation({x = 0, y = 270, z = 0})
	if saved_data ~= "" then
		local loaded_data = JSON.decode(saved_data)
        if loaded_data.svInGame ~= nil then
            inGame = loaded_data.svInGame
        end
		if loaded_data.svDeploySelected ~= nil then
		    deploySelected = loaded_data.svDeploySelected
        end
        if loaded_data.svNotes ~= nil then
		    Notes.setNotes(loaded_data.svNotes)
        end
	end
	writeMenus()
	if not inGame then
		printToAll("Welcome to MESBG FTC", "Yellow")
	end
end

function onSave()
	saved_data = JSON.encode({
		svInGame = inGame,
		svDeploySelected = deploySelected,
		svNotes = getNotes()
	})
	return saved_data
end

function writeMenus()
	self.clearButtons()
	if inGame == false then
		self.createButton(lockInBtn)
		if DeployZonesData[deploySelected] ~= nil then
			if deploySelected == #DeployZonesData then
				scenarioBtn.label = "-"
			else
				scenarioBtn.label = "Scenario " .. deploySelected .. " - " .. DeployZonesData[deploySelected].name
			end
		end
		self.createButton(scenarioBtn)
		self.createButton(deployUpBtn)
		self.createButton(deployDownBtn)
		self.createButton(deployMenuBtn)
		self.createButton(objectivesOffsetDownBtn)
		self.createButton(objectivesOffsetUpBtn)
		self.createButton(objectivesOffsetMenuBtn)
    else
        self.createButton(deployIngameBtn)
	end
	if #deployments > 0 then
		deployIngameBtn.label = hideText .. deployIngameLbl
	end
	if #centers > 0 then
		centersBtn.label = hideText .. centersLbl
	end
	self.createButton(centersBtn)
	self.createButton(quartersBtn)
	self.createButton(maelstromBtn)
	self.createButton(cornersBtn)
	self.createButton(deployOffsetMenuBtn)
	self.createButton(deployOffsetUpBtn)
	self.createButton(deployOffsetDownBtn)
end

lockInBtn = {
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
function startGame()
	Global.call("recordPlayers")
	inGame = true
	destroyDeployZones()
	destroyCenters()
	destroyQuarters()
	destroyMaelstrom()
	destroyCorners()
	writeMenus()
end

objectives = {}
objectivesOffset = 0
objectivesData = { -- (x, z) coordinates of objectives, relative to center of the board)
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
objectivesOffsetMenuBtn = {
	label = "Obj.\nHeight",
	click_function = "none",
	function_owner = self,
	position = {-8, 5, 0},
	rotation = {0, 0, 0},
	height = 450,
	width = 1000,
	font_size = 150,
	color = {0, 0, 0},
	font_color = {1, 1, 1}
}
objectivesOffsetUpBtn = {
	label = "+",
	click_function = "objectivesOffsetUp",
	function_owner = self,
	position = {-8, 5, -1.2},
	rotation = {0, 0, 0},
	height = 450,
	width = 800,
	font_size = 300,
	color = {0, 0, 0},
	font_color = {1, 1, 1}
}
objectivesOffsetDownBtn = {
	label = "-",
	click_function = "objectivesOffsetDown",
	function_owner = self,
	position = {-8, 5, 1.2},
	rotation = {0, 0, 0},
	height = 450,
	width = 800,
	font_size = 300,
	color = {0, 0, 0},
	font_color = {1, 1, 1}
}

function spawnObjectives()
	destroyAllObjectives()
	if DeployZonesData[deploySelected] ~= nil then
		objectiveSet = objectivesData[DeployZonesData[deploySelected].objectivesID]
		local pos = {}
		local y = 1.0 + objectivesOffset
		local template_data = getObjectFromGUID(templateObjective_GUID).getData()
        local callback = function(spawned)
            spawned.setLock(true)
            objectives[#objectives + 1] = spawned --TODO fix so that spamming thru missions deletes the objectives correctly
        end
		for _, obj in ipairs(objectiveSet) do
			pos = {x = obj[1], y = y, z = obj[2]}
			Utils.cloneObjectNoSound(template_data, pos, {x = 0, y = 270, z = 180}, nil, callback)
		end
	end
end

function destroyAllObjectives()
	for _, obj in ipairs(objectives) do
		obj.destroy()
	end
	objectives = {}
end

function objectivesOffsetUp()
	objectivesOffsetUpDown(true)
end
function objectivesOffsetDown()
	objectivesOffsetUpDown(false)
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
	for _, obj in ipairs(objectives) do
		pos = obj.getPosition()
		obj.setPosition({x = pos.x, y = 1.0 + objectivesOffset, z = pos.z})
	end
end

deployLineHeight = 2.1
deployLineYPos = 2.0
deployOffset = 0
deployments = {}
DeployZonesData = {
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
deploySelected = #DeployZonesData


function drawDiagonal(drawData, type)
	local linePos = {
		x = 0,
		y = deployLineYPos,
		z = 0
	}
	local lineRot = {
		x = 0,
		y = 45,
		z = 0
	}
	local lineScale = {
		x = 5,
		y = deployLineHeight + deployOffset,
		z = 0.02
	}
    local sqrt2 = 1.414213562373 -- sqrt(2)
	local edgeLoss = drawData.fromCenter / 0.707106781187 -- sin(atan(1)) or cos(atan(1))
	lineScale.x = sqrt2 * (mat_size - math.abs(edgeLoss))
    local calc = edgeLoss / 2
	linePos.x = calc
	linePos.z = calc
	if drawData.position == "-z" then
		linePos.x = -linePos.x
		linePos.z = -linePos.z
	end
	spawnLine(linePos, lineRot, lineScale, drawData.color, type)
end

function drawLine(drawData, type)
	local linePos = {
		x = drawData.fromCenter,
		y = deployLineYPos,
		z = 0
	}
	local lineRot = {
		x = 0,
		y = 90,
		z = 0
	}
	local lineScale = {
		x = mat_size,
		y = deployLineHeight + deployOffset,
		z = 0.02
	}
	if drawData.position == "-x" then
		linePos.x = -linePos.x
	elseif drawData.position == "z" then
		lineRot.y = 0
		linePos.z = linePos.x
		linePos.x = 0
	elseif drawData.position == "-z" then
		lineRot.y = 0
		linePos.z = -linePos.x
		linePos.x = 0
	end
	spawnLine(linePos, lineRot, lineScale, drawData.color, type)
end

function drawCircle(drawData, type)
    local centerX = drawData.centerX ~= nil and drawData.centerX or 0
    local centerZ = drawData.centerZ ~= nil and drawData.centerZ or 0
    local pos = {x = centerX, y = deployLineYPos, z = centerZ}
    local scale = {x = drawData.fromCenter, y = deployLineHeight + deployOffset, z = drawData.fromCenter}
    local rot = nil
    if drawData.rot ~= nil then
        rot = drawData.rot
    end
    local callback = function(spawned_obj)
        spawned_obj.setLock(true)
        spawned_obj.setColorTint(drawData.color)
        spawned_obj.interactable = false
        spawned_obj.setName("")
        spawned_obj.getComponent("MeshCollider").set("enabled", false)
        insertIntoTable(type, spawned_obj)
    end
    Utils.cloneObjectNoSound(drawData.circ.getData(), pos, rot, scale, callback)
end

function spawnLine(linePos, lineRot, lineScale, color, type)
	local lineObj = spawnObject({
		type = "BlockSquare",
		position = linePos,
		rotation = lineRot,
		scale = lineScale,
        sound = false,
        callback_function = function(spawned_obj)
            spawned_obj.setLock(true)
            spawned_obj.setColorTint(color)
            spawned_obj.setName("")
            spawned_obj.getComponent("BoxCollider").set("enabled", false)
            insertIntoTable(type, spawned_obj)
        end
	})
end

draw_types = {
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
            if drawData.subtype ~= nil then
                drawData.circ = getObjectFromGUID(drawData.subtype)
            end
			draw_types[drawData.type](drawData, "deployZone")
			deployIngameBtn.label = hideText .. deployIngameLbl
		end
	end
end

function insertIntoTable(type, obj)
	if (type == "deployZone") then
		deployments[#deployments + 1] = obj
	elseif (type == "maelstrom") then
		maelstromLines[#maelstromLines + 1] = obj
	elseif (type == "center") then
		centers[#centers + 1] = obj
	elseif (type == "quarter") then
		quarters[#quarters + 1] = obj
	elseif (type == "corners") then
		corners[#corners + 1] = obj
	end
end

deployMenuBtn = {
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
scenarioBtn = {
	click_function = "none",
	function_owner = self,
	position = {-18, 5, 1},
	rotation = {0, 0, 0},
	height = 750,
	width = 6000,
	font_size = 400
}
deployUpBtn = {
	label = "->",
	click_function = "deployUp",
	function_owner = self,
	position = {-10.5, 5, 1},
	rotation = {0, 0, 0},
	height = 750,
	width = 800,
	font_size = 300,
	color = {0, 0, 0},
	font_color = {1, 1, 1}
}
deployDownBtn = {
	label = "<-",
	click_function = "deployDown",
	function_owner = self,
	position = {-25.5, 5, 1},
	rotation = {0, 0, 0},
	height = 750,
	width = 800,
	font_size = 300,
	color = {0, 0, 0},
	font_color = {1, 1, 1}
}
deployOffsetMenuBtn = {
	label = "Deploy\nHeight",
	click_function = "none",
	function_owner = self,
	position = {-28.5, 5, 0},
	rotation = {0, 0, 0},
	height = 450,
	width = 1000,
	font_size = 150,
	color = {0, 0, 0},
	font_color = {1, 1, 1}
}
deployOffsetUpBtn = {
	label = "+",
	click_function = "deployOffsetUp",
	function_owner = self,
	position = {-28.5, 5, -1.2},
	rotation = {0, 0, 0},
	height = 450,
	width = 800,
	font_size = 300,
	color = {0, 0, 0},
	font_color = {1, 1, 1}
}
deployOffsetDownBtn = {
	label = "-",
	click_function = "deployOffsetDown",
	function_owner = self,
	position = {-28.5, 5, 1.2},
	rotation = {0, 0, 0},
	height = 450,
	width = 800,
	font_size = 300,
	color = {0, 0, 0},
	font_color = {1, 1, 1}
}

function deployUp()
	deployUpDown(true)
end
function deployDown()
	deployUpDown(false)
end

function deployUpDown(upDown)
	destroyAllObjectives()
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
	spawnObjectives()
	writeMenus()
end

function deployOffsetUp()
	deployOffsetUpDown(true)
end

function deployOffsetDown()
	deployOffsetUpDown(false)
end

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
    destroyDeployZones()
    drawDeployZone(DeployZonesData[deploySelected])
	writeMenus()
end

deployIngameLbl = "\nDeployment\nZones"
deployIngameBtn = {
	label = showText .. "/" .. hideText .. deployIngameLbl,
	click_function = "showHideIngameDeployment",
	function_owner = self,
	position = {0, 5, 0},
	rotation = {0, 0, 0},
	height = 1500,
	width = 2600,
	font_size = 300
}
function showHideIngameDeployment()
	if #deployments == 0 then
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
	for _, obj in ipairs(deployments) do
		obj.destroy()
	end
	deployments = {}
end

centers = {}
centersLbl = "\nCenter"
centersBtn = {
	label = showText .. centersLbl,
	click_function = "showCenters",
	function_owner = self,
	position = {15, 5, 0},
	rotation = {0, 0, 0},
	height = 1500,
	width = 2600,
	font_size = 300
}
function showCenters()
	if #centers == 0 then
		centersBtn.label = hideText .. centersLbl
        local circ = getObjectFromGUID(centerCircle_GUID)
		drawCircle({
			color = "White",
			fromCenter = 6,
            circ = circ
		}, "center")
		drawCircle({
			color = "White",
			fromCenter = 3,
            circ = circ
		}, "center")
	else
		destroyCenters()
	end
	writeMenus()
end
function destroyCenters()
	centersBtn.label = showText .. centersLbl
	for i, obj in ipairs(centers) do
		obj.destroy()
	end
	centers = {}
end

quarters = {}
quartersLbl = "\nTable Quarters"
quartersBtn = {
	label = showText .. quartersLbl,
	click_function = "showHideQuarters",
	function_owner = self,
	position = {9, 5, 0},
	rotation = {0, 0, 0},
	height = 1500,
	width = 2600,
	font_size = 300
}
function showHideQuarters()
	if #quarters == 0 then
		quartersBtn.label = hideText .. quartersLbl
		local lineScale = {
			x = mat_size,
			y = deployLineHeight + deployOffset,
			z = 0.02
		}
        local linePos = {
            x = 0,
            y = deployLineYPos,
            z = 0
        }
		spawnLine(linePos, {x = 0, y = 0, z = 0}, lineScale, "White", "quarter")
		spawnLine(linePos, {x = 0, y = 90, z = 0}, lineScale, "White", "quarter")
	else
		destroyQuarters()
	end
	writeMenus()
end
function destroyQuarters()
	quartersBtn.label = showText .. quartersLbl
	for _, obj in ipairs(quarters) do
		obj.destroy()
	end
	quarters = {}
end

maelstromLines = {}
maelstromLbl = "\nMaelstrom"
maelstromBtn = {
	label = showText .. maelstromLbl,
	click_function = "showHideMaelstrom",
	function_owner = self,
	position = {27, 5, 0},
	rotation = {0, 0, 0},
	height = 1500,
	width = 2600,
	font_size = 300
}
function showHideMaelstrom()
	if #maelstromLines == 0 then
		maelstromBtn.label = hideText .. maelstromLbl
		local lineScale = {
			x = mat_size,
			y = deployLineHeight + deployOffset,
			z = 0.02
		}
		local half_mat = mat_size * 0.5
		spawnLine({x = 0, y = deployLineYPos, z = half_mat - 6}, {x = 0, y = 0, z = 0}, lineScale, "White", "maelstrom")
		spawnLine({x = 0, y = deployLineYPos, z = -(half_mat - 6)}, {x = 0, y = 0, z = 0}, lineScale, "White", "maelstrom")
		spawnLine({x = half_mat - 6, y = deployLineYPos, z = 0}, {x = 0, y = 90, z = 0}, lineScale, "White", "maelstrom")
		spawnLine({x = -(half_mat - 6), y = deployLineYPos, z = 0}, {x = 0, y = 90, z = 0}, lineScale, "White", "maelstrom")
	else
		destroyMaelstrom()
	end
	writeMenus()
end
function destroyMaelstrom()
	maelstromBtn.label = showText .. maelstromLbl
	for _, obj in ipairs(maelstromLines) do
		obj.destroy()
	end
	maelstromLines = {}
end

corners = {}
cornersLbl = "\nCorners"
cornersBtn = {
	label = showText .. cornersLbl,
	click_function = "showHideCorners",
	function_owner = self,
	position = {21, 5, 0},
	rotation = {0, 0, 0},
	height = 1500,
	width = 2600,
	font_size = 300
}
function showHideCorners()
	if #corners == 0 then
		cornersBtn.label = hideText .. cornersLbl
		local half_mat = mat_size * 0.5
		local drawData = {
			color = "White",
			fromCenter = 12,
            circ = getObjectFromGUID(quarterCircle_GUID)
		}
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
	else
		destroyCorners()
	end
	writeMenus()
end
function destroyCorners()
	cornersBtn.label = showText .. cornersLbl
	for _, obj in ipairs(corners) do
		obj.destroy()
	end
	corners = {}
end

function none()
end
