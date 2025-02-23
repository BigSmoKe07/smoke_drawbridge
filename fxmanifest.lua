fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
this_is_a_map 'yes'

name 'smoke_drawbridge'
repository 'https://github.com/BigSmoKe07/smoke_drawbridge'
version '1.3.0'
author 'BigSmoKe07'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua',
}

dependencies {
    '/onesync',
    'ox_lib',
}

files {
    'config/*.lua',
    'shared/utils.lua',
    'locales/*.json'
}

data_file 'DLC_ITYP_REQUEST' 'stream/drawbridge.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/nodes368.ynd'

ox_libs {
    'locale'
}
