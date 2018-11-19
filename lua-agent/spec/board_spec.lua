--
-- Created by IntelliJ IDEA.
-- User: aayushchadha
-- Date: 19/11/18
-- Time: 20:02
-- To change this template use File | Settings | File Templates.
--

board = require 'board'

northSideString = "NORTH"
southSideString = "SOUTH"


testBoard = board:createBoard(7,7)

-- This shouldn't effect execution since the object is instantiated.
board = nil

describe('indexOfSide', function()
    it('returns 1 if the side is north', function()
        assert.equals(testBoard:indexOfSide(northSideString), 1)
    end)

    it('returns 2 if the side is south', function()
        assert.equals(testBoard:indexOfSide(southSideString), 2)
    end)
end)


describe('createBoard', function()
    it('should create a new board with 7 seeds', function()
        assert.equals(testBoard.seeds, 7)
    end)

    it('should create a new board with 7 holes', function()
        assert.equals(testBoard.holes, 7)
    end)

    it('should allow access to a well on north side', function()
        assert.equals(testBoard.board[1][2], 7)
    end)

    it('should allow access to a well on the south side', function()
        assert.equals(testBoard.board[2][7], 7)
    end)
end)





