local time = 7200
local incr = 900
local mult = 0

function onLoad()
    self.clearContextMenu()
    self.addContextMenuItem("Add 15 minutes", function()
        mult = mult + 1
        self.Clock.setValue(math.max(time + incr * mult, incr))
    end)
    self.addContextMenuItem("Subtract 15 minutes", function()
        if time + incr * mult > 0 then mult = mult - 1 end
        self.Clock.setValue(math.max(time + incr * mult, incr))
    end)
end