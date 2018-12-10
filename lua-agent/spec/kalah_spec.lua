board = require 'board'
Side = require 'side'
Kalah = require 'kalah'
Log = require 'log'

describe('makeMove', function()
    it('makes a move as per the game rules on the North Side', function()
        local boardCopy = board:new(7,7)
        local dummyMove = Move:new(nil, Side.NORTH, 1);
        local state = Kalah:new(boardCopy, Side.NORTH, Side.NORTH)
        local nextTurn = state:makeMove(boardCopy, dummyMove)
        -- First hole should have zero seeds
        assert.equals(boardCopy:getSeeds(Side.NORTH, 1), 0)
--        for hole=2,7 do
--            assert.equals(boardCopy.getSeeds(Side.NORTH, hole), 8)
--        end
        -- Since we end up in the store, we should get an additional turn at the end
        assert.equals(nextTurn, 1)
    end)
end)