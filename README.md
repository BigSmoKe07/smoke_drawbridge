# [Smoke DrawBridge](https://forum.cfx.re/t/map-script-functional-lift-bridges-at-port/5307670)
## Overview
This combination map and script adds fully operational vertical-lift capabilities for the vehicle and rail draw bridges near the Port of Los Santos. 

## Preview
[![preview](https://r2.fivemanage.com/XMCfCRidUHgGkyCuAga9N/image/smoke_drawbridge.jpg)](https://youtu.be/F9RSTJJ-MkA?si=BhVEXrFCTQivnxY-)
### Features
- Bridge prop is server-synced for all players 
- Dynamically triggers at intervals
- Allows player interaction for manual operation

### Dependencies
- [onesync](https://docs.fivem.net/docs/scripting-reference/onesync/)
- [ox_lib](https://github.com/overextended/ox_lib/releases)
- [ox_inventory](https://github.com/overextended/ox_inventory/releases) *(Optional dependency for item-based hacking)*

### Installation
Not much hassle, just drag and drop into your server's resources folder.

## Support
Need help or want to chat? Join our community on Discord: 

[![Discord Banner 2](https://discord.com/api/guilds/1166449313824653393/widget.png?style=banner3)](https://discord.gg/vC9ETrNta2)

## Credits
[PNWParksFan](https://parksmods.com/donate/) - bridge models

[DemiAutomatic](https://github.com/DemiAutomatic) - major rewrite in bridge movement

## Video Credits
[![Discord Banner 2](https://discord.com/api/guilds/1341623000579051520/widget.png?style=banner2)](https://discord.gg/U9y5DAxwH3)


# Export Usage

## `exports.smoke_drawbridge:toggleBridge(index, state)`

Controls the state of a bridge based on its index.

### Parameters
- **`index`** (`integer`)
  - The index of the bridge from the configuration (`config/shared.bridges`).
- **`state`** (`boolean`, optional)
  - The target state for the bridge:
    - `true`: Opens the bridge.
    - `false`: Closes the bridge (default if not specified).

### Description

Toggles the specified bridge. Pass `true` explicitly to open; `false` or omitting `state` closes it.

### Example
```lua
-- Open bridge at index 1
exports.smoke_drawbridge:toggleBridge(1, true)

-- Close bridge at index 2
exports.smoke_drawbridge:toggleBridge(2)
```
