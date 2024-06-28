fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Apex Money Management'
version '1.0.0'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/sounds/open.mp3',
    'nui/sounds/close.mp3',
    'nui/sounds/error.mp3'
}

shared_script 'Config/config.lua' -- Shared script to ensure Config is available

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

dependency 'oxmysql'
