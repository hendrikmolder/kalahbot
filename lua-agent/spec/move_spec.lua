local Move = require 'move'

describe('getSide', function()
    local m = Move:new(nil, 1, 2)
    it('returns side', function()
        assert.are_equal(1, m:getSide())
    end)
end)

describe('getHole', function()
    local m = Move:new(nil, 1, 2)
    it('returns hole', function()
        assert.are_equal(2, m:getHole())
    end)
end)

describe('new', function()
    local m = Move:new(nil, 1, 2)
    it('creates new move', function()
        assert.are_equal(1, m.side)
        assert.are_equal(2, m.hole)
    end)
end)