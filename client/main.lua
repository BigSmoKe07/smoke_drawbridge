local sharedConfig = require 'config.shared'
local utils = require 'shared.utils'
local bridgeEntities = {}
local speedZones = {}
local bridgeStates = {}

local SetEntityCoordsNoOffset = SetEntityCoordsNoOffset
local DoesEntityExist = DoesEntityExist
local IsControlJustPressed = IsControlJustPressed
local SetEntityRotation = SetEntityRotation
local GetEntityRotation = GetEntityRotation

---@param state boolean
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

---@param index number
---@param state boolean
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

---@param index number
local function openBridge(index)
    local bridge = sharedConfig.bridges[index]
    local entity = bridgeEntities[index]

    if not DoesEntityExist(entity) then
        return
    end

    bridgeStates[index] = true

    local currentCoords = GetEntityCoords(entity)
    local timeNeeded = utils.calculateTravelTime(currentCoords, bridge.openState, index)

    toggleBarriers(true)
    toggleBlockAreas(index, true)

    for interpolated in lib.math.lerp(GetEntityCoords(entity), bridge.openState, timeNeeded) do
        SetEntityCoordsNoOffset(entity, interpolated.x, interpolated.y, interpolated.z, false, false, false)
    end

    bridgeStates[index] = false
end

---@param index number
local function closeBridge(index)
    local bridge = sharedConfig.bridges[index]
    local entity = bridgeEntities[index]

    if not DoesEntityExist(entity) then return end

    local currentCoords = GetEntityCoords(entity)
    local timeNeeded = utils.calculateTravelTime(currentCoords, bridge.normalState, index)

    bridgeStates[index] = true

    for interpolated in lib.math.lerp(currentCoords, bridge.normalState, timeNeeded) do
        SetEntityCoordsNoOffset(entity, interpolated.x, interpolated.y, interpolated.z, false, false, false)
    end

    toggleBarriers(false)
    toggleBlockAreas(index, false)
    bridgeStates[index] = false
end

---@param index number
local function spawnBridge(index)
    local bridge = sharedConfig.bridges[index]
    local model = bridge.hash

    lib.requestModel(model)

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

---@param index number
local function destroyBridge(index)
    if DoesEntityExist(bridgeEntities[index]) then
        DeleteEntity(bridgeEntities[index])
    end

    toggleBarriers(false)
    toggleBlockAreas(index, false)

    bridgeEntities[index] = nil
    bridgeStates[index] = false
end

---@param config table
---@param index number
local function hackBridge(config, index)
    if config.item?.name and config.item?.removeItem then
        local success = lib.callback.await('smoke_drawbridge:server:removeItem', 200, index)
        if not success then return end
    end

	TaskTurnPedToFaceCoord(cache.ped, config.coords.x, config.coords.y, config.coords.z, 4000)
	Wait(500)

    lib.playAnim(cache.ped, 'mp_common_heist', 'pick_door', 8.0, -8.0, -1, 1)

    if config.minigame() then
        TriggerServerEvent('smoke_drawbridge:server:hackBridge', index)
    else
        lib.notify({ type = 'error', description = locale('failed_hack_bridge') })
    end

	StopEntityAnim(cache.ped, 'pick_door', 'mp_common_heist', 0)
	RemoveAnimDict('mp_common_heist')
end

---@param index number
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
                hackBridge(config, index)
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
                items = config.item?.name or nil,
                onSelect = function()
                    hackBridge(config, index)
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
