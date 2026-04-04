local MODEL_BAG_GUID = '24f6d0'
local NOTE_NAME = "ArmyList"

function onLoad()
	self.createButton({
		label = "Spawn Army",
		click_function = "spawnFromNotebook",
		function_owner = self,
		position = {0, 5, 0},
		rotation = {0, 180, 0},
		width = 1800,
		height = 400,
		font_size = 250
	})
end

function spawnFromNotebook(obj, playerColor)
	local pages = getNotebookTabs()
	for _, page in ipairs(pages) do
		if page.title == NOTE_NAME then
			processList(page.body, playerColor)
			return
		end
	end
	broadcastToColor("Notebook page '" .. NOTE_NAME .. "' not found.", playerColor, {1, 0, 0})
end

function processList(text, color)
	local bag = getObjectFromGUID(MODEL_BAG_GUID)
	if not bag then
		broadcastToColor("Error: Model bag not found!", color, {1, 0, 0})
		return
	end

	local warbands = {}
	local heroCount = {}
	local currentHeroKey = nil
	local totalModels = 0
	local lines = {}

	-- Collect all parentheses-wrapped lines and trim spaces
	for line in string.gmatch(text, "[^\r\n]+") do
		local firstChar = 0
		local secondChar = 0
		for i = 1, #line do
			local c = line:sub(i, i)
			if (c == "(") then
				firstChar = i
			elseif (c == ")") then
				secondChar = i
			end
		end
		line = line:sub(firstChar + 1, secondChar - 1)
		while true do
			local c = line:sub(1, 1)
			if (c ~= " " and c ~= "\n" and c ~= "\r") then
				break
			end
			line = line:sub(2)
		end
		while true do
			local c = line:sub(-1)
			if c ~= " " and c ~= "\n" and c ~= "\r" then
				break
			end
			line = line:sub(1, #line - 1)
		end
		if line ~= nil and line ~= '' then
			table.insert(lines, line)
		end
	end

	-- Parse warbands
	for _, line in ipairs(lines) do
		if line:find("^%d+x") then
			local count, model = line:match("^(%d+)x%s+(.+)")
			if count and model and currentHeroKey then
				model = model:gsub("%s*%([^%)]+%)", ""):match("^%s*(.-)%s*$")
				table.insert(warbands[currentHeroKey].units, {
					count = tonumber(count),
					name = model
				})
			end
		else
			local heroName = line:gsub("%s*%([^%)]+%)", "")
			if not heroCount[heroName] then
				heroCount[heroName] = 1
				currentHeroKey = heroName
			else
				heroCount[heroName] = heroCount[heroName] + 1
				currentHeroKey = heroName .. " (" .. heroCount[heroName] .. ")"
			end
			warbands[currentHeroKey] = {
				heroName = heroName,
				units = {}
			}
		end
	end

	-- Positioning
	local basePos = {
		x = self.getPosition().x,
		y = self.getPosition().y + 2,
		z = self.getPosition().z + 4
	}
	local warbandSpacing = 8
	local warbandsPerRow = 6
	local rowSpacing = 10
	local spawnQueue = {}
	local warbandIndex = 0

	for heroKey, data in pairs(warbands) do
		local row = math.floor(warbandIndex / warbandsPerRow)
		local col = warbandIndex % warbandsPerRow

		local heroPos = {
			x = basePos.x + row * rowSpacing,
			y = basePos.y,
			z = basePos.z + col * warbandSpacing
		}

		table.insert(spawnQueue, {
			name = data.heroName,
			count = 1,
			pos = heroPos
		})
		totalModels = totalModels + 1

		local modelIndex = 0
		for _, entry in ipairs(data.units) do
			for i = 1, entry.count do
				local gridX = (modelIndex % 6) * 1.1
				local gridZ = math.floor(modelIndex / 6) * 1.1 + 1.5
				local modelPos = {
					x = heroPos.x + gridX,
					y = heroPos.y,
					z = heroPos.z + gridZ
				}
				table.insert(spawnQueue, {
					name = entry.name,
					count = 1,
					pos = modelPos
				})
				totalModels = totalModels + 1
				modelIndex = modelIndex + 1
			end
		end

		warbandIndex = warbandIndex + 1
	end

	spawnNextFromQueue(bag, spawnQueue, color)

	local breakPoint = math.floor(totalModels / 2) + 1
	local quarterRemaining = math.floor(totalModels / 4)
	broadcastToColor(totalModels .. " Models | " .. breakPoint .. " Break | " .. quarterRemaining ..
					                 " Remaining", color, {0.2, 1, 0.2})
end

function spawnNextFromQueue(bag, queue, color)
	if #queue == 0 then
		return
	end

	local task = table.remove(queue, 1)
	local contents = bag.getObjects()
	for _, entry in ipairs(contents) do
		local entry_name = string.lower(entry.name)
		local task_name = string.lower(task.name)
		if entry_name == task_name then
			bag.takeObject({
				index = entry.index,
				position = task.pos,
				smooth = false,
				callback_function = function(original)
					original.setName(task.name)
					Wait.time(function()
						local clone = original.clone({
							position = task.pos
						})
						clone.setName(task.name)
						Wait.time(function()
							if bag then
								bag.putObject(original)
							else
								original.destruct()
							end
							spawnNextFromQueue(bag, queue, color)
						end, 0.05)
					end, 0.05)
				end
			})
			return
		end
	end

	broadcastToColor("Could not find: " .. task.name, color, {1, 0.5, 0})
	spawnNextFromQueue(bag, queue, color)
end
