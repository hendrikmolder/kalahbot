local log = require '..utils.log'

-- Meta class
Node = { state = nil, parent = nil,  children = {}, score = nil }

-- class method new
function Node:new (o, state, parent, children, score)
    if hole < 1 then return nil end

    o = o or {}
    setmetatable(o, self)
    self.__index     = self
    self.state       = state or nil
    self.parent      = parent or nil
    self.children    = children or {}
    self.score       = score or nil

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

function Node:setScore(score)
    self.score = score
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

function Node:getScore()
    return self.score
end

function Node:getRandomChild()
    if (#self.children < 1) then
        log.error('Node has no children.')
        return nil
    end

    return self.children[math.random(1, #self.children)]
end

function Node:GetChildWithMaxScore()
    local maxScore = 0
    local maxChildIndex = nil
    if (#self.children < 1) then return nil end

    for i=1,#self.children do
        if (self.children[i]:getScore() > maxScore) then
            maxChildIndex = i
        end
    end

    return self.children[maxChildIndex]
end

return Node