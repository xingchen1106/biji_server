local skynet = require "skynet"
local player_mgr = require "player_mgr"

local M = {}

function M.CREATE_ROOM_CMD(fd, request)
    local player = player_mgr:get_by_fd(fd)
    local ret = skynet.call("room_mgr", "lua", "create_room", 1, player:pack())
    return ret
end

function M.ROOM_STATE_CHANGE_CMD(fd, request)
    local player = player_mgr:get_by_fd(fd)
    local ret = skynet.call("room_mgr", "lua", "change_room_state", 1, player:pack())
    return ret
end

function M.JOIN_ROOM_CMD(fd, request)
    local player = player_mgr:get_by_fd(fd)
    local roomId = request.roomId
    local ret = skynet.call("room_mgr", "lua", "join_room", roomId, player:pack())
    return ret
end

return M
