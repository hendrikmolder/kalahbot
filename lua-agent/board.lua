--
-- Created by IntelliJ IDEA.
-- User: aayushchadha
-- Date: 19/11/18
-- Time: 13:07
-- The implementation is based on ../mankalah/MKAgent/Board.java
--

-- Create a board object with default values
-- board variable is instantiated as a table / matrix,
-- we shall add the rows later
Side = require 'side'

Board = {NORTH_ROW = 1, SOUTH_ROW = 2, holes=1, seeds=0, board={}}

Board.__index = Board

function Board:indexOfSide(side)
    -- DONE Not sure if we should be using a string here
    if (side == Side.NORTH) then
        return self.NORTH_ROW
    else
        return self.SOUTH_ROW
    end
end

-- Board can be created with or without specifying any of the parameters
function Board:new(o, holes, seeds)
    --luacheck: ignore o
    local o = o or {}
    self = setmetatable(o, self)
--    self.__index = self
    self.holes = holes or 1
    self.seeds = seeds or 0
    self.board = {}
    for side=1,2 do
        -- Create Player Wells
        self.board[side] = {}
        for well=1,holes+1 do
            -- Add seed to player well
            if well <= self.holes then self.board[side][well] = seeds
            -- Handle scoring well
            else self.board[side][well] = 0 end

        end

    end

    return self
end

-- Method to deep copy board for agent manipulation
-- Taken from https://gist.github.com/tylerneylon/81333721109155b2d244#file-copy-lua-L50
function Board:copyBoard(obj)
    if type(obj) ~= 'table' then return obj end
    -- Set the meta table for lookups to be the same as the copied object
    local res = setmetatable({}, getmetatable(obj))
    -- Copy table elements to the agent's copy
    for k,v in pairs(obj) do res[self:copyBoard(k)] = self:copyBoard(v) end
    return res

end

function Board:getNoOfHoles()
    return tonumber(self.holes)
end

function Board:getSeeds(side, hole)
    return tonumber(self.board[self:indexOfSide(side)][hole])
end

function Board:setSeeds(side, hole, seeds)
    self.board[self:indexOfSide(side)][hole] = seeds
end

function Board:addSeeds(side, hole, seeds)
    self.board[self:indexOfSide(side)][hole] = self:getSeeds(side, hole) + seeds
end

function Board:getSeedsOp(side, hole)
    -- Because of Lua's weird representation, we have to ensure the store lookup
    -- doesn't return a nil value
    if hole == 8 then return 0 end
    if (side == Side.NORTH) then return tonumber(self.board[2][self.holes+1-hole])
    else return tonumber(self.board[1][self.holes+1-hole]) end
end

function Board:setSeedsOp(side, hole, seeds)
    if (side == Side.NORTH) then self.board[2][self.holes+1-hole] = seeds
    else self.board[1][self.holes+1-hole] = seeds end
end

-- DONE this function's logic seems a bit dodgy to me, hopefully tests catch it if it is
function Board:addSeedsOp(side, hole, seeds)
    if (side == Side.NORTH) then self.board[2][self.holes+1-hole] = self:getSeedsOp(side, hole) + seeds
    else self.board[1][self.holes+1-hole] = self:getSeedsOp(side, hole) + seeds end
end

function Board:getSeedsInStore(side)
    return tonumber(self.board[self:indexOfSide(side)][8])
end

function Board:setSeedsInStore(side, seeds)
    self.board[self:indexOfSide(side)][8] = seeds
end

function Board:addSeedsToStore(side, seeds)
    self.board[self:indexOfSide(side)][8] = self:getSeedsInStore(side) + seeds
end

function Board:toString()
    local s = {}
    -- Loop over row
    for k,v in pairs(self.board) do
        for wells, _ in pairs(v) do
            table.insert(s, tostring(self.board[k][wells] .. "|"))
            if (k == 1 and  wells == 8) then
                table.insert(s, "\n")
            end
        end
    end

    return table.concat(s)
end

function Board:toShortString()
    local s = {}
    -- Loop over row
    for k,v in pairs(self.board) do
        for wells, _ in pairs(v) do
            if (k==2 and wells == 8) then
                table.insert(s, tostring(self.board[k][wells]))
            else
                table.insert(s, tostring(self.board[k][wells]..","))
            end
        end
    end

    return table.concat(s)
end

return Board