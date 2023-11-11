extends T5ToolsCharacterBase


## Movement force
@export var move_force : float = 7.0

## Jump velocity
@export var jump_velocity : float = 5.0


func _ready() -> void:
	# Subscribe to player wand events
	player.wand.button_pressed.connect(_on_button_pressed)
	player.wand.input_vector2_changed.connect(_on_input_vector2_changed)


func _process(_delta : float) -> void:
	# Track the origin with the character body
	player.origin.global_position = $RigidBody3D.global_position + Vector3(0, 2, 0)


func _on_button_pressed(p_name : String) -> void:
	# Skip if not the jump button
	if p_name != "button_3":
		return

	# Skip if we are moving up
	if $RigidBody3D.linear_velocity.y > 0.0:
		return

	# Skip if not on the ground
	var collision := KinematicCollision3D.new()
	if not $RigidBody3D.test_move(
		$RigidBody3D.global_transform,
		Vector3.DOWN * 0.1,
		collision):
		return

	# Skip if the ground is too steep to jump
	if collision.get_angle(0) > deg_to_rad(60):
		return

	# Jump up
	$RigidBody3D.linear_velocity.y = jump_velocity


func _on_input_vector2_changed(p_name : String, p_value : Vector2) -> void:
	# Skip if not joystick
	if p_name != "stick":
		return

	# Apply force to character body
	$RigidBody3D.apply_central_force(
		Vector3(p_value.x, 0.0, -p_value.y) * move_force)