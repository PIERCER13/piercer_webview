local TAG = "^3[" .. GetCurrentResourceName() .. "]^0 "
local function log(fmt, ...)
    if select("#", ...) > 0 then fmt = fmt:format(...) end
    print(TAG .. fmt .. "^0")
end

local status = { checked = false, blocked = false, reason = nil, url = nil, frameBlocked = false }

local function fixUrl(url)
    if Config.fixUrls == false or type(url) ~= "string" then return url end

    local yt = url:match("^https?://[%w%.]*youtube%.com/watch%?.-v=([%w_%-]+)")
        or url:match("^https?://youtu%.be/([%w_%-]+)")
        or url:match("^https?://[%w%.]*youtube%.com/shorts/([%w_%-]+)")
    if yt then return "https://www.youtube.com/embed/" .. yt end

    local host, rest = url:match("^https?://([^/%?#]+)(.*)$")
    if host and host:match("^www%.google%.") and not rest:find("igu=", 1, true) then
        local path = rest:match("^[^%?#]*")
        if path == "" or path == "/" or path == "/search" or path == "/webhp" then
            if rest == "" then url = url .. "/" end
            return url .. (url:find("?", 1, true) and "&" or "?") .. "igu=1"
        end
    end
    return url
end

local function lowerKeys(headers)
    local out = {}
    for k, v in pairs(headers or {}) do out[string.lower(k)] = v end
    return out
end

local function blockingFrameAncestors(csp)
    local list = string.match(string.lower(csp), "frame%-ancestors%s+([^;]+)")
    if not list then return nil end
    if string.find(list, "%*") then return nil end           -- libera qualquer origem
    if string.find(list, "cfx%-nui%-") then return nil end    -- libera a NUI do FiveM
    return list
end

local function verify()
    local url = fixUrl(Config.url)
    status.url = url
    if url ~= Config.url then
        log("link ajustado pra abrir no jogo: %s", url)
    end
    -- no modo "auto" a checagem decide iframe x DUI, então roda sempre
    if Config.warnBlocked == false and (Config.mode == "iframe" or Config.mode == "dui") then return end
    if type(url) ~= "string" or url == "" then return end

    if not string.match(url, "^https?://") then
        status = { checked = true, blocked = true, reason = "Config.url precisa começar com https://", url = url, frameBlocked = false }
        log("^3aviso^0: Config.url = \"%s\" não começa com http(s):// — o iframe não carrega", url)
        return
    end

    PerformHttpRequest(url, function(code, _, headers)
        if code == 0 then
            status = { checked = true, blocked = false, reason = nil, url = url, frameBlocked = false }
            log("^3aviso^0: não consegui verificar %s (sem resposta da rede)", url)
            return
        end

        if code >= 400 then
            status = { checked = true, blocked = true, reason = ("site respondeu HTTP %d"):format(code), url = url, frameBlocked = false }
            log("^3aviso^0: %s respondeu HTTP %d", url, code)
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

        status = { checked = true, blocked = reason ~= nil, reason = reason, url = url, frameBlocked = reason ~= nil }

        if reason then
            log("^3aviso^0: %s bloqueia iframe (%s)", url, reason)
            if Config.mode == "iframe" then
                log("^3aviso^0: com Config.mode = \"iframe\" o site fica em branco — use \"auto\" pra abrir via DUI")
            else
                log("abrindo via DUI (mouse e rolagem funcionam; teclado não)")
            end
        else
            log("^2ok^0: %s aceita iframe", url)
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

    return {
        id = id,
        name = framezero.GetName(source) or "",
        reason = (status.blocked and status.reason) or nil,
        url = status.url or fixUrl(Config.url),
        frameBlocked = status.frameBlocked,
    }
end)
