local placed = false

function onSave()
    return JSON.encode({
        placed = placed
    })
end

function onLoad(saved_data)
    self.interactable = false
    if not JSON.decode(saved_data).placed then
        ml = JSON.decode(self.script_state).ml
        self.createButton({
            label="Place", click_function="buttonClick_place", function_owner=self,
            position={0,15,-2}, rotation={0,180,0}, height=800, width=4300,
            font_size=250, color={0,0,0,0}, font_color={1,1,1,1}
        })
    end
end

function buttonClick_place()
    if placed then
        return
    end
    local item = nil
    for _, bagObj in ipairs(self.getObjects()) do
        if ml[bagObj.guid] ~= nil then
            item = self.takeObject({
                guid=bagObj.guid,
                position = ml[bagObj.guid].pos,
                rotation = ml[bagObj.guid].rot,
                smooth = false,
            })
            item.setLock(true)
        end
    end
    placed = true
    broadcastToAll("Objects Placed", {1,1,1})
end
