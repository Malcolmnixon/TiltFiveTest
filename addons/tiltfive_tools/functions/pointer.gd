@tool
class_name T5ToolsPointer
extends Node3D


## TiltFive Pointer
##
## This node implements a laser-pointer capable of interacting with bodies
## and areas.


## Signal for pointer entered valid target
signal pointer_entered(target : Node3D, at : Vector3)

## Signal for pointer moved on valid target
signal pointer_moved(target : Node3D, from : Vector3, to : Vector3)

## Signal for pointer exited valid target
signal pointer_exited(target : Node3D, at : Vector3)

## Signal for pointer pressed on valid target
signal pointer_pressed(target : Node3D, at : Vector3)

## Signal for pointer released on valid target
signal pointer_released(target : Node3D, at : Vector3)

## Signal for pointing event
signal pointing_event(event : T5ToolsPointerEvent)


## Default collison mask (world + 21:pointable)
const COLLISION_MASK := 0b0000_0000_0001_0000_0000_0000_1111_1111

## Default valid mask (21:pointable)
const VALID_MASK := 0b0000_0000_0001_0000_0000_0000_0000_0000


@export_group("General")

## Pointer enabled
@export var enabled : bool = true : set = _set_enabled

## Pointer length
@export var length : float = 1.0 : set = _set_length

## Pointer angle
@export var angle : float = 25.0 : set = _set_angle

## Player
@export var player : T5ToolsPlayer

## Action button
@export var button : String = "trigger"

@export_group("Arc")

## Arc length when not colliding
@export_range(0.01, 1.0, 0.01, "or_greater") var not_colliding_distance : float = 0.5

## Bezier strength
@export_range(0.1, 1.0, 0.05) var bezier_strength : float = 0.5

## Laser radius
@export var laser_radius : float = 0.01 : set = _set_laser_radius

## Laser pointer material
@export var laser_color : Color = Color(0.0, 0.0, 1.0) : set = _set_laser_color

## Laser pointer hit material
@export var laser_hit_color : Color = Color(0.5, 0.5, 1.0) : set = _set_laser_hit_color

## Show debug information
@export var debug : bool = false

@export_group("Target")

## Laser target radius
@export var target_radius : float = 0.05 : set = _set_target_radius

## Laser pointer target
@export var target_material : Material = null : set = _set_target_material

@export_group("Collision")

## Pointer collision mask
@export_flags_3d_physics var collision_mask : int = COLLISION_MASK : set = _set_collision_mask

## Pointer valid mask
@export_flags_3d_physics var valid_mask : int = VALID_MASK : set = _set_valid_mask

## Enable pointer collision with bodies
@export var collide_with_bodies : bool = true : set = _set_collide_with_bodies

## Enable pointer collision with areas
@export var collide_with_areas : bool = false : set = _set_collide_with_areas


# RayCast node
@onready var _raycast : RayCast3D = $RayCast

# Laser node
@onready var _laser : MeshInstance3D = $Laser

# Laser material
@onready var _material : ShaderMaterial = $Laser.material_override

# Target node
@onready var _target : MeshInstance3D = $Target


# Controller
var _controller : T5Controller3D

# Locked target
var _locked_target : Node3D

# Last target
var _last_target : Node3D

# Last valid
var _last_valid : bool

# Last collision point
var _last_at : Vector3

# Last input float (for action buttons on float axes)
var _last_input_float : float = 0.0


func _ready() -> void:
	# Do not initialise if in the editor
	if Engine.is_editor_hint():
		return

	# Get the controller
	_controller = get_parent() as T5Controller3D
	_controller.button_pressed.connect(_on_button_pressed)
	_controller.button_released.connect(_on_button_released)
	_controller.input_float_changed.connect(_on_input_float_changed)

	# Get the laser shader material
	_material = _laser.material_override

	# Update the pointer
	_update_ray()
	_update_target()
	_update_collision()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	# Verify the controller
	if not (get_parent() is T5Controller3D):
		warnings.append("Pointer must be a child of a T5Controller3D")

	return warnings


