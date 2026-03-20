extends CharacterBody3D


const SPEED = 400.0
const JUMP_VELOCITY = 4.5

# Stores the x-y direction to rotate the player look direction
var _look := Vector2.ZERO

# mouse sensistivity should be low because it is in radians
@export var mouse_sensitivity := 0.0008
@export var min_look_boundary  = -60.0
@export var max_look_boundary  = 10.0

@onready var horizontal_pivot: Node3D = $HorizontalPivot
@onready var vertical_pivot: Node3D = $HorizontalPivot/VerticalPivot

#**********************julian######################
@onready var raycast = $RayCast3D 
###################################################
	



# To properly move, the player camera needs the mouse to be captured
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	frame_camera_rotation()
	#############julain#####################
	#handle_interaction()
	########################################
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Moves based on input keys and facing direction. Smoothly stops if no key is pressed
	var direction := get_movement_direction()
	if direction:
		velocity.x = direction.x * SPEED * delta
		velocity.z = direction.z * SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta)

	move_and_slide()
	
	
#############################julian###########################################
#This is the function to interact with the lever
#func handle_interaction():
	if Input.is_action_just_pressed("interact"):
		if raycast.is_colliding():
			var obj = raycast.get_collider()
			if obj and obj.has_method("interact"):
				obj.interact()
##############################################################################



func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			_look += -event.relative * mouse_sensitivity
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Calculates the desired movement direction based on input direction and which way the player is facing
func get_movement_direction() -> Vector3:
	# global movement direction
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
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
	
