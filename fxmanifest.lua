fx_version 'cerulean'
game 'gta5'
lua54 'yes'

-- Abre um site (Config.url) dentro do jogo pelo comando Config.command.
-- Modelo genérico: pra outro site, copie a pasta e troque o config.lua.
-- Funciona em qualquer framework através da framezero_bridge.

dependency 'framezero_bridge'

ui_page 'nui/index.html'

shared_scripts {
    '@framezero_bridge/import.lua',
    'config.lua',
}

client_script 'client.lua'
server_script 'server.lua'

files {
    'nui/*',
}