func _physics_process(_delta : float) -> void:
	# Do not run if in the editor
	if Engine.is_editor_hint() or !is_inside_tree():
		return

	# Handle targets being deleted
	if _locked_target and not is_instance_valid(_locked_target):
		_locked_target = null
	if _last_target and not is_instance_valid(_last_target):
		_last_target = null
		_visible_miss()

	# find the new target
	var new_target : Node3D
	var new_valid : bool
	var new_at : Vector3
	if enabled and _controller.get_is_active() and _raycast.is_colliding():
		new_at = _raycast.get_collision_point()
		if _locked_target:
			# Locked to 'target'
			new_target = _locked_target
		else:
			# Use raycast target
			new_target = _raycast.get_collider()

		# Test if the object is a valid hit
		if not is_instance_valid(new_target) or not "collision_layer" in new_target:
			new_target = null
		else:
			new_valid = (new_target.collision_layer & valid_mask) != 0

	# Skip if no current and previous collision
	if not new_target and not _last_target:
		return

	# Handle pointer changes
	if new_target and not _last_target:
		# If valid, report events on new_target
		if new_valid:
			_report_entered(new_target, new_at)
			_report_moved(new_target, new_at, new_at)

		# Update visible artifacts for hit
		_visible_hit(new_valid, new_at)
	elif not new_target and _last_target:
		# If valid, report exited _last_target
		if _last_valid:
			_report_exited(_last_target, _last_at)

		# Update visible artifacts for miss
		_visible_miss()
	elif new_target != _last_target:
		# If valid, report exiting _last_target
		if _last_valid:
			_report_exited(_last_target, _last_at)

		# If valid, report entered new_target
		if new_valid:
			_report_entered(new_target, new_at)
			_report_moved(new_target, new_at, new_at)

		# Update visible artifacts for hit
		_visible_hit(new_valid, new_at)
	elif new_at != _last_at:
		# If valid, report moved on target
		if new_valid:
			_report_moved(new_target, new_at, _last_at)

		# Update visible artifacts for move
		_visible_move(new_at)

	# Update last values
	_last_target = new_target
	_last_valid = new_valid
	_last_at = new_at


func _set_enabled(p_enabled : bool) -> void:
	enabled = p_enabled
	if is_inside_tree():
		_update_laser()


func _set_length(p_length : float) -> void:
	length = p_length
	if is_inside_tree():
		_update_ray()


func _set_angle(p_angle : float) -> void:
	angle = p_angle
	if is_inside_tree():
		_update_ray()


func _set_laser_radius(p_laser_radius : float) -> void:
	laser_radius = p_laser_radius
	if is_inside_tree():
		_update_laser()


func _set_laser_color(p_laser_color : Color) -> void:
	laser_color = p_laser_color
	if is_inside_tree():
		_update_laser()


func _set_laser_hit_color(p_laser_hit_color : Color) -> void:
	laser_hit_color = p_laser_hit_color
	if is_inside_tree():
		_update_laser()


func _set_target_radius(p_target_radius : float) -> void:
	target_radius = p_target_radius
	if is_inside_tree():
		_update_target()


func _set_target_material(p_target_material : Material) -> void:
	target_material = p_target_material
	if is_inside_tree():
		_update_target()


func _set_collision_mask(p_collision_mask : int) -> void:
	collision_mask = p_collision_mask
	if is_inside_tree():
		_update_collision()


func _set_valid_mask(p_valid_mask : int) -> void:
	valid_mask = p_valid_mask
	if is_inside_tree():
		_update_collision()


func _set_collide_with_bodies(p_collide_with_bodies : bool) -> void:
	collide_with_bodies = p_collide_with_bodies
	if is_inside_tree():
		_update_collision()


func _set_collide_with_areas(p_collide_with_areas : bool) -> void:
	collide_with_areas = p_collide_with_areas
	if is_inside_tree():
		_update_collision()


func _update_ray() -> void:
	_raycast.rotation_degrees.x = -angle
	_raycast.target_position.z = -length
	_update_laser()


