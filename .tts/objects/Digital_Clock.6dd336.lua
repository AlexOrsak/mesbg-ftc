function onLoad()
    self.clearContextMenu()
    self.addContextMenuItem("Start 1h 30m Timer", function()
        self.Clock.setValue(1 * 3600 + 30 * 60)  -- 5400
    end)
    self.addContextMenuItem("Start 1h 45m Timer", function()
        self.Clock.setValue(1 * 3600 + 45 * 60)  -- 6300
    end)
    self.addContextMenuItem("Start 2h Timer", function()
        self.Clock.setValue(2 * 3600)  -- 7200
    end)
    self.addContextMenuItem("Start 2h 15m Timer", function()
        self.Clock.setValue(2 * 3600 + 15 * 60)  -- 8100
    end)
    self.addContextMenuItem("Start 2h 30m Timer", function()
        self.Clock.setValue(2 * 3600 + 30 * 60)  -- 9000
    end)
end