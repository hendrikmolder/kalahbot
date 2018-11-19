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

return Board