UCT = {}

local MAX_VALUE = math.huge

function UCT.uctValue(totalVisit, nodeWinScore, nodeVisit)
    if (nodeVisit == 0) then return math.huge end

    return (nodeWinScore / nodeVisit) + 1.41 * math.sqrt(math.log(totalVisit) / nodeVisit)
end

function UCT.findBestNodeWithUCT(node)
    local parentVisit = node:getState():evaluate() --TODO

    -- TODO convert this code
    -- Comparator.comparing(c -> uctValue(parentVisit,
    --         c.getState().getWinScore(), c.getState().getVisitCount())));
end

return UCT