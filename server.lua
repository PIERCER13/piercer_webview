-- Framework, permissão e notificação ficam com a framezero_bridge
-- (ESX, QBCore, Qbox, vRP, vRPex, Creative ou standalone).

framezero.RegisterCallback(GetCurrentResourceName()..":open", function(source)
    local id = framezero.GetPlayerId(source)
    if not id then return false end

    if #Config.perms > 0 then
        local allowed = false
        for _, perm in ipairs(Config.perms) do
            if framezero.HasPermission(source, perm) then allowed = true break end
        end
        if not allowed then
            framezero.Notify(source, "error", Config.denied, 5000)
            return false
        end
    end

    return id, framezero.GetName(source) or ""
end)
