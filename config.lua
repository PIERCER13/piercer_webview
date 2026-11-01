Config = {}

-- Modelo genérico: abre qualquer site dentro do jogo (iframe).
-- Pra reaproveitar em outro site: copie a pasta, renomeie e
-- troque só os campos abaixo.

Config.url = "linkaqui"
Config.command = "comandoaqui"

-- tecla padrão (o jogador pode trocar em Configurações > Teclas > FiveM). "" = sem tecla
Config.key = ""

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
