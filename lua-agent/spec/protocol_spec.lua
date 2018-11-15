protocol = require 'protocol'

-- Define strings for testing
startStr    = "START;asdasd"
changeStr   = "CHANGE;asdasd"
endStr      = "END\n"

describe('getMessageType', function()
    it('returns \"start\" if message starts with START;', function()
        assert.equals(protocol.getMessageType(startStr), "start")
    end)

    it('returns \"end\" if message starts with END', function()
        assert.equals(protocol.getMessageType(endStr), "end")
    end)

    it('returns \"change\" if message starts with CHANGE;', function()
        assert.equals(protocol.getMessageType(changeStr), "change")
    end)
end)

describe('createMoveMsg', function ()
    it('returns a valid move message', function()
        assert.equals(protocol.createMoveMsg(123), "MOVE;123\n")
    end)
end)