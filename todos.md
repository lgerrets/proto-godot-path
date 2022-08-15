# TODOs
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
- in 105344c6030d099ea53bf25cdc8f6843c2ae2b57: not really a bug, but 2+ enemies + 1 wall may stuck one another depending on where they want to go
- in e3fc7ab49aeb34d3b4ef7b84ba72e67048fa28c4: sometimes following paths is bugged eg entity does not make progress or wiggles
- in e3fc7ab49aeb34d3b4ef7b84ba72e67048fa28c4: `assert(len(path) > 0)`
