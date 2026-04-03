function onLoad()
    self.clearContextMenu()
    self.addContextMenuItem("Start 1h 30m Timer", function()
        self.Clock.setValue(1 * 3600 + 30 * 60)  -- 1 hour 30 minutes in seconds = 5400
    end)
    self.addContextMenuItem("Start 1h 45m Timer", function()
        self.Clock.setValue(1 * 3600 + 45 * 60)  -- 1 hour 45 minutes in seconds = 6300
    end)
    self.addContextMenuItem("Start 2h Timer", function()
        self.Clock.setValue(2 * 3600)  -- 2 hours in seconds = 7200
    end)
    self.addContextMenuItem("Start 2h 15m Timer", function()
        self.Clock.setValue(2 * 3600 + 15 * 60)  -- 2 hours 15 minutes in seconds = 8100
    end)
end
