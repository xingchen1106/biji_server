local M = {}

local id_tbl = {
    -- 登陆协议
    {name = "LOGIN_CMD"},
    {name = "REGISTER_CMD"},
    {name = "LOGIN_HALL_CMD"},

    -- 房间
    {name = "CREATE_ROOM_CMD"},
    {name = "JOIN_ROOM_CMD"},
    {name = "ROOM_ENTER_NOTIFY_CMD"},
    {name = "ROOM_STATE_CHANGE_CMD"},

    -- 游戏
    {name = "GAME_DEAL_CARD"},                          -- 发牌
    {name = "GAME_CARD_SOLUTION"},                      -- 打牌
    {name = "GAME_RESULT"},                             -- 结果
}

local error_tbl = {
    ["INDEXS_ERROR"] = 1100,

}

function M.getError(name)
    return error_tbl[name]
end



local name_tbl = {}

for id,v in ipairs(id_tbl) do
    name_tbl[v.name] = id
end

function M.name_2_id(name)
    return name_tbl[name]
end

function M.id_2_name(id)
    local v = id_tbl[id]
    if not v then
        return
    end

    return v.name
end

function M.get_by_id(id)
    return id_tbl[id]
end

function M.get_by_name(name)
    local id = name_tbl[name]
    return id_tbl[id]
end

return M
