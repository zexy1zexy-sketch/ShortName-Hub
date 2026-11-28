# ShortName FE Admin (Standalone)

This branch is independent of the ShortName Hub loader and its module tree.

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/zexy1zexy-sketch/ShortName-Hub/fe-admin-standalone/FE-Admin/Main.lua"))()
```

## Scope

This initial build is a client-side utility console. Commands alter the local client's character, camera, and lighting where Roblox permits. They do not grant server authority, change other players' server state, or bypass game permissions. Client-side changes may be corrected by the server and may not replicate to other players.

## Commands

Use `;help` in the console. The command prefix is `;`.

Initial commands include help, clear, walkspeed, jumppower, hipheight, sit, stand, reset, fov, time, brightness, fullbright, fog, goto/tp, view, unview, coords, players, count, hideui, showui, and rejoin.

## Development

The branch is named `fe-admin-standalone`. It is intentionally separate from `main`; no ShortName Hub loader or Main.lua is modified.
