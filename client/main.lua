local sharedConfig = require 'config.shared'
local math = lib.math
local bridgePoint

local SetEntityCoordsNoOffset = SetEntityCoordsNoOffset
local DoesEntityExist = DoesEntityExist
local IsControlJustPressed = IsControlJustPressed
local SetEntityRotation = SetEntityRotation
local GetEntityRotation = GetEntityRotation

local function rotateGate(entity, initialRotation, targetRotation)
    local lerp = math.lerp(initialRotation.y, targetRotation.y, 4000)
    while true do
        local y, step = lerp()
        SetEntityRotation(entity, initialRotation.x, y, initialRotation.z, 1, true)
        if step >= 1 then break end
        Wait(10)
    end
end

local function updateBarrierGateRotation(isOpen)
    local gates = sharedConfig.barrierGates
    local gateCount = #gates
    for i = 1, gateCount do
        local gate = gates[i]
        local entity = GetClosestObjectOfType(gate.coords.x, gate.coords.y, gate.coords.z, 2.0, gate.model, false, false, false)
        if entity ~= 0 then
            local currentRotation = GetEntityRotation(entity)
            local diff = currentRotation - gate.normalRot
            if #(diff) >= 1 then
                SetEntityRotation(entity, gate.normalRot.x, gate.normalRot.y, gate.normalRot.z, 1, true)
                currentRotation = gate.normalRot
            end
            local targetRotationY = isOpen and gate.maxRotationY or gate.minRotationY
            local targetRotation = vector3(currentRotation.x, currentRotation.y + targetRotationY, currentRotation.z)

            CreateThread(function()
                rotateGate(entity, currentRotation, targetRotation)
            end)
        end
    end
end

local function bridgeHandler()
    bridgePoint = lib.points.new({
        coords = vec3(280.7779, -2316.0391, 9.5852),
        distance = 1000,
        bridges = sharedConfig.bridges,
        speedZones = {}
    })

    function bridgePoint:onEnter()
        local bridges = self.bridges
        local bridgeCount = #bridges
        for i = 1, bridgeCount do
            local bridge = bridges[i]
            local model = bridge.hash
            -- lib.requestModel failded sometimes
            RequestModel(model)
            while not HasModelLoaded(model) do
                RequestModel(model)
                Wait(100)
            end
            local pos = bridge.normalState
            local ent = CreateObjectNoOffset(model, pos.x, pos.y, pos.z, false, false, false)
            SetEntityLodDist(ent, 3000)
            FreezeEntityPosition(ent, true)
            bridge.ent = ent
        end
    end

    function bridgePoint:onExit()
        local bridges = self.bridges
        local bridgeCount = #bridges
        for i = 1, bridgeCount do
            local ent = bridges[i].ent
            if DoesEntityExist(ent) then
                DeleteEntity(ent)
            end
        end
    end
end



---@diagnostic disable-next-line: param-type-mismatch
AddStateBagChangeHandler("pBrMeta", nil, function(_, _, bridgeMeta)
    local currentDistance = bridgePoint.currentDistance
    if not currentDistance or currentDistance > 850 then return end

    local bridges = bridgePoint.bridges
    local bridgeCount = #bridges
    local state = bridgeMeta.state
    local speedZones = bridgePoint.speedZones
    local blockingData = sharedConfig.blockArea

    for i = 1, bridgeCount do
        local ent = bridges[i].ent
        if DoesEntityExist(ent) then
            local bridgeData = bridgeMeta.cPos[i]
            SetEntityCoordsNoOffset(ent, bridgeData.x, bridgeData.y, bridgeData.z, false, false, false)
        end
    end
    if state and not next(speedZones) then
        for id = 1, #blockingData do
            local data = blockingData[id]
            speedZones[id] = AddRoadNodeSpeedZone(data.coords.x, data.coords.y, data.coords.z, data.size, 0.0, false)
        end
        updateBarrierGateRotation(state)
    elseif not state and next(speedZones) then
        for id = 1, #blockingData do
            if speedZones[id] then
                RemoveRoadNodeSpeedZone(speedZones[id])

                speedZones[id] = nil
            end
        end
        updateBarrierGateRotation(state)
    end
end)

local function createInteraction()
    local state = GetResourceState('ox_target')
    local oxTarget = state == 'started' or state == 'starting'
    local config = sharedConfig.HackBridge
    if oxTarget then
        exports.ox_target:addBoxZone({
            coords = config.coords,
            size = config.size,
            rotation = config.rotation,
            options = {
                label = 'Hack Bridge Control',
                icon = 'fas fa-code-branch',
                distance = 2.5,
                canInteract = function()
                    return not GlobalState.pBrMeta.state
                end,
                onSelect = function()
                    if config.minigame() then
                        TriggerServerEvent('smoke_drawbridge:server:hackBridge')
                    end
                end
            }
        })
    else
        local interact = lib.points.new({
            coords = config.coords,
            distance = 1.5,
        })

        function interact:nearby()
            print('Nearby')
            lib.showTextUI('[E] - Hack Module')
            if IsControlJustPressed(0, 38) then
                if config.minigame() then
                    TriggerServerEvent('smoke_drawbridge:server:hackBridge')
                end
            end
        end

        function interact:onExit()
            lib.hideTextUI()
        end
    end
end

CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(0) end
    Wait(5000) -- Wait for slow PCs
    bridgeHandler()
    if sharedConfig.HackBridge.enabled then
        createInteraction()
    end
end)
