package.cpath = "skynet/luaclib/?.so;luaclib/?.so"
package.path = "skynet/lualib/?.lua;lualib/?.lua"

local socket = require "clientsocket"
local cjson = require "cjson"
local msg_define = require "msg_define"
local fd = assert(socket.connect("127.0.0.1", 8080))

-- 发送消息至服务器
function send_request(name, msg)
    print(name)
    local id = msg_define.name_2_id(name)
    print(id)
    local msg_str = cjson.encode(msg)
    local len = 2 + 2 + #msg_str
    local data = string.pack(">HHs2", len, id, msg_str)
    socket.send(fd, data)

    print("send msg", name)
    for k,v in pairs(msg) do
        print(k,v)
    end
end

last = ""
function recv_package()
    local r = socket.recv(fd)
    if not r then
        return nil
    end
    if r == "" then
        error "Server closed"
    end

    print("recv data", #r)
    last = last .. r

    local len
    local pack_list = {}
    repeat
        if #last < 2 then
            break
        end
        len = last:byte(1) * 256 + last:byte(2)
        if #last < len + 2 then
            break
        end
        table.insert(pack_list, last:sub(3, 2 + len))
        last = last:sub(3 + len) or ""
    until(false)

    return pack_list
end

function deal_package(data)
    local id, msg_str = string.unpack(">Hs2", data)
    print("recv package:", id, msg_str)

    local msg = cjson.decode(msg_str)
    if id == 1 then
        socket.close(fd)

        fd = assert(socket.connect(msg.ip, tonumber(msg.port)))
    end
end

function dispatch_package()
    local pack_list = recv_package()
    if not pack_list then
        return
    end

    for _,v in ipairs(pack_list) do
        deal_package(v)
    end
end

function main()
    --send_request("login.login", {account="a", passwd="a"})
    send_request("login.login", {account="c", passwd="b"})
    socket.usleep(100000)
    dispatch_package()

    -- 发送登陆baseapp协议
    --send_request("login.login_baseapp", {account = "a", token="token"})
    --socket.usleep(100000)
    --dispatch_package()

    --send_request("room.create_table", {})
    --socket.usleep(100000)
    --dispatch_package()
end

main()
