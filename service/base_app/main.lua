local skynet = require "skynet"
require "skynet.manager"
local db = require "db"
local sock_mgr = require "sock_mgr"
local player_mgr  = require "player_mgr"
local login_mgr = require "login_mgr"
local msg_handler = require "msg_handler.init"
local token_mgr = require "token_mgr"
local cjson = require "cjson"

local CMD = {}
local gate_conf  = {}

function CMD.start(conf)
    gate_conf = conf
    db:init()
    sock_mgr:start(conf)
    player_mgr:init()
    login_mgr:init()
    msg_handler.init()
end

function CMD.get_gate_conf()
    return gate_conf
end

function CMD.room_begin(msg)
    print("room_begin")
    local obj = player_mgr:get_by_account(msg.account)
    if not obj then
        return
    end

    obj:room_begin(msg)
end

function CMD.sendto_client(account, proto_name, msg)
    local obj = player_mgr:get_by_account(account)
    if not obj then
        return
    end

    obj:sendto_client(proto_name, msg)
end

function CMD.get_base_app_info(account)
    -- TODO IP
    local ret = {
        ip = "127.0.0.1";
        port = tostring(gate_conf.port);
        token = tostring(token_mgr:gen(account));
    }
    skynet.error(cjson.encode(ret))
    return ret
end

skynet.start(function()
    token_mgr:init();

    skynet.dispatch("lua", function(_, session, cmd, subcmd, ...)
        if cmd == "socket" then
            sock_mgr[subcmd](sock_mgr, ...)
            return
        end

        local f = CMD[cmd]
        assert(f, "can't find dispatch handler cmd = "..cmd)

        if session > 0 then
            return skynet.ret(skynet.pack(f(subcmd, ...)))
        else
            f(subcmd, ...)
        end
    end)

    skynet.register("base_app")
end)
