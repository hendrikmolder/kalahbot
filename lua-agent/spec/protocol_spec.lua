protocol = require 'protocol'

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
        assert.equals(protocol.createMoveMsg(123), "MOVE;123\n")
    end)
end)

describe('createSwapMsg', function()
    it('returns a valid swap message', function()
        assert.equals(protocol.createSwapMsg(), "SWAP\n")
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

