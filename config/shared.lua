return {
    bridges = {
        {
            hash = 3685260158,
            normalState = vec3(353.3317, -2315.838, 13.75),
            openState = vec3(353.3317, -2315.838, 42.00)
        },
        {
            hash = 4287851603,
            normalState = vec3(219.5085, -2319.432, 13.25),
            openState = vec3(219.5085, -2319.432, 42.00)
        }
    },
    blockArea = {
        {
            coords = vec3(347.376, -2279.668, 10.184),
            size = 10.0,
        },
        {
            coords = vec3(358.786, -2352.276, 10.186),
            size = 10.0,
        }
    },
    --- Enables players to hack the bridge
    --- You can chance the minigame in client/main.lua
    HackBridge = {
        enabled = true,
        coords = vec3(366.11, -2346.96, 10.5),
        size = vec3(0.5, 0.75, 2.0),
        rotation = 0.0,
        model = `prop_elecbox_01a`,
        cooldown = 60 * 60000, -- 60 minutes
    },
    barrierGates = {
        {
            model = `prop_bridge_barrier_gate_01x`,
            coords = vec3(364.69915771484377, -2343.686279296875, 11.39140605926513),
            normalRot = vec3(0.000000, -0.000000, -0.000010),
            minRotationY = 90,
            maxRotationY = -90,
            rotationX = 180
        },
        {
            model = `prop_bridge_barrier_gate_01x`,
            coords = vec3(342.0478515625, -2343.5517578125, 11.46424674987793),
            normalRot = vec3(0.000000, -0.000000, 179.999985),
            minRotationY = -90,
            maxRotationY = 90,
            rotationX = 0
        },
        {
            model = `prop_bridge_barrier_gate_01x`,
            coords = vec3(364.7115478515625, -2288.304443359375, 11.36281585693359),
            normalRot = vec3(0.000000, -0.000000, -0.000010),
            minRotationY = 90,
            maxRotationY = -90,
            rotationX = 180
        },
        {
            model = `prop_bridge_barrier_gate_01x`,
            coords = vec3(342.1158447265625, -2288.013671875, 11.30535125732421),
            normalRot = vec3(0.000000, -0.000000, 179.999985),
            minRotationY = -90,
            maxRotationY = 90,
            rotationX = 0
        }
    }
}
