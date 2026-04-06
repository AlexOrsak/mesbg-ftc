local arcs = { -- 1st ARC (can copy paste as many arcs as required)
{
	name = "Siege Weapon Firing Arc",
	origin = {0, 0.1, 0}, -- arc origin position {x,y,z}
	range = {7, 60.8}, -- arc range {min,max} in TTS units (inch)
	clr1 = {0, 1, 0}, -- outer range colour {r,g,b}
	clr2 = {1, 0, 0}, -- inner range colour {r,g,b}
}}

local arcs_on = 0
local arc_scale = 1
local floor = math.floor

function onLoad()
	for i, elm in ipairs(arcs) do
		self.addContextMenuItem(elm.name, function() ArcDraw(i) end, false)
	end
	arc_scale = 1 / self.getScale().x
end

function ArcDraw(idno)
	if arcs_on == idno then
		self.setVectorLines()
		arcs_on = 0
		return
	end
	local arc = arcs[idno]
	local fwd_long = Vector(0, 0, arc.range[2] * arc_scale)
	local fwd_short = Vector(0, 0, arc.range[1] * arc_scale)
	local pos_origin = Vector(0, arc.origin[2] * arc_scale, 0)

	local vec = Vector(0, 0, 0)
	local long, short = {}, {}
    local longi, shorti = 1, 1
	short[shorti] = pos_origin
    shorti = shorti + 1

	fwd_long:rotateOver('y', -27.5)
	fwd_short:rotateOver('y', -27.5)
    vec = pos_origin + fwd_short
    vec:rotateOver('y', 5)
    long[longi] = vec
    longi = longi + 1
	for i = -22.5, 22.5, 5 do
		fwd_long:rotateOver('y', 5)
		fwd_short:rotateOver('y', 5)
		vec = pos_origin + fwd_long
		vec.y = pos_origin.y
		long[longi] = vec
        longi = longi + 1
		vec = pos_origin + fwd_short
		vec.y = pos_origin.y
		short[shorti] = vec
        shorti = shorti + 1
	end
    long[longi] = vec
    longi = longi + 1
    short[shorti] = pos_origin
    shorti = shorti + 1
	self.setVectorLines({{
		points = long,
		color = arc.clr1,
		thickness = 0.1 * arc_scale
	}, {
		points = short,
		color = arc.clr2,
		thickness = 0.1 * arc_scale
	}})
	arcs_on = idno
end
