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
Board = {NORTH_ROW = 1, SOUTH_ROW = 2, holes=1, seeds=0}

Board.__index = Board

function Board:indexOfSide(side)
    -- Not sure if we should be using a string here
    if (side == "NORTH") then
        return self.NORTH_ROW
    else
        return self.SOUTH_ROW
    end
end

-- Board can be created with or without specifying any of the parameters
function Board:new(holes, seeds)

    local o = {}
    setmetatable(o, self)
    self.__index = self
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

    return o
end

-- Method to deep copy board for agent manipulation
-- Taken from https://gist.github.com/tylerneylon/81333721109155b2d244#file-copy-lua-L50
function Board:copyBoard(obj)
    if type(obj) ~= 'table' then return obj end
    -- Set the meta table for lookups to be the same as the copied object
    local res = setmetatable({}, getmetatable(obj))
    -- Copy table elements to the agent's copy
    for k,v in pairs(obj) do res[copyBoard(k)] = copyBoard(v) end
    return res

end

function Board:getNoOfHoles()
    return self.holes
end

function Board:getSeeds(side, hole)
    return self.board[self:indexOfSide(side)][hole]
end

function Board:setSeeds(side, hole, seeds)
    self.board[self:indexOfSide(side)][hole] = seeds
end

function Board:addSeeds(side, hole, seeds)
    self.board[self:indexOfSide(side)][hole] = self:getSeeds(side, hole) + seeds
end

function Board:getSeedsOp(side, hole)
    if (side == "NORTH") then return self.board[2][self.holes+1-hole]
    else return self.board[1][self.holes+1-hole] end
end

function Board:setSeedsOp(side, hole, seeds)
    if (side == "NORTH") then self.board[2][self.holes+1-hole] = seeds
    else self.board[1][self.holes+1-hole] = seeds end
end

-- TODO this function's logic seems a bit dodgy to me, hopefully tests catch it if it is
function Board:addSeedsOp(side, hole, seeds)
    if (side == "NORTH") then self.board[2][self.holes+1-hole] = self:getSeedsOp(side, hole) + seeds
    else self.board[1][self.holes+1-hole] = self:getSeedsOp(side, hole) + seeds end
end

function Board:getSeedsInStore(side)
    return self.board[self:indexOfSide(side)][8]
end

function Board:setSeedsInStore(side, seeds)
    self.board[self:indexOfSide(side)][8] = seeds
end

function Board:addSeedsToStore(side, seeds)
    self.board[self:indexOfSide(side)][8] = self:getSeeds(side, 8) + seeds
end

function Board:toString()
    -- Loop over row
    for k,v in pairs(self.board) do
        for wells, _ in pairs(v) do
            io.write(self.board[k][wells] .. " | ")
            if (k == 1 and  wells == 8) then
                io.write("\n")
            end
        end
    end
end

return Board