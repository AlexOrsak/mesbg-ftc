local radiuses = {0, 1.5, 2.5, 3.5, 6.5, 8.5, 12.5, 18.5, 24.5, 30.5}
local showCircle = false

function onScriptingButtonDown(index, playerColor)
	if Player[playerColor].getHoverObject() == self then
		print(math.floor(radiuses[index]) .. '" radius')
		toggleCircle(radiuses[index])
	end
end

function toggleCircle(radius)
	showCircle = not showCircle
	if showCircle then
		self.setVectorLines({
			{
				points    = getCircleVectorPoints(radius),
				color     = {0, 0.8, 0.4},
				thickness = 0.05,
				rotation  = {0,0,0},
			}
		})
	else
		self.setVectorLines({})
	end
end

function getCircleVectorPoints(radius)
	local t = {}
	local step = 0.0981747704247
	local cos, sin = math.cos, math.sin
	local rdi = 0
	for i = 0, 64 do
		t[i + 1] = { cos(rdi)*radius, 0.1, sin(rdi)*radius }
		rdi = rdi + step
	end
	return t
end