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
function Board:createBoard(holes, seeds)

    local o = {}
    setmetatable(o, self)
    self.__index = self
    self.holes = holes or 1
    self.seeds = seeds or 0
    self.board = {}
    for side=1,2 do
        -- Create Player Well
        self.board[side] = {}
        for well=1,holes do
            -- Add seed to player well
            self.board[side][well] = seeds
        end

    end

    return o
end

-- Method to deep copy board for agent manipulation
-- Taken from https://gist.github.com/tylerneylon/81333721109155b2d244#file-copy-lua-L50
function Board:copyBoard()
    if type(self) ~= 'table' then return self end
    -- Set the meta table for lookups to be the same as the copied object
    local res = setmetatable({}, getmetatable(self))
    -- Copy table elements to the agent's copy
    for k,v in pairs(self) do res[copyBoard(k)] = copyBoard(v) end
    return res

end



return Board