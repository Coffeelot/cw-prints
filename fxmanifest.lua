fx_version 'cerulean'

game 'gta5'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'config.lua',
}

client_scripts{
    'client/*.lua',
}

server_scripts{
    'server/*.lua',
}

dependency 'qb-target'
dependency 'ps-ui'