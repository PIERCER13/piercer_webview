local opened = false

local function close()
    opened = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

RegisterCommand(Config.command, function()
    if opened then return end
    opened = true
    local id, name = framezero.TriggerCallback(GetCurrentResourceName()..":open", 10000)
    if not id then
        opened = false
        return
    end
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        url = Config.url,
        id = id,
        name = name,
        title = Config.title,
        highlight = Config.highlight,
        color = Config.color,
        showId = Config.showId,
        idHint = Config.idHint,
        sendParams = Config.sendParams,
    })
end)

if Config.key ~= "" then
    RegisterKeyMapping(Config.command, "Abrir "..Config.title.." "..Config.highlight, "keyboard", Config.key)
end

RegisterNUICallback("close", function(_, cb)
    close()
    cb("ok")
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() and opened then
        SetNuiFocus(false, false)
    end
end)
