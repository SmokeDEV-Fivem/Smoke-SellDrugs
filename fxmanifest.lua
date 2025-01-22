fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'SmokeDEV'
description 'Script de vente de drogue aux PNJ de SmokeShop'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target',
    'ox_inventory'
} 
