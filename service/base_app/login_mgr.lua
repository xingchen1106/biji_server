local sock_mgr = require "sock_mgr"
local player = require "player"
local player_mgr = require "player_mgr"
-- local token_mgr = require "token_mgr"

local M = {}

function M:init()
    self.new_conn_tbl = {}
    sock_mgr:register_callback("LOGIN_HALL_CMD", self.auth, self)
end

function M:auth(fd, msg)
    if msg.token ~= "token" then
        return {errmsg = "wrong token"}
    end

    self.new_conn_tbl[fd] = nil

    local obj = player.create(fd, msg.account)
    obj:load_from_db()

    player_mgr:add(obj)
    local info = {info = obj:pack()}
    print(info)
    return info
end

return M
