extends CharacterBody3D


signal perform_attack
signal perform_attack_alternative
signal perform_sprint
signal stop_attack_alternative
signal stop_sprint

const SPEED = 400.0
const JUMP_VELOCITY = 4.5

@onready var sprint_component: SprintComponent = $Sprint_Component


# Stores the x-y direction to rotate the player look direction
var _look := Vector2.ZERO

# mouse sensistivity should be low because it is in radians
@export var mouse_sensitivity := 0.0008
@export var min_look_boundary  = -60.0
@export var max_look_boundary  = 10.0

@onready var horizontal_pivot: Node3D = $HorizontalPivot
@onready var vertical_pivot: Node3D = $HorizontalPivot/VerticalPivot

# To properly move, the player camera needs the mouse to be captured
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	frame_camera_rotation()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Moves based on input keys and facing direction. Smoothly stops if no key is pressed
	var direction := get_movement_direction()
	var move_speed = sprint_component.apply_sprint(SPEED, delta)
	if direction:
		velocity.x = direction.x * move_speed * delta
		velocity.z = direction.z * move_speed * delta
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * delta)
		velocity.z = move_toward(velocity.z, 0, move_speed * delta)

	move_and_slide()



func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			_look += -event.relative * mouse_sensitivity
		
		if event.is_action_pressed("combat_attack"):
			perform_attack.emit()
		if event.is_action_pressed("combat_alternative"):
			perform_attack_alternative.emit()
		if event.is_action_released("combat_alternative"):
			stop_attack_alternative.emit()
		if event.is_action_pressed("move_sprint"):
			perform_sprint.emit()
		if event.is_action_released("move_sprint"):
			stop_sprint.emit()
		
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Calculates the desired movement direction based on input direction and which way the player is facing
func get_movement_direction() -> Vector3:
	# global movement direction
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_vector := Vector3(input_dir.x, 0, input_dir.y).normalized()
	# transforms movement to be based on the horizontal facing direction
	var direction := horizontal_pivot.global_transform.basis * input_vector
	return direction


# rotates pivot nodes to store how much the player has rotated based on how much
# the mouse moves  each from
func frame_camera_rotation() -> void:
	horizontal_pivot.rotate_y(_look.x)
	vertical_pivot.rotate_x(_look.y)
	
	# Prevent vertical look direction from looking up or down too much
	vertical_pivot.rotation.x = clampf(
		 vertical_pivot.rotation.x,
		 deg_to_rad(min_look_boundary),
		 deg_to_rad(max_look_boundary)
	)
	
	# Spring arm only needs to copy what the vertical pivot has already stored.
	$SpringArm3D.global_transform = vertical_pivot.global_transform
	
	# By this point, "used" all the difference accumulated in _look since last frame, reset for next accumulation
	_look = Vector2.ZERO
