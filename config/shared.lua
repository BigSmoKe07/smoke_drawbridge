local minutes = 60 * 1000

return {
    bridges = {
        {
            hash = `car_drawbridge`,
            normalState = vec3(353.3317, -2315.838, 13.75),
            openState = vec3(353.3317, -2315.838, 42.00),
            movementDuration = 5 * minutes,
            blockAreas = {
                {
                    coords = vec3(347.7381, -2273.5859, 10.1941),
                    size = 10.0,
                },
                {
                    coords = vec3(358.786, -2352.276, 10.186),
                    size = 10.0,
                }
            },
            hackBridge = {
                enabled = true,
                interact = 'ox_target', -- 'ox_target' or 'textUI' uses ox_lib
                coords = vec3(366.15, -2346.95, 10.6),
                radius = 0.6,
                item = {          -- optional item NOTE: This feature will only work if you have ox_inventory
                    name = false, -- item name or false to disable
                    remove = true
                },
                minigame = function()
                    return lib.skillCheck({ { areaSize = 20, speedMultiplier = 0.1 }, { areaSize = 10, speedMultiplier = 0.1 }, { areaSize = 25, speedMultiplier = 0.1 } })
                end
            }
        },
        {
            hash = `train_drawbridge`,
            normalState = vec3(219.5085, -2319.432, 13.25),
            openState = vec3(219.5085, -2319.432, 42.00),
            movementDuration = 5 * minutes,
            hackBridge = {
                enabled = true,
                interact = 'ox_target', -- 'ox_target' or 'textUI' uses ox_lib
                coords = vec3(211.6990, -2347.2209, 69.1732),
                radius = 0.6,
                item = {          -- optional item NOTE: This feature will only work if you have ox_inventory
                    name = false, -- item name or false to disable
                    remove = false
                },
                minigame = function()
                    return lib.skillCheck({ { areaSize = 20, speedMultiplier = 0.1 }, { areaSize = 10, speedMultiplier = 0.1 }, { areaSize = 25, speedMultiplier = 0.1 } })
                end
            }
        }
    },
    barrierGates = {
        {
            model = `prop_bridge_barrier_gate_01x`,
            coords = vec3(364.69, -2343.68, 11.39),
            closed = vec3(0.0, 0.0, 0.0),
            open = vec3(0.0, -90.0, 0.0),
        },
        {
            model = `prop_bridge_barrier_gate_01x`,
            coords = vec3(342.04, -2343.55, 11.46),
            closed = vec3(0.0, 0.0, 0),
            open = vec3(0.0, 90.0, 0.0),
        },

        {
            model = `prop_bridge_barrier_gate_01x`,
            coords = vec3(364.71, -2288.3, 11.36),
            closed = vec3(0.0, 0.0, 0.0),
            open = vec3(0.0, -90.0, 0.0),
        },
        {
            model = `prop_bridge_barrier_gate_01x`,
            coords = vec3(342.11, -2288.01, 11.30),
            closed = vec3(0.0, 0.0, 0.0),
            open = vec3(0.0, 90.0, 0.0),
        }
    }
}
