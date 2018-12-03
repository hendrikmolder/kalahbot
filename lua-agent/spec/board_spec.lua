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


testBoard = board:new(nil, 7,7)
agentTestBoard = testBoard:copyBoard(testBoard)

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

describe('copyBoard', function()
    it('should create a copied board with 7 seeds', function()
        assert.equals(agentTestBoard.seeds, 7)
    end)

    it('should create a copied board with 7 holes', function()
        assert.equals(agentTestBoard.holes, 7)
    end)

    it('should allow access to a copied well on north side', function()
        assert.equals(agentTestBoard.board[1][2], 7)
    end)

    it('should allow access to a copied well on the south side', function()
        assert.equals(agentTestBoard.board[2][7], 7)
    end)
end)

describe('getNoOfHoles', function()
    it('returns number of holes per side', function()
        assert.equals(testBoard:getNoOfHoles(), 7)
    end)
end)

describe('getSeeds', function()
    it('returns seeds in a hole', function ()
        assert.equals(testBoard:getSeeds(northSideString, 4), 7)
    end)
end)

describe('setSeeds', function()
    it('sets the seeds on a specified side and hole', function()
        testBoard:setSeeds(northSideString, 4, 3)
        assert.equals(testBoard:getSeeds(northSideString, 4), 3)
    end)
end)

describe('addSeeds', function ()
    it('adds the number of seeds in a given well', function()
        testBoard:addSeeds(southSideString, 5, 4)
        assert.equals(testBoard:getSeeds(southSideString, 5), 11)
    end)
end)

describe('getSeedsOp', function()
    it('returns the seeds opposite to a north well', function()
        assert.equals(testBoard:getSeedsOp(northSideString, 1), 7)
    end)

    it('returns the seeds opposite to a south well', function()
        testBoard:setSeeds(northSideString, 3, 1)
        assert.equals(testBoard:getSeedsOp(southSideString, 5), 1)
    end)
end)

describe('setSeedsOp', function()
    it('sets the seeds in the opposite (south) well', function()
        testBoard:setSeedsOp(northSideString, 3, 1)
        assert.equals(testBoard:getSeedsOp(northSideString, 3), 1)
    end)

    it('sets the seeds in the opposite (north) well', function()
        testBoard:setSeedsOp(southSideString, 2, 1)
        assert.equals(testBoard:getSeedsOp(southSideString, 2), 1)
    end)
end)

describe('addSeedsOp', function()
    it('adds seeds to the opposite (north) well', function ()
        testBoard:addSeedsOp(northSideString, 3, 2)
        assert.equals(testBoard:getSeedsOp(northSideString, 3), 3)
    end)

    it('adds seeds to the opposite (south) well', function ()
        testBoard:addSeedsOp(southSideString, 2, 2)
        assert.equals(testBoard:getSeedsOp(southSideString, 2), 3)
    end)

end)

describe('getSeedsInStore', function()
    it('returns the seeds in the north scoring well', function ()
        assert.equals(testBoard:getSeedsInStore(northSideString), 0)
    end)

    it('returns the seeds in the south scoring well', function ()
        assert.equals(testBoard:getSeedsInStore(northSideString), 0)
    end)

end)

describe('setSeedsInStore', function()
    it('sets the seeds in the north scoring well', function ()
        testBoard:setSeedsInStore(northSideString, 11)
        assert.equals(testBoard:getSeedsInStore(northSideString), 11)
    end)

    it('sets the seeds in the south scoring well', function ()
        testBoard:setSeedsInStore(southSideString, 11)
        assert.equals(testBoard:getSeedsInStore(northSideString), 11)
    end)
end)

describe('addSeedsToStore', function()
    it('adds seeds to the north scoring well', function ()
        testBoard:addSeedsToStore(northSideString, 2)
        assert.equals(testBoard:getSeedsInStore(northSideString), 13)
    end)

    it('adds seeds to the south scoring well', function ()
        testBoard:addSeedsToStore(southSideString, 2)
        assert.equals(testBoard:getSeedsInStore(southSideString), 13)
    end)
end)




