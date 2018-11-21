protocol = require 'protocol'
board = require 'board'
moveTurn = require 'moveTurn'

local pl = require 'pl.pretty'

-- Define strings for testing
startStr    = "START;asdasd"
changeStr   = "CHANGE;asdasd"
endStr      = "END\n"

startSouth  = "START;South\n"
startNorth  = "START;North\n"

describe('getMessageType', function()
    it('returns \"start\" if message starts with START;', function()
        assert.equals(protocol.getMessageType(startStr), "start")
    end)

    it('returns \"end\" if message starts with END', function()
        assert.equals(protocol.getMessageType(endStr), "end")
    end)

    it('returns \"change\" if message starts with CHANGE;', function()
        assert.equals(protocol.getMessageType(changeStr), "state")
    end)

    it('returns nil if message is not recognized', function()
        assert.Nil(protocol.getMessageType("1337b00bs"))
    end)
end)

describe('createMoveMsg', function ()
    it('returns a valid move message', function()
        assert.are.equal(protocol.createMoveMsg(123), "MOVE;123\n")
    end)
end)

describe('createSwapMsg', function()
    it('returns a valid swap message', function()
        assert.are.equal(protocol.createSwapMsg(), "SWAP\n")
    end)
end)

describe('evaluateStartMsg', function()
    it('returns an error if the position is invalid', function()
        assert.Nil(protocol.evaluateStartMsg("START;1337\n"))
    end)

    it('returns nil if the message doesnt end correctly', function()
        assert.Nil(protocol.evaluateStartMsg("START;South"))
    end)

    it('returns true if the position is South', function()
        assert.True(protocol.evaluateStartMsg(startSouth))
    end)

    it('returns false if the position is North', function()
        assert.False(protocol.evaluateStartMsg(startNorth))
    end)
end)

-- INTEGRATION TESTS with board
describe('evaluateStateMsg', function()
    local incorrectEnd = "START;asd;asd;asd"
    local threeParts = "START;asd;asd\n"
    local boardParts14 = "1,1,1,1,1,1,1,1,1,1,1,1,1,1"
    local boardParts15 = "1,1,1,1,1,1,1,1,1,1,1,1,1,1,1"
    local correctMsg14 = "CHANGE;SWAP;" .. boardParts14 .. ";YOU\n"
    local correctMsg15 = "CHANGE;SWAP;" .. boardParts15 .. ";YOU\n"
    local correctMsg = "CHANGE;SWAP;" .. boardParts15 .. ";"

    -- Mock the board
    local mockBoard = board:new(7,7)

    it('returns nil if the message doesnt end correctly', function()
        assert.Nil(protocol.evaluateStateMsg(incorrectEnd, nil))
    end)

    it('returns nil if the message doesnt have 4 parts', function()
        assert.Nil(protocol.evaluateStateMsg(threeParts, nil))
    end)

    it('returns board error if the board dimensions dont match', function()
        -- assert.spy(mockBoard.getNoOfHoles).was.called()
        assert.Nil(protocol.evaluateStateMsg(correctMsg14, mockBoard))
    end)

    it('returns a mt if everything is OK and its your turn', function()
        mt = moveTurn:new(nil)
        mt.move = -1
        mt.endMove = false
        mt.again = true

        assert.are.same(mt, protocol.evaluateStateMsg(correctMsg15, mockBoard))
    end)

    it('returns a mt if everything is OK and its OPPs turn', function()
        mt = moveTurn:new(nil)
        mt.move = -1
        mt.endMove = false
        mt.again = false

        assert.are.same(mt, protocol.evaluateStateMsg(correctMsg .. "OPP\n", mockBoard))
    end)

    it('returns a mt if everything is OK and its end of the game', function()
        mt = moveTurn:new(nil)
        mt.move = -1
        mt.endMove = true
        mt.again = false

        assert.are.same(mt, protocol.evaluateStateMsg(correctMsg .. "END\n", mockBoard))
    end)

    it('returns nil if turn not recognised', function()
        assert.Nil(mt, protocol.evaluateStateMsg(correctMsg .. "1337", mockBoard))
    end)

end)

