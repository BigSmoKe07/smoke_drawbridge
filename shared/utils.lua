local sharedConfig = require 'config.shared'

local utils = {}

---@param currentCoords vector3
---@param targetCoords vector3
---@param index number
---@return number
function utils.calculateTravelTime(currentCoords, targetCoords, index)
    local bridge = sharedConfig.bridges[index]
    local totalTime = bridge.movementDuration
    local currentDistance = #(currentCoords - targetCoords)
    local totalDistance = #(bridge.normalState - bridge.openState)
    local mod = (totalDistance - currentDistance) / totalDistance

    return totalTime - math.floor(totalTime * mod)
end

return utils