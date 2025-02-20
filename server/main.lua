local sharedConfig = require 'config.shared'
local config = require 'config.server'
local math = lib.math

GlobalState.pBrMeta = {
    state = false,
    cPos = { false, false },
}

local duration = config.bridgeSettings.movementDuration
local function moveEntity(currentState)
    CreateThread(function()
        local interpolators = {}
        local bridgeCount = #sharedConfig.bridges
        local positions = {}
        local GlobalState = GlobalState

        for i = 1, bridgeCount do
            local bridge = sharedConfig.bridges[i]
            local from = currentState and bridge.openState or bridge.normalState
            local to = currentState and bridge.normalState or bridge.openState
            interpolators[i] = math.lerp(from, to, duration)
        end
        local targetState = not currentState
        currentState = currentState or true
        while true do
            local allFinished = true
            for i = 1, bridgeCount do
                local pos, step = interpolators[i]()
                positions[i] = pos
                if step < 1 then
                    allFinished = false
                end
            end
            GlobalState.pBrMeta = {
                state = currentState,
                cPos = positions,
            }
            if allFinished then break end
            Wait(500)
        end
        if targetState then
            SetTimeout(config.bridgeSettings.timeout, function()
                moveEntity(true)
            end)
        end
        GlobalState.pBrMeta = {
            state = targetState,
            cPos = positions,
        }
    end)
end

local function openBridges()
    local currentState = GlobalState.pBrMeta.state
    if not currentState then
        moveEntity(currentState)
    end
end

---@diagnostic disable-next-line: undefined-global
SetInterval(function()
    if not GlobalState.pBrMeta.state and math.random(1, 100) <= config.bridgeSettings.chance then
        openBridges()
    end
end, config.bridgeSettings.interval)

RegisterNetEvent('smoke_drawbridge:server:hackBridge', function()
    local coords = GetEntityCoords(GetPlayerPed(source))
    local distance = #(coords - sharedConfig.HackBridge.coords)
    if distance > 3 then return end
    openBridges()
end)

if config.enableCommands then
    lib.addCommand('portbridges', {
        help = 'Open or view status of bridge',
        params = {
            {
                name = 'state',
                type = 'string',
                help = 'open / status',
            }
        },
        restricted = 'group.admin'
    }, function(source, args)
        if args.state == 'open' then
            openBridges()
        elseif args.state == 'status' then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Smoke Bridge',
                description = 'The bridge is currently ' .. (GlobalState.pBrMeta.state and 'open' or 'closed'),
                type = 'success'
            })
        else
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Smoke Bridge',
                description = 'Invalid state',
                type = 'error'
            })
        end
    end)
end

-- Exports 
exports('openPortBridges', openBridges)