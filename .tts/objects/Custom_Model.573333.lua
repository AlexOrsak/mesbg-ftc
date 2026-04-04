radiuses = {0, 1.5, 2.5, 3.5, 6.5, 8.5, 12.5, 18.5, 24.5, 30.5}
circle = {
	color             = {0, 0.8, 0.4},
	radius            = 1.5,
	show              = false,
	steps             = 64,
	thickness         = 0.05,
	vertical_position = 0.1,
}

function onScriptingButtonDown(index, playerColor)
	if Player[playerColor].getHoverObject() == self then
		circle.radius = radiuses[index]
		print(math.floor(radiuses[index]) .. '" radius')
		toggleCircle()
	end
end

function toggleCircle()
	circle.show = not circle.show
	if circle.show then
		self.setVectorLines({
			{
				points    = getCircleVectorPoints(circle.radius, circle.steps, circle.vertical_position),
				color     = circle.color,
				thickness = circle.thickness,
				rotation  = {0,0,0},
			}
		})
	else
		self.setVectorLines({})
	end
end

function getCircleVectorPoints(radius, steps, y)
	local t = {}
	local d = 360 / steps
	for i = 0, steps do
		rdi = math.rad(d*i)
		t[#t + 1] = { math.cos(rdi)*radius, y, math.sin(rdi)*radius }
	end
	return t
end