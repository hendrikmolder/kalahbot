Board = require 'board'

local Kalah = {}
local board = Board:new(7, 7)

function Kalah.getBoard()
    return board
end

-- Checks whether a given move is legal on a given board.
-- NB! No moves are actually made.
function Kalah.isLegalMove(board, move)
    return (move.getHole() <= board.getNoOfHoles()) 
        and (board.getSeeds(move.getSide(), move.getHole()) ~= 0)
end

function Kalah.makeMove(move)
    return true
end

-- Checks whether all holes are empty
function Kalah.holesEmpty(board, side)
    for hole=1,board.getNoOfHoles() do
        if (board.getSeeds(side, hole) ~= 0) then return false end
        return true
    end
end

-- Checks whether the game is over (based on the board)
function gameOver(board)
    return holesEmpty(board, "NORTH") or holesEmpty(board, "SOUTH")
end

return Kalah