local opened = false

local function close()
    opened = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

RegisterCommand(Config.command, function()
    if opened then return end
    opened = true

    -- 3º retorno: motivo quando o site bloqueia iframe (X-Frame-Options /
    -- CSP frame-ancestors). nil = site ok ou ainda não verificado.
    local id, name, blocked = framezero.TriggerCallback(GetCurrentResourceName()..":open", 10000)
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
        blocked = blocked,
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
