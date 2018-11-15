local protocol = require '../protocol'

describe('getMessageType', function()
    it('Returns START MESSAGE if message starts with START;', function()
        assert.equals(protocol.getMessageType("START;asdasdasd", "start"))
    end)
end)