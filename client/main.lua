local sharedConfig = require 'config.shared'
local math = lib.math
local bridgeEntities = {}
local speedZones = {}
local bridgeStates = {}

local SetEntityCoordsNoOffset = SetEntityCoordsNoOffset
local DoesEntityExist = DoesEntityExist
local IsControlJustPressed = IsControlJustPressed
local SetEntityRotation = SetEntityRotation
local GetEntityRotation = GetEntityRotation

local function toggleBarriers(state)
    for i = 1, #sharedConfig.barrierGates do
        CreateThread(function()
            local barrier = sharedConfig.barrierGates[i]
            local entity = GetClosestObjectOfType(barrier.coords.x, barrier.coords.y, barrier.coords.z, 2.0,
                barrier.model, false, false, false)
            if entity ~= 0 then
                local current = GetEntityRotation(entity)
                local target = (state and barrier.open) or barrier.closed

                for interpolated in lib.math.lerp(current, target, 3000) do
                    SetEntityRotation(entity, interpolated.x, interpolated.y, interpolated.z, 1, true)
                end
            end
        end)
    end
end

local function toggleBlockAreas(index, state)
    if state then
        local blockAreas = sharedConfig.bridges[index].blockAreas

        if not blockAreas then return end

        speedZones[index] = speedZones[index] or {}
        for i = 1, #blockAreas do
            if not speedZones[index][i] then
                local data = blockAreas[i]
                speedZones[index][i] = AddRoadNodeSpeedZone(data.coords.x, data.coords.y, data.coords.z, data.size, 0.0,
                    false)
            end
        end
    else
        if speedZones[index] then
            for i = #speedZones[index], 1, -1 do
                local zone = table.remove(speedZones[index], i)
                RemoveRoadNodeSpeedZone(zone)
            end
        end
    end
end

local function calculateTravelTime(currentCoords, targetCoords, index)
    local bridge = sharedConfig.bridges[index]
    local totalTime = bridge.movementDuration
    local currentDistance = #(currentCoords - targetCoords)
    local totalDistance = #(bridge.normalState - bridge.openState)
    local mod = (totalDistance - currentDistance) / totalDistance

    return totalTime - math.floor(totalTime * mod)
end

local function openBridge(index)
    local bridge = sharedConfig.bridges[index]
    local entity = bridgeEntities[index]

    if not DoesEntityExist(entity) then
        return
    end

    bridgeStates[index] = true

    local currentCoords = GetEntityCoords(entity)
    local timeNeeded = calculateTravelTime(currentCoords, bridge.openState, index)

    toggleBarriers(true)
    toggleBlockAreas(index, true)

    for interpolated in lib.math.lerp(GetEntityCoords(entity), bridge.openState, timeNeeded) do
        SetEntityCoordsNoOffset(entity, interpolated.x, interpolated.y, interpolated.z, false, false, false)
    end

    bridgeStates[index] = false
end

local function closeBridge(index)
    local bridge = sharedConfig.bridges[index]
    local entity = bridgeEntities[index]

    if not DoesEntityExist(entity) then return end

    local currentCoords = GetEntityCoords(entity)
    local timeNeeded = calculateTravelTime(currentCoords, bridge.normalState, index)

    bridgeStates[index] = true

    for interpolated in lib.math.lerp(currentCoords, bridge.normalState, timeNeeded) do
        SetEntityCoordsNoOffset(entity, interpolated.x, interpolated.y, interpolated.z, false, false, false)
    end

    toggleBarriers(false)
    toggleBlockAreas(index, false)
    bridgeStates[index] = false
end

local function spawnBridge(index)
    local bridge = sharedConfig.bridges[index]
    local model = bridge.hash

    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(100)
    end

    local pos = GlobalState['bridges:coords:' .. index]
    local ent = CreateObjectNoOffset(model, pos.x, pos.y, pos.z, false, false, false)
    SetEntityLodDist(ent, 3000)
    FreezeEntityPosition(ent, true)
    bridgeEntities[index] = ent

    if GlobalState['bridges:state:' .. index] then
        openBridge(index)
    else
        closeBridge(index)
    end
end

local function destroyBridge(index)
    if DoesEntityExist(bridgeEntities[index]) then
        DeleteEntity(bridgeEntities[index])
    end
    toggleBarriers(false)
    toggleBlockAreas(index, false)
    bridgeEntities[index] = nil
    bridgeStates[index] = false
end

local function createInteraction(index)
    local config = sharedConfig.bridges[index].hackBridge
    local type = config.interact
    if type == 'textUI' then
        local interact = lib.points.new({
            coords = config.coords,
            distance = 1.5,
        })

        function interact:nearby()
            if GlobalState['bridges:cooldown:' .. index] then return end

            lib.showTextUI(('[E] - %s'):format(locale('hack_bridge')))
            if IsControlJustPressed(0, 38) then
                if config.minigame() then
                    TriggerServerEvent('smoke_drawbridge:server:hackBridge', index)
                end
            end
        end

        function interact:onExit()
            lib.hideTextUI()
        end
    elseif type == 'ox_target' then
        exports.ox_target:addSphereZone({
            name = 'bridge:interact' .. index,
            coords = config.coords,
            radius = config.radius,
            options = {
                label = locale('hack_bridge'),
                icon = 'fa-solid fa-code-branch',
                distance = 2.5,
                canInteract = function()
                    return not GlobalState['bridges:cooldown:' .. index]
                end,
                onSelect = function()
                    if config.minigame() then
                        TriggerServerEvent('smoke_drawbridge:server:hackBridge', index)
                    end
                end
            }
        })
    end
end

CreateThread(function()
    for i = 1, #sharedConfig.bridges do
        local coords = sharedConfig.bridges[i].normalState

        local point = lib.points.new({
            coords = coords,
            distance = 850,
        })

        function point:onEnter()
            spawnBridge(i)
        end

        function point:onExit()
            destroyBridge(i)
        end

        local config = sharedConfig.bridges[i].hackBridge
        if config.enabled then
            createInteraction(i)
        end
    end
end)

CreateThread(function()
    for index = 1, #sharedConfig.bridges do
        ---@diagnostic disable-next-line: param-type-mismatch
        AddStateBagChangeHandler('bridges:state:' .. index, nil, function(_, _, state)
            if not bridgeStates[index] then
                if state then
                    openBridge(index)
                else
                    closeBridge(index)
                end
            end
        end)
    end
end)
