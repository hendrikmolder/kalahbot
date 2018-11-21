-- class method for MoveTurn
MoveTurn = { endMove = false, again = false, move = nil }
MoveTurn.__index = MoveTurn

function MoveTurn:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index    = self
    self.endMove    = false
    self.again      = false
    self.endMove    = nil

    return o
end

return MoveTurn