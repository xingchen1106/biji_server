local card = require "biji_card"

local M = {}

function isSanTiao(a, b, c)
    local numberA = card.getNumber(a);
    local numberB = card.getNumber(b);
    local numberC = card.getNumber(c);
    return numberA == numberB and numberA == numberC
end

function isTongHuaShun(a,b,c)
    return M.isTongHua(a,b,c) and M.isShunZi(a,b,c)
end

function isTongHua(a,b,c)
    local suitA = card.getSuits(a);
    local suitB = card.getSuits(b);
    local suitC = card.getSuits(c);
    return suitA == suitB and suitA == suitC
end

function isShunZi(a,b,c)
    local numberA = card.getNumber(a);
    local numberB = card.getNumber(b);
    local numberC = card.getNumber(c);
    return (numberA == numberB - 1 and numberA == numberC - 2)
        or (numberA == numberB + 1 and numberA == numberC + 2)
        or (numberA == 14 and numberB == 3 and numberC == 2) -- A23
end

function isDuiZi(a, b, c)
    local numberA = card.getNumber(a);
    local numberB = card.getNumber(b);
    local numberC = card.getNumber(c);
    return numberA == numberB or numberA == numberC or numberB == numberC
end


function M.sort3card(a, b, c)
    a,b,c = dealA(a,b,c)
    local an = card.getNumber(a);
    local bn = card.getNumber(b);
    local cn = card.getNumber(c);

    if an < bn then
        a, b = b, a
        an,bn = bn,an
    end
    if an < cn then
        a, c = c, a
        an,cn = cn,an
    end
    if bn < cn then
        b, c = c, b
        bn,cn = cn,bn
    end

    if an == 14 and bn == 3 and cn == 2  then -- A23
        a, b, c = card.getSuits(a)+1, card.getSuits(b)+2, card.getSuits(c)+3
    elseif isShunZi(a,b,c) then
        a,b,c = c,b,a
    end

    if not isSanTiao(a, b, c) then
        if an == cn then
            b,c = c,b
            bn,cn = cn,bn
        elseif bn == cn then
            a,c = c,a
            an,cn = cn,an
        end
        if an == bn and card.getSuits(a) > card.getSuits(b) then
            a,b = b,a
        end
    end

    return a, b, c
end

function dealA(a, b, c)
    if card.getNumber(a) == 1 then
        a = card.getSuits(a) + 14
    end

    if card.getNumber(b) == 1 then
        b = card.getSuits(b) + 14
    end

    if card.getNumber(c) == 1 then
        c = card.getSuits(c) + 14
    end
    return a, b, c
end


function compareNumber(a1,a2,a3,b1,b2,b3)
    local an1 = card.getNumber(a1);
    local an2 = card.getNumber(a2);
    local an3 = card.getNumber(a3);
    local bn1 = card.getNumber(b1);
    local bn2 = card.getNumber(b2);
    local bn3 = card.getNumber(b3);

    local numValueA = an1 * 400 + an2 * 20 + an3 * 1
    local numValueB = bn1 * 400 + bn2 * 20 + bn3 * 1
    if numValueA ~= numValueB then
        return numValueA > numValueB
    else
        return card.getSuits(a1) < card.getSuits(b1)
    end
end

function compareResult(resultA, resultB)
    local needReturn, result;
    if resultA and resultB then
        needReturn = false;
        result = true;
    elseif not resultA and not resultB then
        needReturn = false;
        result = false;
    elseif resultA then
        needReturn = true
        result = true;
    elseif resultB then
        needReturn = true;
        result = false;
    end
    return needReturn, result;
end

function M.compare(a1,a2,a3,b1,b2,b3)
    a1,a2,a3 = M.sort3card(a1,a2,a3)
    b1,b2,b3 = M.sort3card(b1,b2,b3)

    local aNumber1 = card.getNumber(a1);
    local aNumber2 = card.getNumber(a2);
    local aNumber3 = card.getNumber(a3);
    local bNumber1 = card.getNumber(b1);
    local bNumber2 = card.getNumber(b2);
    local bNumber3 = card.getNumber(b3);

    local valueA = 0;
    local valueB = 0;

    local needReturn ,result = compareResult(isSanTiao(a1,a2,a3), isSanTiao(b1,b2,b3))
    if needReturn then
        return result
    elseif result then
        return compareNumber(a1,a2,a3,b1,b2,b3)
    end

    needReturn ,result = compareResult(isTongHuaShun(a1,a2,a3), isTongHuaShun(b1,b2,b3))
    if needReturn then
        return result
    elseif result then
        return compareNumber(a1,a2,a3,b1,b2,b3)
    end

    needReturn ,result = compareResult(isTongHua(a1,a2,a3), isTongHua(b1,b2,b3))
    if needReturn then
        return result
    elseif result then
        return compareNumber(a1,a2,a3,b1,b2,b3)
    end


    needReturn ,result = compareResult(isShunZi(a1,a2,a3), isShunZi(b1,b2,b3))
    if needReturn then
        return result
    elseif result then
        return compareNumber(a1,a2,a3,b1,b2,b3)
    end

    local needReturn ,result = compareResult(isDuiZi(a1,a2,a3), isDuiZi(b1,b2,b3))
    if needReturn then
        return result
    elseif result then
        return compareNumber(a1,a2,a3,b1,b2,b3)
    end

    return compareNumber(a1,a2,a3,b1,b2,b3)
end

M.isSanTiao = isSanTiao
M.isTongHuaShun = isTongHuaShun
M.isTongHua = isTongHua
M.isShunZi = isShunZi
M.isDuiZi = isDuiZi

return M
