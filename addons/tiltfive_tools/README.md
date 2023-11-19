# Tilt Five Tools

This asset provides numerous helper scripts and nodes that work with
[TiltFiveGodot4](https://github.com/GodotVR/TiltFiveGodot4) for developing
Tilt Five experiences and games.


## General Concepts

### Visual Layers

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


### Physics Layers

Similar to Visual Layers, four physics layers are reserved for the players.

* [11] Collision for Player 1
* [12] Collision for Player 2
* [13] Collision for Player 3
* [14] Collision for Player 4


### Staging

Staging is the the infrastructure for loading and switching between game scenes.
The components are named and behave like a theater:
* Staging: The stage where scenes are loaded and played
* Scene: An environment constructed on a stage for playing in
* Player: A user playing a role in the game
* Character: A role in the game performed by a player


## Tilt Five Tool Components

### Functions

This folder contains nodes for enhancing player scenes:

| Type | Function |
| :--- | :----------- |
| Board Scale | Support scaling the game board via wand buttons |
| Pointer | Adds a curved pointer to the wand that fires pointer events |
| Face Player | Causes the parent node to rotate to face the player |
| Visible Toggle | Toggles the parent node visibility on a wand button |

### Objects

This folder contains nodes to help with standard Tilt Five behavior.

| Type | Function |
| :--- | :----------- |
| Viewport2Din3D | Render a 2D UI in 3D  with support for pointer interactions |
| Scene Switch Area | An Area3D that can trigger Staging to load a different game scene |
| Spectator Camera | A spectator camera that follows the average player origin/board position |


### Staging

This folder contains nodes for switching between different scenes.

| Type | Function |
| :--- | :----------- |
| Staging | This manages the players, and supports switching between different game scenes |
| Scene | This is the base for creating custom game scenes |
| Player | This is the base for customizing player functionality |
| Character | this is the base for characters (player avatars) |


## FAQ

### Where to Begin

Construct a custom "player" scene inheriting from staging/player.tscn and save it
in the game folder. This can be modified to add pointers, spectator meshes for
glasses and wands, and player-specific popup menus.

Construct a custom "start" scene inheriting from staging/scene.tscn and save it
in the game folder. This will contain the scene objects. Add a simple 0.1 meter
cube mesh in there to test.

Construct a custom "main" scene inheriting from staging/staging.tscn and save it
in the game folder. Set the "Start Scene" property to point to the custom "start"
scene. In the T5Manager node set the "Glasses Scene" to point to the custom
"player" scene. Set this "main" scene as the Godot Main Scene.

Pressing play in Godot should start the game, load the start scene, and show the
cube in the middle of the Tilt Five game pad.


### Create a Popup Menu

Construct a new "popup menu" 2D scene and save it in the game folder. Populate
the 2D scene with suitable controls and buttons as desired for the popup menu.

Open the custom "player" scene and add a new Node3D called "Menu" under the
"Origin" node (which represents the center of the game-board). Under the "Menu"
node add a VisibleToggle node and a FacePlayer node. These will cause the
node to toggle visibility when the T5 Menu button (this can be customized) is
pressed, and to face towards the player.

Under the "Menu" node add a Viewport2Din3D called "Popup" and set its Scene to
the "popup menu" scene. Enable Unshaded otherwise the popup will use the lighting
of the stage and environment.

To prevent other players from seeing or interacting with the popup menu, disable
all Visible and Collision layers. The correct player-only collision and visible
layers will be enabled at runtime depending on which player pops open the menu.


### Scaling the World

Many assets are designed for real-world scale; however the Tilt Five board is
only around 1 meter in size. The easiest way to solve this is to change the 
"Gameboard Scale" property in the custom "player" Origin node. A value of 10
will shrink items in the board making them 10x smaller.


### Creating Characters for Players

Construct a new custom "character" scene inheriting from "staging/character.tscn"
and save it in the game folder.

Add an appropriate character body object (E.G. CharacterBody3D or RigidBody3D)
to the scene, and add a control script to it. In the control body scripts 
'_ready' method, the script should:
* Get the player using `T5ToolsCharacter.find_instance(self).player`
* Get the wand using `player.get_player_wand(0)`
* Subscribe to wand signals such as buttons and joystick
* Have the button and joystick signal handlers control the character body


### Center Game Board on Character

The Origin node of the player scene represents the center of the game-board, so
to make sure the game board stays centered on the character, the character
control body scripts '_process' method should:
* Get the origin using `player.get_player_origin()`
* Set the origins position `origin.global_position = character.global_position

To sink the character into the board, just position the origin above the
character by adding a +Y vector such as:
	`origin.global_position = character.global_position + Vector3(0, 2, 0)`
