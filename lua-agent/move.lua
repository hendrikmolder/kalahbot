-- Meta class
Move = { side = nil, hole = nil }
Move.__index = Move

-- class method new
function Move:new (o, side, hole)
    if hole < 1 then return nil end
    --luacheck: ignore o
    --luacheck: ignore self
    o = o or {}
    local self = setmetatable(o, Move)
    self.side       = side or nil
    self.hole       = hole or nil

    return self
end

function Move:getSide ()
    return self.side
end

function Move:getHole ()
    return self.hole
end

function Move:toString()
    return 'MOVE(Side: ' .. self.side .. ', Hole: ' .. self.hole .. ')'
end

return Move