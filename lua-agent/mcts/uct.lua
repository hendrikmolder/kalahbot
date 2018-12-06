UCT = {}

local MAX_VALUE = math.huge

function UCT.uctValue(totalVisit, nodeWinScore, nodevisit)
    if (nodeVisit == 0) then return math.huge end

    return (nodeWinScore / nodeVisit) + 1.41 * math.sqrt(math.log(totalVisit) / nodeVisit)
end

function UCT.findBestNodeWithUCT(node)

end

return UCT