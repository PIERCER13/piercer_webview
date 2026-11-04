local opened = false
local TXD = GetCurrentResourceName() .. "_dui"
local txd = nil
local texCount = 0
local dui, duiTex, duiRect, duiUrl = nil, nil, nil, nil
local duiW, duiH = 0, 0

local function destroyDui()
    if dui then DestroyDui(dui) end
    dui, duiTex, duiRect, duiUrl = nil, nil, nil, nil
end

local function drawDui()
    CreateThread(function()
        while opened and dui do
            DrawRect(0.5, 0.5, 1.0, 1.0, 0, 0, 0, 140)
            local r = duiRect
            local cx, cy = r.x + r.w / 2, r.y + r.h / 2
            if IsDuiAvailable(dui) then
                DrawSprite(TXD, duiTex, cx, cy, r.w, r.h, 0.0, 255, 255, 255, 255)
            else
                DrawRect(cx, cy, r.w, r.h, 18, 18, 18, 255)
            end
            Wait(0)
        end
    end)
end

local function close()
    opened = false
    destroyDui() 
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

RegisterCommand(Config.command, function()
    if opened then return end
    opened = true


    local info = framezero.TriggerCallback(GetCurrentResourceName()..":open", 10000)
    if type(info) ~= "table" or not info.id then
        opened = false
        return
    end

    local mode = Config.mode
    if mode ~= "iframe" and mode ~= "dui" then
        mode = info.frameBlocked and "dui" or "iframe"
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        url = info.url or Config.url,
        mode = mode,
        id = info.id,
        name = info.name,
        blocked = info.reason,
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

RegisterNUICallback("duiStage", function(data, cb)
    cb("ok")
    if not opened then return end
    duiRect = { x = tonumber(data.x) or 0, y = tonumber(data.y) or 0, w = tonumber(data.w) or 1, h = tonumber(data.h) or 1 }
    if dui then return end

    local pw, ph = math.max(320, math.floor(tonumber(data.pw) or 1280)), math.max(240, math.floor(tonumber(data.ph) or 720))
    if pw > 1920 then ph, pw = math.floor(ph * 1920 / pw), 1920 end
    duiW, duiH = pw, ph
    duiUrl = data.url

    dui = CreateDui(duiUrl, duiW, duiH)
    if not txd then txd = CreateRuntimeTxd(TXD) end
    texCount = texCount + 1
    duiTex = "page" .. texCount
    CreateRuntimeTextureFromDuiHandle(txd, duiTex, GetDuiHandle(dui))
    drawDui()
end)

RegisterNUICallback("duiMouse", function(data, cb)
    cb("ok")
    if not dui then return end
    if data.x then
        SendDuiMouseMove(dui, math.floor(data.x * duiW), math.floor(data.y * duiH))
    end
    local button = data.button
    if button ~= "left" and button ~= "middle" and button ~= "right" then return end
    if data.type == "down" then
        SendDuiMouseDown(dui, button)
    elseif data.type == "up" then
        SendDuiMouseUp(dui, button)
    end
end)

RegisterNUICallback("duiWheel", function(data, cb)
    cb("ok")
    if not dui then return end
    -- navegador: deltaY > 0 = descer · CEF: delta > 0 = subir
    SendDuiMouseWheel(dui, -math.floor(tonumber(data.dy) or 0), -math.floor(tonumber(data.dx) or 0))
end)

RegisterNUICallback("duiReload", function(_, cb)
    cb("ok")
    if dui and duiUrl then SetDuiUrl(dui, duiUrl) end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() and opened then
        destroyDui()
        SetNuiFocus(false, false)
    end
end)
