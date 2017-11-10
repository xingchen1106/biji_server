local algo = require "algorithm"
local card = require "biji_card"


function one_str(a)
    local suitChars = {'♥','♠','♦','♣'}
    local numberChars = {'A','2','3','4','5','6','7','8','9','10','J','Q','K','A'}
    local suit = a >> 8
    local number = card.getNumber(a)

    return string.format("%s%2s", suitChars[suit+1], numberChars[number]);
end

function print_compare(a1,a2,a3,b1,b2,b3)

    a1,a2,a3 = algo.sort3card(a1,a2,a3);
    b1,b2,b3 = algo.sort3card(b1,b2,b3);

    aStr = one_str(a1) .. one_str(a2) .. one_str(a3)
    bStr = one_str(b1) .. one_str(b2) .. one_str(b3)

    if algo.compare(a1,a2,a3,b1,b2,b3) then
        print(aStr .. " > " .. bStr)
    else
        print(aStr .. " < " .. bStr)
    end
end


function random_card ()
    local random_suit = math.random(0,3);
    local random_num = math.random(13);

    local num = random_suit * 256 + random_num
    return num
end

math.randomseed(os.time())

    --[[
for i = 1,100 do
    local a1 = random_card();
    local a2 = random_card();
    local a3 = random_card();

    print(string.format("%d-%d-%d",a1,a2,a3))
    a1,a2,a3 = algo.sort3card(a1,a2,a3);
    local aStr = one_str(a1) .. one_str(a2) .. one_str(a3)
    print(aStr)

    if algo.isSanTiao(a1,a2,a3) then
        print("isSanTiao");
    end
    if algo.isTongHuaShun(a1,a2,a3) then
        print("isTongHuaShun");
    end
    if algo.isTongHua(a1,a2,a3) then
        print("isTongHua");
    end
    if algo.isShunZi(a1,a2,a3) then
        print("isShunZi");
    end
    if algo.isDuiZi(a1,a2,a3) then
        print("isDuiZi");
    end
    print("--------");
end
]]


-- local suitChars = {'♥','♠','♦','♣'}
--  ♠ J♣ Q♠ 2
--  
--  
--  

--♥ A♠ A♣ A > ♥ 2♠ 2♣ 2
print_compare(0*256+1,1*256+1,3*256+1, 0*256+2,1*256+2,3*256+2)
--♥ 3♠ 3♣ 3 > ♥ 2♠ 2♣ 2
print_compare(0*256+3,1*256+3,3*256+3, 0*256+2,1*256+2,3*256+2)
--♥ A♠ A♣ A > ♥ 2♥ 3♥ 4
print_compare(0*256+1,1*256+1,3*256+1, 0*256+2,0*256+3,0*256+4)
--♥ 2♥ 3♥ 4 > ♥ A♥ 2♥ 3
print_compare(0*256+2,0*256+3,0*256+4, 0*256+1,0*256+2,0*256+3)
--♥ Q♥ K♥ A > ♥ A♥ 2♥ 3
print_compare(0*256+12,0*256+13,0*256+1, 0*256+11,0*256+12,0*256+13)
--♥ A♥ 4♥ 2 > ♥ Q♠ K♣ A
print_compare(0*256+1,0*256+2,0*256+4, 0*256+12,1*256+13,3*256+1)
--♥ A♥ 2♥ 3 > ♥ Q♠ K♣ A
print_compare(0*256+1,0*256+2,0*256+3, 0*256+12,1*256+13,3*256+1)
--♥ A♥ 2♥ 3 > ♥ A♥ 5♥ 4
print_compare(0*256+1,0*256+2,0*256+3, 0*256+1,0*256+4,0*256+5)
--♥ A♥ 2♥ 3 > ♥ A♥ 5♥ 4
print_compare(0*256+1,2*256+2,3*256+3, 0*256+1,1*256+4,2*256+1)
--♥ A♥ 2♥ 3 > ♥ Q♠ K♣ A
print_compare(0*256+1,2*256+2,2*256+3, 0*256+4,1*256+4,2*256+5)
print_compare(0*256+4,1*256+4,2*256+5, 0*256+1,1*256+9,2*256+8)
print_compare(0*256+1,1*256+9,2*256+8, 1*256+1,2*256+9,3*256+8)

-- ♣10♥ A♣ 3
-- 262-775-269
