class_name T5ToolsStagingBase
extends Node3D


## TiltFive Tools Staging Base
##
## This node manages transitions between scenes. It can be accessed globally 
## using "T5ToolsStagingBase.instance".


signal player_created(player : T5ToolsPlayerBase)
signal player_removed(player : T5ToolsPlayerBase)
signal scene_pre_exiting(scene : T5ToolsSceneBase, user_data : Variant)
signal scene_exiting(scene : T5ToolsSceneBase, user_data : Variant)
signal scene_loaded(scene : T5ToolsSceneBase, user_data : Variant)
signal scene_visible(scene : T5ToolsSceneBase, user_data : Variant)


## Main scene
@export_file('*.tscn') var main_scene : String


## Variable to hold general game-data
var data : Dictionary = {}

## Array of players
var players : Array[T5ToolsPlayerBase] = []


# The current scene
var _current_scene : T5ToolsSceneBase

# The fade tween
var _fade_tween : Tween


## Instance of the staging
static var instance : T5ToolsStagingBase


func _enter_tree():
	# Save as the staging instance
	instance = self


func _exit_tree():
	# Clear the staging instance
	instance = null


func _ready() -> void:
	# Do not initialise if in the editor
	if Engine.is_editor_hint():
		return

	# Start by loading the main scene
	do_load_scene(main_scene, null)


# Load a scene
func do_load_scene(p_scene_path : String, user_data : Variant) -> void:
	# Log request
	print_verbose("StagingBase: Request to load %s" % p_scene_path)

	# Start background loading of the resource
	ResourceLoader.load_threaded_request(p_scene_path)

	# Start by unloading the current scene
	if _current_scene:
		# Report about to exit the current scene
		print_verbose("StagingBase: Reporting scene_pre_exiting")
		scene_pre_exiting.emit(_current_scene, user_data)
		_current_scene.scene_pre_exiting(user_data)

		# Fade to black
		print_verbose("StagingBase: Fading out")
		if _fade_tween: _fade_tween.kill()
		_fade_tween = get_tree().create_tween()
		_fade_tween.tween_method(_set_fade, 0.0, 1.0, 1.0)
		await _fade_tween.finished

		# Report the exit of the current scene
		print_verbose("StagingBase: Reporting scene_exiting")
		scene_exiting.emit(_current_scene, user_data)
		_current_scene.scene_exiting(user_data)

		# Discard the current scene
		print_verbose("StagingBase: Discarding old scene")
		$Scene.remove_child(_current_scene)
		_current_scene.queue_free()
		_current_scene = null

		# Zero all player origins. The new scene can choose to relocate
		# but it's safest to just zero in case
		for player in players:
			player.origin.global_transform = Transform3D.IDENTITY

	# Load the new scene
	print_verbose("StagingBase: Loading new scene")
	var new_scene : PackedScene = ResourceLoader.load_threaded_get(p_scene_path)

	# Instantiate the scene
	print_verbose("StagingBase: Instantiating new scene")
	_current_scene = new_scene.instantiate()
	$Scene.add_child(_current_scene)

	# Report the new scene is loaded
	print_verbose("StagingBase: Reporting scene_loaded")
	_current_scene.scene_loaded(user_data)
	scene_loaded.emit(_current_scene, user_data)

	# Fade to visible
	print_verbose("StagingBase: Fading in")
	if _fade_tween: _fade_tween.kill()
	_fade_tween = get_tree().create_tween()
	_fade_tween.tween_method(_set_fade, 1.0, 0.0, 1.0)
	await _fade_tween.finished

	# Report the new scene is visible
	print_verbose("StagingBase: Reporting scene_visible")
	_current_scene.scene_visible(user_data)
	scene_visible.emit(_current_scene, user_data)


func _set_fade(p_fade : float) -> void:
	if p_fade == 0.0:
		$Fade.visible = false
	else:
		var material : ShaderMaterial = $Fade.get_surface_override_material(0)
		if material:
			material.set_shader_parameter("alpha", p_fade)
		$Fade.visible = true


# Handle player added
func _on_player_scene_added(player : T5ToolsPlayerBase):
	print_verbose("StagingBase: Player %s added" % player)
	players.append(player)
	player_created.emit(player)


# Handle player removed
func _on_player_scene_removed(player : T5ToolsPlayerBase):
	print_verbose("StagingBase: Player %s removed" % player)
	players.erase(player)
	player_removed.emit(player)


## Load the requested scene
static func load_scene(p_scene_path : String, user_data : Variant = null) -> void:
	instance.do_load_scene(p_scene_path, user_data)
