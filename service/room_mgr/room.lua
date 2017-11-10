local skynet = require "skynet"
local G = require "global"

local M = {}

M.__index = M

function M.new(...)
    local o = {}
    setmetatable(o, M)
    M.init(o, ...)
    return o
end

function M:init(id, game_id, player_info)
    self.id = id
    self.game_id = game_id
    self.owner_account = player_info.account
    self.player_list = {player_info}
    self.player_state = {[player_info.account] = true}
    self.ready = false
    self.getting_area = false
    self:notify()
    -- self:notify_state()
end

function M:add(player_info)
    table.insert(self.player_list, player_info)
    table.insert(self.player_state, {[player_info.account] = true})
    self:notify()
    -- self:notify_state()
    --[[
    if #self.player_list == 4 then
        print("房间凑齐了四个人")
        self.ready = true
        G.room_mgr:add_ready(self)
    end
    ]]
end

function M:start()
    print("开启一桌")
    local area = skynet.call("area_mgr", "lua", "get_area", self.game_id)
    self.getting_area = true
    skynet.send(area.addr, "lua", "create_room", self:pack())
end

function M:notify()
    local base_app = skynet.queryservice("base_app")
    for _,player in ipairs(self.player_list) do
        skynet.call(base_app, "lua", "sendto_client", player.account, "ROOM_ENTER_NOTIFY_CMD", self:pack())
    end
end


-- state
function M:notify_state()
    local base_app = skynet.queryservice("base_app")
    for _,player in ipairs(self.player_list) do
        skynet.call(base_app, "lua", "sendto_client", player.account, "ROOM_STATE_CHANGE_CMD", self.player_state)
    end
end

function M:state_change(account)
    self.player_list[account] = not self.player_list[account]
    notify_state();
end

-- game

local function shuffle(t)
    if not t then return end
    local cnt = #t
    for i=1,cnt do
        local j = math.random(i,cnt)
        t[i],t[j] = t[j],t[i]
    end
end

function M:deal_card(account)
    local cards = {}
    for i = 0,3 do
        for j = 1,13 do
            cards.insert(i<<8 + j);
        end
    end
    shuffle(cards)

    local base_app = skynet.queryservice("base_app")
    for _,player in ipairs(self.player_list) do
        local send_cards = {};
        table.move(cards,1,9,1,send_cards)
        skynet.call(base_app, "lua", "sendto_client", player.account, "GAME_DEAL_CARD", send_cards)
    end
end


function M:solution_card(account)
    local cards = {}
    for i = 0,3 do
        for j = 1,13 do
            cards.insert(i<<8 + j);
        end
    end
    shuffle(cards)

    local base_app = skynet.queryservice("base_app")
    for _,player in ipairs(self.player_list) do
        local send_cards = {};
        table.move(cards,1,9,1,send_cards)
        skynet.call(base_app, "lua", "sendto_client", player.account, "GAME_DEAL_CARD", send_cards)
    end
end



function M:compare(account)
end

function M:send_result(account)
end


function M:pack()
    return {
        id = self.id,
        ownerAccount = self.owner_account,
        playerList = self.player_list
    }
end

return M
