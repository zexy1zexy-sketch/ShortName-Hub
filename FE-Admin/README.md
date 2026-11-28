# ShortName FE Admin — Standalone

This project lives on the `fe-admin-standalone` branch and is independent of the ShortName Hub loader and module tree. Nothing in `main` is changed by this branch.

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/zexy1zexy-sketch/ShortName-Hub/fe-admin-standalone/FE-Admin/Main.lua"))()
```

## Interface

- Draggable ShortName-themed console
- Close button and RightCtrl visibility toggle
- Command terminal with scrolling output
- `;help` command directory and `;help <word>` search
- Up to 100 recent commands retained in the current session
- Error handling around command execution
- Notifications on startup

## Command groups

- Character: WalkSpeed, JumpPower, HipHeight, sit/stand, jump, reset, health and movement information
- Camera: FOV, camera subject, first/third person, zoom limits, mouse lock
- Player information: player list, name search, account details, team, distance and character information
- Lighting: time presets, brightness, fog, ambient colors, shadows and restore
- World/client properties: local gravity property and position information
- Session: PlaceId, JobId, session duration, ping estimate, rejoin
- Interface: help, history, clear, minimize, restore, notification and reset commands

## Important limits

This is an executor-side **client utility**, not a server admin backdoor. It cannot grant server permissions, kick/ban other players, change other players' server-owned properties, or bypass a game's server validation. Local property changes can be overwritten by the server and may not replicate. For real FE moderation/admin powers, the game owner must install server-side scripts and authorize user IDs in their own Roblox experience.

## Branch

`fe-admin-standalone`

The main hub branch is not modified.