fx_version 'cerulean'
game 'gta5'

author 'Andromeda'
description 'Apex Money Management'
version '1.0.0'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/sounds/open.mp3',
    'nui/sounds/error.mp3'
}

shared_script 'Config/config.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@Apex/Server/functions.lua',  -- Ensure Apex functions are available
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

dependencies {
    'Apex',
    'oxmysql'
}
