class_name T5ToolsSceneBase
extends Node3D


## Character scene
@export var character_scene : PackedScene

## How close to spawn characters
@export var spawn_padding : float = 1.0


## Array of characters
var characters : Array[T5ToolsCharacterBase] = []


func scene_pre_exiting(_user_data : Variant) -> void:
	pass


func scene_exiting(_user_data : Variant) -> void:
	pass


func scene_loaded(user_data : Variant) -> void:
	# Skip if we dont have characters to instance
	if !character_scene:
		return

	# Get the spawn position data
	var spawn_position = user_data
	if typeof(spawn_position) == TYPE_OBJECT and \
		spawn_position.has_method("get_spawn_position"):
		spawn_position = spawn_position.get_spawn_postion(self)

	# Get the spawn transform
	var spawn_transform := Transform3D.IDENTITY
	match typeof(spawn_position):
		TYPE_STRING:
			# Name of Node3D to spawn at
			var node = find_child(spawn_position)
			if node is Node3D:
				spawn_transform = node.global_transform

		TYPE_VECTOR3:
			# Vector3 to spawn at
			spawn_transform.origin = spawn_position

		TYPE_TRANSFORM3D:
			# Transform3D to spawn at
			spawn_transform = spawn_position

	# Spawn the player characters
	var players := T5ToolsStagingBase.instance.players
	var count = players.size()
	for index in count:
		# Construct the character
		var character : T5ToolsCharacterBase = character_scene.instantiate()
		character.player = players[index]

		# Add the character to the scene
		add_child(character)

		# Calculate the spawn offset
		var offset := Vector3.FORWARD * spawn_padding
		offset = offset.rotated(Vector3.UP, PI * 2 * index / count)

		# Position the character
		character.global_transform = spawn_transform
		character.global_position += offset


func scene_visible(_user_data : Variant) -> void:
	pass
