local skynet = require "skynet"

local function main()
    skynet.newservice("debug_console", 8081)

    -- 登陆服务
    local login = skynet.newservice("login")
    skynet.call(login, "lua", "start", {
        port = 8080,
        maxclient = 1000,
        nodelay = true,
    })

    local base_app = skynet.uniqueservice("base_app")
    skynet.call(base_app, "lua", "start", {
        port = 9000,
        maxclient = 1000,
        nodelay = true,
    })

    skynet.uniqueservice("player_mgr")
    skynet.uniqueservice("room_mgr")

    skynet.exit()
end

skynet.start(main)
