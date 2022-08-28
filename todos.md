# TODOs

## General

- camera system
- UI
- netplay
- combat
- terrain generation

## Features
- player or some enemies avoid other enemies ? (how? implement a second astar whose coefs are dynamic)

## Future ideas
- some enemies are heavier
- player is heavier when idle ? player's mass may be a gameplay thing (some stuff gives more mass)

## Bugs (most recently observed first)
- bug :
    - now that we do not add all points, some points are missed
    - player's path should be updated eg once every sec
- in 105344c6030d099ea53bf25cdc8f6843c2ae2b57: not really a bug, but 2+ enemies + 1 wall may stuck one another depending on where they want to go
