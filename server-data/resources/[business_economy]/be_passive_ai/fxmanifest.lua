fx_version 'adamant'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/animals.lua',
    'client.lua',
    'client/mainpassiveai.lua'
}

server_scripts {
    'server/randomaiinterval.lua',
    'server/animals.lua'
}

server_exports {
	
}