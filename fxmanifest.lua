fx_version 'cerulean'
game 'gta5'
lua54 'yes'

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
