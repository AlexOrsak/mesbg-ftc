centerCircle_GUID = "51ee2f"
quarterCircle_GUID = "51ee3f"
templateObjective_GUID = "573333"
mat_GUID = "4ee1f2"
inGame = false
hideText = "Hide"
showText = "Show"

function onLoad(saved_data)
	self.setRotation({0, 270, 0})
	if saved_data ~= "" then
		local loaded_data = JSON.decode(saved_data)
		inGame = loaded_data.svInGame
		deploySelected = loaded_data.svDeploySelected
		Notes.setNotes(loaded_data.svNotes)
	end

	mat = getObjectFromGUID(mat_GUID)
	mat_size = mat.getScale() * 36

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
				scenarioBtn.label = ""
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
	end
	if #deployments > 0 then
		deployIngameBtn.label = hideText .. "\nDeployment\nZones"
	end
	if #centers > 0 then
		centersBtn.label = hideText .. centersLbl
	end
	self.createButton(centersBtn)
	self.createButton(quartersBtn)
	self.createButton(maelstromBtn)
	self.createButton(campSitesBtn)
	self.createButton(deployIngameBtn)
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
	destroyCampSites()
	writeMenus()
end

objectives = {}
objectivesOffset = 0
objectivesData = {
	[1] = {},
	[2] = {{
		pos = {0, 0}
	}},
	[3] = {{
		pos = {0, 0}
	}, {
		pos = {12, 0}
	}, {
		pos = {0, -12}
	}, {
		pos = {0, 12}
	}, {
		pos = {-12, 0}
	}},
	[4] = {{
		pos = {-12, 0}
	}, {
		pos = {12, 0}
	}, {
		pos = {0, 0}
	}},
	[5] = {{
		pos = {0, -12}
	}, {
		pos = {0, 12}
	}, {
		pos = {12, 0}
	}, {
		pos = {-12, 0}
	}},
	[6] = {{
		pos = {12, -12}
	}, {
		pos = {0, -12}
	}, {
		pos = {-12, -12}
	}, {
		pos = {12, 12}
	}, {
		pos = {0, 12}
	}, {
		pos = {-12, 12}
	}},
	[7] = {{
		pos = {12, -12}
	}, {
		pos = {-12, -12}
	}, {
		pos = {12, 12}
	}, {
		pos = {-12, 12}
	}},
	[8] = {{
		pos = {12, -6}
	}, {
		pos = {0, -6}
	}, {
		pos = {-12, -6}
	}, {
		pos = {12, 6}
	}, {
		pos = {0, 6}
	}, {
		pos = {-12, 6}
	}},
	[9] = {{
		pos = {-9.84, -9.84}
	}, {
		pos = {9.84, 9.84}
	}}
}
objectivesOffsetMenuBtn = {
	label = "Obj.\nHeight",
	click_function = "none",
	function_owner = self,
	position = {-10.5, 5, 0},
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
	position = {-10.5, 5, -1.2},
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
	position = {-10.5, 5, 1.2},
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
		local template = getObjectFromGUID(Global.getVar("templateObjective_GUID"))
		for _, obj in ipairs(objectiveSet) do
			pos = {obj.pos[1], y, obj.pos[2]}
			spawned = template.clone()
			spawned.setPosition(pos)
			spawned.setRotation({0, 270, 180})
			spawned.setLock(true)
			objectives[#objectives + 1] = spawned
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
		objectivesOffset = objectivesOffset + 0.2
		if objectivesOffset > 25 then
			objectivesOffset = 25
		end
	else
		objectivesOffset = objectivesOffset - 0.2
		if objectivesOffset < 0 then
			objectivesOffset = 0
		end
	end
	writeMenus()
	local pos = {0, 0, 0}
	for _, obj in ipairs(objectives) do
		pos = obj.getPosition()
		obj.setPosition({pos[1], 1.0 + objectivesOffset, pos[3]})
	end
end

deployLineHeight = 2.1
deployLineYPos = 2.0
deployOffset = 0
deployments = {}
DeployZonesData = {{
	name = "Domination",
	objectivesID = 2,
	draw = {{
		type = "line",
		color = "Red",
		position = "z",
		fromCenter = 0
	}, {
		type = "line",
		color = "Teal",
		position = "-z",
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
	draw = {{
		type = "line",
		color = "Red",
		position = "z",
		fromCenter = 250
	}, {
		type = "line",
		color = "Teal",
		position = "-z",
		fromCenter = 250
	}}
}, {
	name = "Lords of Battle",
	objectivesID = 1,
	draw = {{
		type = "line",
		color = "Red",
		position = "z",
		fromCenter = 0
	}, {
		type = "line",
		color = "Teal",
		position = "-z",
		fromCenter = 0
	}}
}, {
	name = "Reconnoitre",
	objectivesID = 1,
	draw = {{
		type = "line",
		color = "Red",
		position = "z",
		fromCenter = 250
	}, {
		type = "line",
		color = "Teal",
		position = "-z",
		fromCenter = 250
	}}
}, {
	name = "A Clash By MoonLight",
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
		color = "Red",
		position = "z",
		fromCenter = 0
	}, {
		type = "line",
		color = "Teal",
		position = "-z",
		fromCenter = 0
	}}
}, {
	name = "Capture and Control",
	objectivesID = 3,
	draw = { -- TODO fix deploy zones
	{
		type = "line",
		color = "Red",
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
	}, {
		type = "line",
		color = "Teal",
		position = "-z",
		fromCenter = 0
	}}
}, {
	name = "Heirloom of Ages Past ",
	objectivesID = 1,
	draw = {{
		type = "line",
		color = "Red",
		position = "z",
		fromCenter = 250
	}, {
		type = "line",
		color = "Teal",
		position = "-z",
		fromCenter = 250
	}}
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
		type = "line",
		color = "Red",
		position = "z",
		fromCenter = 250
	}, {
		type = "line",
		color = "Teal",
		position = "-z",
		fromCenter = 250
	}}
}, {
	name = "Command the Battlefield",
	objectivesID = 2,
	draw = {{
		type = "line",
		color = "Red",
		position = "z",
		fromCenter = 250
	}, {
		type = "line",
		color = "Teal",
		position = "-z",
		fromCenter = 250
	}}
}, {
	name = "Retrieval",
	objectivesID = 9,
	draw = {{
		type = "diagonal",
		color = "Red",
		position = "x",
		fromCenter = -3
	}, {
		type = "diagonal",
		color = "Teal",
		position = "x",
		fromCenter = 3
	}}
}, {
	name = "Breakthrough",
	objectivesID = 5,
	draw = {{
		type = "line",
		color = "Red",
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
		type = "line",
		color = "Red",
		position = "z",
		fromCenter = 250
	}, {
		type = "line",
		color = "Teal",
		position = "-z",
		fromCenter = 250
	}}
}, {
	name = "Assassination",
	objectivesID = 1,
	draw = {{
		type = "line",
		color = "Red",
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
	draw = {{
		type = "line",
		color = "Red",
		position = "z",
		fromCenter = 250
	}, {
		type = "line",
		color = "Teal",
		position = "-z",
		fromCenter = 250
	}}
}, {
	name = "Treasure Horde",
	objectivesID = 8,
	draw = {{
		type = "line",
		color = "Red",
		position = "z",
		fromCenter = 250
	}, {
		type = "line",
		color = "Teal",
		position = "-z",
		fromCenter = 250
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
		type = "line",
		color = "Red",
		position = "z",
		fromCenter = 250
	}, {
		type = "line",
		color = "Teal",
		position = "-z",
		fromCenter = 250
	}}
}, {
	name = "None",
	objectivesID = 1,
	draw = {}
}}
deploySelected = #DeployZonesData
draw_types = {
	["line"] = drawLine,
	["diagonal"] = drawDiagonal,
	["circle"] = drawCircle
}

function drawDiagonal(drawData, nop1, nop2, type)
	local linePos = {
		x = 0,
		y = deployLineYPos,
		z = 0
	}
	local lineRot = {
		x = 0,
		y = 0,
		z = 0
	}
	local lineScale = {
		x = 5,
		y = deployLineHeight + deployOffset,
		z = 0.02
	}

	local mainDiagonal = math.sqrt(math.pow(mat_size, 2) + math.pow(mat_size, 2))
	local edgeAngleRad = math.atan(mat_size / mat_size)
	local edgeAngle = math.deg(edgeAngleRad)
	local edgeLoss = drawData.fromCenter / math.cos(edgeAngleRad)
	local triBase = mat_size - edgeLoss
	local ratio = triBase / mat_size
	lineScale.x = mainDiagonal * ratio
	lineRot.y = edgeAngle
	linePos.x = (mat_size / 2) - (lineScale.x / 2) * math.cos(edgeAngleRad)
	linePos.z = (mat_size / 2) - (lineScale.x / 2) * math.sin(edgeAngleRad)
	if drawData.position == "-z" then
		linePos.x = -linePos.x
		linePos.z = -linePos.z
	end
	spawnLine(linePos, lineRot, lineScale, drawData.color, type)
end

function drawLine(drawData, nop1, nop2, type)
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

function drawCircle(drawData, centerX, centerZ, type)
	local ogCirc = getObjectFromGUID(Global.getVar("centerCircle_GUID"))
	if type == "campSites" then
		ogCirc = getObjectFromGUID(Global.getVar("quarterCircle_GUID"))
	end
	local circObj = ogCirc.clone()
	if circObj then
		circObj.setLock(true)
		circObj.setScale({drawData.fromCenter, deployLineHeight + deployOffset, drawData.fromCenter})
		circObj.setPosition({centerX, deployLineYPos, centerZ})
		circObj.setColorTint(drawData.color)
		circObj.setName("")
		circObj.getComponent("BoxCollider").set("enabled", false)
		insertIntoTable(type, circObj)
	end
end

function spawnLine(linePos, lineRot, lineScale, color, type)
	local lineObj = spawnObject({
		type = "BlockSquare",
		position = linePos,
		rotation = lineRot,
		scale = lineScale
	})
	if lineObj then
		lineObj.setLock(true)
		lineObj.setColorTint(color)
		lineObj.getComponent("BoxCollider").set("enabled", false)
		insertIntoTable(type, lineObj)
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
	elseif (type == "campSites") then
		campSites[#campSites + 1] = obj
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
	position = {-10.5, 5, 0},
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
	position = {-10.5, 5, -1.2},
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
	position = {-10.5, 5, 1.2},
	rotation = {0, 0, 0},
	height = 450,
	width = 800,
	font_size = 300,
	color = {0, 0, 0},
	font_color = {1, 1, 1}
}

function drawDeployZone(zone)
	destroyDeployZones()
	deployIngameBtn.label = showText .. deployIngameLbl
	for _, drawData in ipairs(zone.draw) do
		if draw_types[drawData.type] ~= nil then
			draw_types[drawData.type](drawData, 0, 0, "deployZone")
			deployIngameBtn.label = hideText .. deployIngameLbl
		end
	end
end

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
		drawCircle({
			color = "White",
			fromCenter = 6
		}, 0, 0, "center")
		drawCircle({
			color = "White",
			fromCenter = 3
		}, 0, 0, "center")
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
		spawnLine({0, deployLineYPos, 0}, {0, 0, 0}, lineScale, "White", "quarter")
		spawnLine({0, deployLineYPos, 0}, {0, 90, 0}, lineScale, "White", "quarter")
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
maelstromLbl = "\nMaelstrom Deployment"
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
		spawnLine({0, deployLineYPos, half_mat - 6}, {0, 0, 0}, lineScale, "Red", "maelstrom")
		spawnLine({0, deployLineYPos, -(half_mat - 6)}, {0, 0, 0}, lineScale, "Teal", "maelstrom")
		spawnLine({half_mat - 6, deployLineYPos, 0}, {0, 90, 0}, lineScale, "Red", "maelstrom")
		spawnLine({-(half_mat - 6), deployLineYPos, 0}, {0, 90, 0}, lineScale, "Teal", "maelstrom")
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

campSites = {}
campSitesLbl = "\nCamp Sites"
campSitesBtn = {
	label = showText .. campSitesLbl,
	click_function = "showHideCampSites",
	function_owner = self,
	position = {33, 5, 0},
	rotation = {0, 0, 0},
	height = 1500,
	width = 2600,
	font_size = 300
}
function showHideCampSites()
	if #campSites == 0 then
		campSitesBtn.label = hideText .. campSitesLbl
		local half_mat = mat_size * 0.5
		local drawData = {
			color = "White",
			fromCenter = 12
		}
		drawCircle(drawData, half_mat, half_mat, "campSites")
		drawCircle(drawData, half_mat, -half_mat, "campSites")
		drawCircle(drawData, -half_mat, half_mat, "campSites")
		drawCircle(drawData, -half_mat, -half_mat, "campSites")
	else
		destroyCampSites()
	end
	writeMenus()
end
function destroyCampSites()
	campSitesBtn.label = showText .. campSitesLbl
	for _, obj in ipairs(campSites) do
		obj.destroy()
	end
	campSites = {}
end

function none()
end
