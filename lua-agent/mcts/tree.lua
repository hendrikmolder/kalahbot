-- Meta class
Tree = { root = nil }

-- class method new
function Tree:new (o, root)

    o = o or {}
    setmetatable(o, self)
    self.__index    = self
    self.root       = root or nil

    return o
end

return Tree