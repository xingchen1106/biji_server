local skynet = require "skynet"
local G = require "global"
local msg_define = require "msg_define"
local algorithm = require "algorithm"

local M = {}

M.__index = M

local ONE_GROUP_CARD_NUM = 9

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
    self.player_cards = {}
    self.player_score = {}
    self.player_solutions = {}
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


-- 发牌
function M:deal_card(account)

    local cards = {}
    for i = 0,3 do
        for j = 1,13 do
            cards.insert(i<<8 + j);
        end
    end

    for i = 0,50 do
        shuffle(cards)
    end

    local base_app = skynet.queryservice("base_app")
    for _,player in ipairs(self.player_list) do
        self.player_cards[player.account] = {}
        self.player_solutions[player.account] = nil

        table.move(cards,1,ONE_GROUP_CARD_NUM,1,self.player_cards[player.account])
        skynet.call(base_app, "lua", "sendto_client", player.account, "GAME_DEAL_CARD", self.player_cards[player.account])
    end
end

-- 检查是否有9张卡，和是否符合 1 ~ 9的要求
local function check_solution(indexs)
    local indexErrorCode = msg_define.getError("INDEXS_ERROR")
    if not #indexs == ONE_GROUP_CARD_NUM then
        return { errCode = indexErrorCode };
    
    for i = 1, ONE_GROUP_CARD_NUM do
        local findFlag = false
        for j = 1 ,ONE_GROUP_CARD_NUM do
            if indexs[j] == i then
                findFlag = true;
            end
        end

        if not findFlag then
            return { errCode = indexErrorCode };
        end
    end
end


local function M:isSolutionFull()
    for _, solution in self.player_solutions then
        if solution == nil then
            return false;
        end
    end
    return true;
end


-- 存储牌
function M:solution_card(account, indexs)
    local checkResult = check_solution(indexs)
    if checkResult then
        return checkResult
    end

    self.player_solutions[account] = indexs

    if self:isSolutionFull() then
        self:notify_result();
    end
end


function M:compare1(a,b)
    local a1 = self.player_cards[a][self.player_solutions[a][1]];
    local a2 = self.player_cards[a][self.player_solutions[a][2]];
    local a3 = self.player_cards[a][self.player_solutions[a][3]];
    local b1 = self.player_cards[b][self.player_solutions[b][1]];
    local b2 = self.player_cards[b][self.player_solutions[b][2]];
    local b3 = self.player_cards[b][self.player_solutions[b][3]];
    return algorithm.compare(a1, a2, a3, b1, b2 ,b3);
end

function M:compare2(a,b)
    local a1 = self.player_cards[a][self.player_solutions[a][4]];
    local a2 = self.player_cards[a][self.player_solutions[a][5]];
    local a3 = self.player_cards[a][self.player_solutions[a][6]];
    local b1 = self.player_cards[b][self.player_solutions[b][4]];
    local b2 = self.player_cards[b][self.player_solutions[b][5]];
    local b3 = self.player_cards[b][self.player_solutions[b][6]];
    return algorithm.compare(a1, a2, a3, b1, b2 ,b3);
end

function M:compare3(a,b)
    local a1 = self.player_cards[a][self.player_solutions[a][7]];
    local a2 = self.player_cards[a][self.player_solutions[a][8]];
    local a3 = self.player_cards[a][self.player_solutions[a][9]];
    local b1 = self.player_cards[b][self.player_solutions[b][7]];
    local b2 = self.player_cards[b][self.player_solutions[b][8]];
    local b3 = self.player_cards[b][self.player_solutions[b][9]];
    return algorithm.compare(a1, a2, a3, b1, b2 ,b3);
end


local function M:getScoreList(ids)
    local scoreList = {}
    for i,v in ids do
        if i == 1 then
            scoreList[v] = 5;
        else
            scoreList[v] = -i + 1;
        end
    end
    -- TODO 根据配置 和 设定的喜牌类型
    return scoreList
end

-- 发送结果
function M:notify_result()
    local result = {}
    local ids = {1, 2, 3, 4 ,5}

    table.sort(ids, self.compare1);
    table.insert(result, self:getScoreList(ids));

    table.sort(ids, self.compare2);
    table.insert(result, self:getScoreList(ids));

    table.sort(ids, self.compare3);
    table.insert(result, self:getScoreList(ids));

    local base_app = skynet.queryservice("base_app")
    for _,player in ipairs(self.player_list) do
        skynet.call(base_app, "lua", "sendto_client", player.account, "GAME_RESULT", result)
    end
end

function M:pack()
    return {
        id = self.id,
        ownerAccount = self.owner_account,
        playerList = self.player_list
    }
end

return M
