
local M = {}


local numberMask    = 0x0ff;
local suitsMask     = 0xf00;

local HongTaoMask   = 0x000;
local HeiTaoMask    = 0x100;
local FangKuaiMask  = 0x200;
local MeiHuaMask    = 0x300;

function M.getSuits(value)
    return value & suitsMask
end

function M.getNumber(value)
    return value & numberMask
end


return M

