fx_version 'cerulean'
game 'gta5'
-- Resource Metadata
author 'EddiesLife247'
description 'PD Clothing Menu'
version '1.0.0'
lua54 'yes' -- This ensures the asset is compatible with Lua 5.4



shared_script {
    '@ox_lib/init.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}
exports {
    'IsRoped'
}


dependency 'ox_lib'
dependency 'ox_target'
