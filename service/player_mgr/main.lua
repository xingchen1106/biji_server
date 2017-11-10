local cjson = require "cjson"
local skynet = require "skynet"
require "skynet.manager"
local player_mgr = require "player_mgr"

local CMD = {}

function CMD.login_lobby(info)
    local acc = player_mgr:get(info.account)
    if not acc then
        player_mgr:add(info)
    end

    return {
        room_card = 100,
    }
end

skynet.start(function()
    skynet.error("player_mgr/main:start")
    skynet.dispatch("lua", function(_, session, cmd, ...)
        skynet.error("player_mgr/dispatch cmd " .. cmd)
        local f = CMD[cmd]
        if not f then
            return
        end

        if session > 0 then
            skynet.ret(skynet.pack(f(...)))
        else
            f(...)
        end
    end)

    player_mgr:init()
    skynet.register("player_mgr")
    skynet.error("player_mgr booted...")
end)
