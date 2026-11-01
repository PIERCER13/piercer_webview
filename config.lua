Config = {}

-- Modelo genérico: abre qualquer site dentro do jogo (iframe).
Config.url = "https://www.netlify.com/"
Config.command = "comandoaqui"

-- tecla padrão (o jogador pode trocar em Configurações > Teclas > FiveM). "" = sem tecla
Config.key = ""

-- Como o site é exibido:
--   "auto"   → iframe; se o site bloquear iframe (X-Frame-Options / CSP
--              frame-ancestors: YouTube, GitBook, Instagram…) abre via DUI
--   "iframe" → sempre iframe (sites que bloqueiam ficam em branco)
--   "dui"    → sempre DUI
-- DUI = navegador separado desenhado pelo jogo: abre qualquer site, mouse e
-- rolagem funcionam, mas o TECLADO NÃO (o FiveM não repassa teclas pra DUI).
-- Pra sites onde precisa digitar, a janela mostra "abrir no navegador".
Config.mode = "auto"

-- Ajusta links conhecidos pra versão que abre em iframe (com teclado):
-- youtube.com/watch?v=ID, youtu.be/ID, /shorts/ID → youtube.com/embed/ID
-- www.google.com (início/busca) → ?igu=1
Config.fixUrls = true

-- Ao iniciar, faz um GET em Config.url, avisa no console do servidor quando o
-- site bloqueia iframe e mostra o motivo na janela. No modo "auto" a checagem
-- roda mesmo com isso desligado (é ela que decide iframe x DUI).
Config.warnBlocked = true

-- quem pode abrir. Vazio = todo mundo
-- aceita o que o seu framework entende por permissão (via framezero_bridge):
-- vRP: permissão/grupo · QBCore/Qbox: job, gang, grupo ou ACE · ESX: grupo ou job · standalone: ACE
Config.perms = {}

-- textos da janela
Config.title = ""          -- título no topo
Config.highlight = ""        -- parte destacada do título (cor de destaque). "" = nada
Config.color = "#9a9a9a"        -- cor de destaque (título, ID)
Config.denied = "Você não tem acesso a isso."

-- mostra o ID do personagem no topo (com botão de copiar), pra sites que pedem ID
-- vRP: passaporte · QBCore/Qbox: citizenid · ESX: identifier · standalone: license
Config.showId = false
Config.idHint = "Use seu ID:"

-- manda ?id=<id>&nome=<nome> na URL do site (só serve se o site ler isso)
Config.sendParams = false
