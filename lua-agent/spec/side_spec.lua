--
-- Created by IntelliJ IDEA.
-- User: aayushchadha
-- Date: 28/11/18
-- Time: 02:59
-- To change this template use File | Settings | File Templates.
--

Side = require 'side'

testSide = Side

describe('getOppositeSide', function()
    it ('should return the default side', function ()
        assert.equals(testSide:getOpposite(testSide.SOUTH), 1)
    end)

    it('should return the south side', function ()
        assert.equals(testSide:getOpposite(testSide.NORTH), 2)
    end)
end)
