local id_mgr = require "id_mgr"
local room = require "room"
local cjson = require "cjson"
local skynet = require "skynet"

local M = {}

function M:init()
    id_mgr:init()
    self.room_tbl = {}
    self.player_2_room = {}
    self.ready_tbl = {}
end

function M:create(game_id, player_info)
    skynet.error(cjson.encode(game_id))
    skynet.error(cjson.encode(player_info))

    local ret = {}
    local id = id_mgr:gen_id(game_id)
    self.room_tbl[id] = room.new(id, game_id, player_info)
    self.player_2_room[player_info.account] = id

    ret.roomId = id
    return ret
end

function M:join(room_id, player_info)
    local room = self.room_tbl[room_id]
    if not room then
        return false
    end

    room:add(player_info)
    return ret 
end

function M:change_state(room_id, player_info)
    local room = self.room_tbl[room_id]
    if not room then
        return false
    end

    room:state_change(player_info)
    return ret 
end

function M:deal_card(player_info)
    local room_id = self.player_2_room[player_info.account]
    local room = self.room_tbl[room_id]
    if not room then
        return false
    end

    room:deal_card(player_info)
end



function M:close(room_id)
    local room = self.room_tbl[room_id]
    self.room_tbl[room_id] = nil
    for _,v in ipairs(room.player_list) do
        self.player_2_room[v.account] = nil
    end
end

function M:get_room_by_player(account)
    local id = self.player_2_room[account]
    if not id then
        return
    end

    return self.room_tbl[id]
end

function M:add_ready(room)
    self.ready_tbl[room.id] = room
end

function M:check_ready()
    if not next(self.ready_tbl) then
        return
    end

    print("check_ready")
    for id, room in pairs(self.ready_tbl) do
        room:start()
    end

    self.ready_tbl = {}
end

function M:room_begin(room_id)
    self:close(room_id)
end

return M
