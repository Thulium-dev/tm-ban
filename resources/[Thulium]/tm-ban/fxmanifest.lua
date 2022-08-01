fx_version 'cerulean'
game 'gta5'

author 'Thulium.dev'
description "Bans players if there are in Thulium.dev's modder database"
version '0.1.0'

server_scripts {
    'config.lua',
    'server.lua'
}

escrow_ignore {
    'config.lua'
}

server_only 'yes'

lua54 'yes'