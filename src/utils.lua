Utils = {}

-- Setting pos, rot, or scale to nil will use the default values for those parameters in spawnObjectData
function Utils.cloneObjectNoSound(obj_data, pos, rot, scale, callback)
    if not obj_data then
        broadcastToAll("Error: No object data provided for cloning.")
        return
    end
    return spawnObjectData({
        data = obj_data,
        position = pos,
        rotation = rot,
        scale = scale,
        sound = false,
        callback_function = callback
    })
end

return Utils