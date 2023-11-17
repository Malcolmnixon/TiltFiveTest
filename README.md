# Tilt Five Test

This test project is a development area for the construction of the Godot Tilt Five Tools asset.
The Tilt Five Tools asset builds on the [TiltFiveGodot4](https://github.com/GodotVR/TiltFiveGodot4) asset.


## Getting Started

At this point the repository can be checked out with the basic infrastructure and two mini-games.
In the future the following will be the steps to construct a new project.

### Initial Project Setup

1. Install the TiltFiveGodot4 asset and enabling the plugin
2. Install the TiltFiveTools asset


### Basic Game Infrastructure

1. Create a Custom Main scene (extending from Tilt Five Tools "Staging")
2. Create a Custom Player scene (extending from Tilt Five tools "Player")
3. Create a starting Game scene (extending from Tilt Five tools "Scene")
4. Set the Custom Main scene to:
   * Be the Godot Main scene started when the application begins
   * Use the Custom Player scene as its T5Manager Glasses scene
   * Use the starting Game scene as its starting scene to initially load

### Customizing

* Add a Spectator Camera to the Custom Main scene
* Add pointers or effects to the the Custom Player scene
* Populate objects in the Custom Start scene
* Construct characters (extending from Tilt Five Tools "Character")
* Handle player wand inputs and for the character
* Add new Game scenes and the logic to transition between them
* Add wand-pointer event handling scripts to objects
