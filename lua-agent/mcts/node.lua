-- Meta class
Move = { side = nil, hole = nil }

-- class method new
function Move:new (o, side, hole)
    if hole < 1 then return nil end

    o = o or {}
    setmetatable(o, self)
    self.__index    = self
    self.side       = side or nil
    self.hole       = hole or nil

    return o
end

function Move:getSide ()
    return self.side
end

function Move:getHole ()
    return self.hole
end

return Move