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
- camera position / mouse position
- doc/bug.png one enemy's path does not seem to update every sec as expected ?!
    - fixed
        - this was because points were added to a_star even when invalid + we are assigned to the closest a_star point + we check the straight path to the closest a_star point
        - now we do not do that check + we only add points that are connected to the unique connected component
- bug :
    - now that we do not add all points, some points are missed
    - characters do not slide but collide => try move_and_slide or put weights on nodes that are occupied by a character
    - player's path should be updated eg once every sec
- characters oscillate
- in 105344c6030d099ea53bf25cdc8f6843c2ae2b57: not really a bug, but 2+ enemies + 1 wall may stuck one another depending on where they want to go
- in e3fc7ab49aeb34d3b4ef7b84ba72e67048fa28c4: sometimes following paths is bugged eg entity does not make progress or wiggles
- in e3fc7ab49aeb34d3b4ef7b84ba72e67048fa28c4: `assert(len(path) > 0)`
