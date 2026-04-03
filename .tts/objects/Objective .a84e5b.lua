function onLoad()
	circle = {
		color             = {0, 0.8, 0.4}, --RGB color of the circle
		radius            = 1,           --radius of the circle around the object
		show              = false,       --should the circle be shown by default?
		steps             = 64,          --number of segments that make up the circle
		thickness         = 0.05,         --thickness of the circle line
		vertical_position = 0.1,           --vertical height of the circle relative to the object
	}
end

function onScriptingButtonDown(index, playerColor)
if Player[playerColor].getHoverObject() == self then
if index == 1 then
circle.radius = 1.5
print('1" circle')
toggleCircle() end
if index == 2 then
circle.radius = 2.5
print('2" circle')
toggleCircle() end
if index == 3 then
circle.radius = 3.5
print('3" circle')
toggleCircle() end
if index == 4 then
circle.radius = 6.5
print('6" circle')
toggleCircle() end
if index == 5 then
circle.radius = 8.5
print('8" circle')
toggleCircle() end
if index == 6 then
circle.radius = 12.5
print('12" circle')
toggleCircle() end
if index == 7 then
circle.radius = 18.5
print('18" circle')
toggleCircle() end
if index == 8 then
circle.radius = 24.5
print('24" circle')
toggleCircle() end
if index == 9 then
circle.radius = 30.5
print('30" circle')
toggleCircle() end
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
	local d,s,c,r = 360/steps, math.sin, math.cos, math.rad
	for i = 0,steps do
		table.insert(t, {
			c(r(d*i))*radius,
			y,
			s(r(d*i))*radius
		})
	end
	return t
end