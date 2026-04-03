function onload() self.interactable = false
end

function onSave()
    saveTable = {interactable = self.interactable}
    saved_data = JSON.encode(saveTable)
    return saved_data
end

function onLoad(saved_data)
    loadTable = JSON.decode(saved_data)
    self.interactable = loadTable.interactable
end