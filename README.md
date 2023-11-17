# Tilt Five Test

This test project is a development area for the construction of the Godot Tilt Five Tools asset.
The Tilt Five Tools asset builds on the [TiltFiveGodot4](https://github.com/GodotVR/TiltFiveGodot4) asset.


## How To Use

At this point the repository should be checked out to a new folder and opened in Godot. In the future
the initial project configuration will start by:

1. Installing the TiltFiveGodot4 asset and enabling the plugin
2. Installing the TiltFiveTools asset

The initial game infrastructure is created by:

1. Create a Custom Main scene (extending from Tilt Five Tools "Staging")
2. Create a Custom Player scene (extending from Tilt Five tools "Player")
3. Create a starting Game scene (extending from Tilt Five tools "Scene")
4. Set the Custom Main scene to:
   * Be the Godot Main scene started when the application begins
   * Use the Custom Player scene as its T5Manager Glasses scene
   * Use the starting Game scene as its starting scene to initially load

The game infrastructure is then customized by:

* Adding a Spectator Camera to the Custom Main scene
* Adding pointers or effects to the the Custom Player scene
* Populating objects in the Custom Start scene
* Constructing characters (extending from Tilt Five Tools "Character")
* Handle player wand inputs and for the character
* Adding new Game scenes and the logic to transition between them
* Adding wand-pointer event handling scripts to objects
