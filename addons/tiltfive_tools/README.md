# Tilt Five Tools

This asset provides numerous helper scripts and nodes that work with
[TiltFiveGodot4](https://github.com/GodotVR/TiltFiveGodot4) for developing
Tilt Five experiences and games.


## Visual Layers

As Tilt Five is designed to work with multiple local players, it is sometimes
necessary to limit what content is visible to the different players. This can
be achieved using visual layers and camera cull masks. The following are the
layer assignments used by Tilt Five Tools:
* [1] Visible by Everyone
* [2] Visible by Spectator
* [3] Visible by All Players
* [11] Visible to Player 1
* [12] Visible to Player 2
* [13] Visible to Player 3
* [14] Visible to Player 4


## Functions

This folder contains nodes for enhancing player scenes:

| Type | Function |
| :--- | :----------- |
| Board Scale | Support scaling the game board via wand buttons |
| Pointer | Adds a curved pointer to the wand that fires pointer events |


## Objects

This folder contains nodes to help with standard Tilt Five behavior.

| Type | Function |
| :--- | :----------- |
| Viewport2Din3D | Render a 2D UI in 3D  with support for pointer interactions |
| Scene Switch Area | An Area3D that can trigger Staging to load a different game scene |
| Spectator Camera | A spectator camera that follows the average player origin/board position |


## Staging

This folder contains nodes for switching between different scenes.

| Type | Function |
| :--- | :----------- |
| Staging | This manages the players, and supports switching between different game scenes |
| Scene | This is the base for creating custom game scenes |
| Player | This is the base for customizing player functionality |
| Character | this is the base for characters (player avatars) |
