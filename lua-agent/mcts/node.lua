-- Meta class
Node = { state = nil, parent = nil,  children = {} }

-- class method new
function Node:new (o, state, parent, children)
    if hole < 1 then return nil end

    o = o or {}
    setmetatable(o, self)
    self.__index     = self
    self.state       = state or nil
    self.parent      = parent or nil
    self.children    = children or {}

    return o
end

-- Getters and setters

function Node:setState(state)
    self.state = state
end

function Node:setParent(parent)
    self.parent = parent
end

function Node:addChildren(child)
    table.insert(self.children, child)
end

function Node:getState()
    return self.state
end

function Node:getParent()
    return self.parent
end

function Node:getChildren()
    return self.children
end

return Node