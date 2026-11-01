-- Framework, permissão e notificação ficam com a framezero_bridge
-- (ESX, QBCore, Qbox, vRP, vRPex, Creative ou standalone).

-- ── Preflight: o site aceita ser aberto dentro de um iframe? ──────────────────
-- A NUI é um Chromium (CEF) e obedece X-Frame-Options e CSP frame-ancestors do
-- site. Quando o site bloqueia, o iframe fica preto e o jogador (e você) não
-- entende o motivo. Aqui a gente faz um GET em Config.url na inicialização,
-- avisa no console e manda o motivo pra NUI mostrar um aviso com "copiar link".

local status = { checked = false, blocked = false, reason = nil }

local function lowerKeys(headers)
    local out = {}
    for k, v in pairs(headers or {}) do out[string.lower(k)] = v end
    return out
end

-- Retorna a lista do frame-ancestors quando ela NÃO libera a NUI do FiveM
-- (origem https://cfx-nui-<resource>). nil = libera / não tem a diretiva.
-- Obs.: "https:" sozinho não conta como liberado — o GitBook manda
-- "frame-ancestors https: ionic: capacitor:" e mesmo assim o CEF bloqueia.
local function blockingFrameAncestors(csp)
    local list = string.match(string.lower(csp), "frame%-ancestors%s+([^;]+)")
    if not list then return nil end
    if string.find(list, "%*") then return nil end           -- libera qualquer origem
    if string.find(list, "cfx%-nui%-") then return nil end    -- libera a NUI do FiveM
    return list
end

local function verify()
    local url = Config.url
    if Config.warnBlocked == false then return end
    if type(url) ~= "string" or url == "" then return end

    -- "linkaqui", "meusite.com" (sem esquema): o iframe trata como caminho
    -- relativo da NUI e não carrega nada. É o erro mais comum.
    if not string.match(url, "^https?://") then
        status = { checked = true, blocked = true, reason = "Config.url precisa começar com https://" }
        framezero.Log("warn", "Config.url = \"%s\" não começa com http(s):// — o iframe não carrega", url)
        return
    end

    PerformHttpRequest(url, function(code, _, headers)
        if code == 0 then
            status = { checked = true, blocked = false, reason = nil }
            framezero.Log("warn", "não consegui verificar %s (sem resposta da rede)", url)
            return
        end

        if code >= 400 then
            status = { checked = true, blocked = true, reason = ("site respondeu HTTP %d"):format(code) }
            framezero.Log("warn", "%s respondeu HTTP %d", url, code)
            return
        end

        local h = lowerKeys(headers)
        local xfo = h["x-frame-options"]
        local csp = h["content-security-policy"]   -- report-only não bloqueia, então ignora
        local reason

        if xfo and (string.lower(xfo):find("deny", 1, true) or string.lower(xfo):find("sameorigin", 1, true)) then
            reason = "X-Frame-Options: " .. xfo
        elseif csp then
            local list = blockingFrameAncestors(csp)
            if list then reason = "CSP frame-ancestors " .. list end
        end

        status = { checked = true, blocked = reason ~= nil, reason = reason }

        if reason then
            framezero.Log("warn", "%s bloqueia iframe (%s)", url, reason)
            framezero.Log("warn", "a janela abre, mas o site fica em branco: use um site que permita iframe, "
                .. "ou libere 'Content-Security-Policy: frame-ancestors https://cfx-nui-%s' no site",
                GetCurrentResourceName())
        else
            framezero.Log("info", "%s aceita iframe — ok", url)
        end
    end, "GET")
end

-- Espera a bridge/framework subir antes de logar.
CreateThread(function()
    Wait(1500)
    verify()
end)


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

    -- 3º valor: motivo do bloqueio (nil = site ok / não verificado). A NUI usa
    -- isso pra mostrar o aviso em vez de deixar a tela preta sem explicação.
    return id, framezero.GetName(source) or "", (status.blocked and status.reason) or nil
end)