func _update_laser() -> void:
	_laser.mesh.top_radius = laser_radius
	_laser.mesh.bottom_radius = laser_radius

	if enabled and _last_target:
		_visible_hit(_last_valid, _last_at)
	else:
		_visible_miss()


func _update_target() -> void:
	_target.mesh.radius = target_radius
	_target.mesh.height = target_radius * 2.0
	_target.set_surface_override_material(0, target_material)


func _update_collision():
	_raycast.collision_mask = collision_mask
	_raycast.collide_with_bodies = collide_with_bodies
	_raycast.collide_with_areas = collide_with_areas


func _update_laser_active_color(hit : bool) -> void:
	# Get the material
	var color = laser_hit_color if hit else laser_color

	# Show or hide the laser
	if _material:
		_material.set_shader_parameter("color", color)
		_laser.visible = true
	else:
		_laser.visible = false


func _report_entered(target : Node3D, at : Vector3) -> void:
	pointer_entered.emit(target, at)
	T5ToolsPointerEvent.entered(player, self, target, at)


func _report_moved(target : Node3D, to : Vector3, from : Vector3) -> void:
	pointer_moved.emit(target, from, to)
	T5ToolsPointerEvent.moved(player, self, target, to, from)


func _report_exited(target : Node3D, at : Vector3) -> void:
	pointer_exited.emit(target, at)
	T5ToolsPointerEvent.exited(player, self, target, at)


func _report_pressed(target : Node3D, at : Vector3) -> void:
	pointer_pressed.emit(target, at)
	T5ToolsPointerEvent.pressed(player, self, target, at)


func _report_released(target : Node3D, at : Vector3) -> void:
	pointer_released.emit(target, at)
	T5ToolsPointerEvent.released(player, self, target, at)


func _visible_hit(valid : bool, at : Vector3) -> void:
	# If enabled, show the target
	_target.global_position = at
	_target.visible = valid and target_material

	# Update the laser
	_update_laser_active_color(valid)
	_update_laser_arc(at)
	#var hit_length := at.distance_to(global_position)
	#_laser.mesh.height = hit_length
	#_laser.position.z = hit_length * -0.5


func _visible_move(at : Vector3) -> void:
	# If enabled, show the target
	_target.global_position = at

	# Update the laser
	_update_laser_arc(at)


func _visible_miss() -> void:
	# Update the target
	_target.visible = false

	# Calculate a fake at vector
	var at := _raycast.to_global(Vector3(0, 0, -length))

	# Update the laser
	_update_laser_active_color(false)
	_update_laser_arc(at)


func _update_laser_arc(at : Vector3) -> void:
	var raycast_transform := _raycast.global_transform

	var distance := at.distance_to(raycast_transform.origin)

	# Mix target up with raycast direction
	var forward := Vector3(0, -1, 0)
	var up := (Vector3.UP + raycast_transform.basis.z).normalized()

	var inv := _laser.global_transform.affine_inverse()
	var target := inv * at
	var target_up := inv.basis * up
	target_up.z -= abs(target_up.x)
	target_up.x = 0.0

	if _material:
		_material.set_shader_parameter("forward", forward * distance * bezier_strength)
		_material.set_shader_parameter("target", target)
		_material.set_shader_parameter("target_up", target_up * distance * bezier_strength)


func _on_button_pressed(p_name : String) -> void:
	# Ignore if not the active button or no target
	if not _last_target or p_name != button:
		return

	# Lock the target and report the press
	_locked_target = _last_target
	_report_pressed(_locked_target, _last_at)


func _on_button_released(p_name : String) -> void:
	# Ignore if not the active button or no target
	if not _locked_target or p_name != button:
		return

	# Report the release and unlock the target
	_report_released(_locked_target, _last_at)
	_locked_target = null


func _on_input_float_changed(p_name : String, p_value : float) -> void:
	# Ignore if not the active button
	if p_name != button:
		return

	# Handle press/release with hysteresis
	if p_value >= 0.75 and _last_input_float < 0.75:
		_on_button_pressed(p_name)
	elif p_value <= 0.25 and _last_input_float > 0.25:
		_on_button_released(p_name)

	_last_input_float = p_value
