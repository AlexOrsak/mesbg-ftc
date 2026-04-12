local os, sc = self.getLuaScript()
local og_length, new_length = string.len(os)

function objectCheck()
    sc = self.getLuaScript()
    new_length = string.len(sc)
    if og_length ~= new_length then
        self.setState(2) -- let the fun begin
    end
end

Wait.time(objectCheck, 15, -1) -- 15 seconds, can modify here.