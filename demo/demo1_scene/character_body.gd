extends RigidBody3D


## Movement force
@export var move_force : float = 7.0

## Jump velocity
@export var jump_velocity : float = 5.0


# The player
var _player : T5ToolsPlayer

# Last hit test
var _last_hit := false


func _ready() -> void:
	# Get the player from the character
	_player = T5ToolsCharacter.find_instance(self).player
	
	# Subscribe to player wand events
	var controller := _player.get_player_wand(0)
	controller.button_pressed.connect(_on_button_pressed)
	controller.input_vector2_changed.connect(_on_input_vector2_changed)


func _process(_delta : float) -> void:
	# Track the origin with the character body
	_player.get_player_origin().global_position = global_position + Vector3(0, 2, 0)


func _integrate_forces(state : PhysicsDirectBodyState3D) -> void:
	# Process the contacts for hits and fastest rolling speed
	var hit := false
	var speed := 0.0
	for c in state.get_contact_count():
		# Test for a velocity striking into the contact surface
		var cnorm := state.get_contact_local_normal(c)
		var cvel := state.get_contact_local_velocity_at_position(c)
		if cnorm.dot(cvel) < -2.0:
			hit = true

		# Get the maximum speed at the contact point
		var pos := to_local(state.get_contact_local_position(c))
		var vel := state.get_velocity_at_local_position(pos)
		speed = max(speed, vel.length())

	# Adjust rolling volume based on speed
	speed = clamp(speed / 5.0, 0.0, 1.0)
	$RollingPlayer.volume_db = linear_to_db(speed)

	# Play hit sounds on hit
	if hit and not _last_hit:
		$HitPlayer.play()
	_last_hit = hit


func _on_button_pressed(p_name : String) -> void:
	# Skip if not the jump button
	if p_name != "button_3":
		return

	# Skip if we are moving up
	if linear_velocity.y > 0.0:
		return

	# Skip if not on the ground
	var collision := KinematicCollision3D.new()
	if not test_move(
		global_transform,
		Vector3.DOWN * 0.1,
		collision):
		return

	# Skip if the ground is too steep to jump
	if collision.get_angle(0) > deg_to_rad(60):
		return

	# Jump up
	linear_velocity.y = jump_velocity


func _on_input_vector2_changed(p_name : String, p_value : Vector2) -> void:
	# Skip if not joystick
	if p_name != "stick":
		return

	# Apply force to character body
	apply_central_force(
		Vector3(p_value.x, 0.0, -p_value.y) * move_force)
