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

#Inventory variables and signals
@onready var inventory_controller: Node = %"Inventory Controller/CanvasLayer/Inventory UI"
@onready var raycast: RayCast3D = $RayCast3D

var inv_open : bool = false

signal invent_on_item_collected(item)

# To properly move, the player camera needs the mouse to be captured
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	invent_on_item_collected.connect(inventory_controller.pickup_item)

func _physics_process(delta: float) -> void:
	frame_camera_rotation()
	# interaction function
	try_taking_item()
	
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

func _input(_event: InputEvent) -> void:
	# Handle Inventory Opening/Closing
	if Input.is_action_just_pressed("inventory"):
		if not inv_open:
			inventory_controller.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			# Here we would disable things that use the mouse, like looking around
			# or interacting / attacking, would depending on ho the final Player camera is set up
			inv_open = true
		else:
			inventory_controller.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			# Here we would re-enable whatever was disabled above
			inv_open = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			_look += -event.relative * mouse_sensitivity
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Handles interaction using RayCast3D
# Object must have "ItemInteract" to be an item that is interactable
# "ItemInteract" holds item/action data
func try_taking_item() -> void:
	if !Input.is_action_just_pressed("interact"):
		return
	if !raycast.is_colliding():
		print("not colliding!")
		return
	print("Raycast Collided!")
	
	var obj = find_interaction_component(raycast.get_collider())
	
	if obj == null:
		print("This is not an item!")
		return
	print("object is an item!")
	
	if !obj.has_method("interact"):
		print("Item cannot be picked up!")
		return
	print(obj.name)
	obj.item_collected.connect(_on_item_collected)
	print("signal connected")
	obj.interact()

# Handles finding the "ItemInteract" nodes of objects
func find_interaction_component(object: Node) -> Node:
	return object.get_node("ItemInteract")

# Signal emmited when item is picked up
func _on_item_collected(item: Node):
	print("Collected Item: ", item)
	
	var ic = find_interaction_component(item)
	if not ic:
		return
	
	# Add item to player inventory
	add_item_to_inventory(ic.item_data)
	# play item pickup sound effect
	play_sound_effect(ic.collect_sound_effect)
	# delete item from 3D world
	item.queue_free()

# Handles playing the pickup sound affect of a given item
func play_sound_effect(sound_effect: AudioStream) -> void:
	if not sound_effect:
		return
	
	var audio_player := AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.stream = sound_effect
	
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.play()

# Handles adding Item to Inventory
func add_item_to_inventory(Item_data: ItemData) -> void:
	if Item_data != null:
		invent_on_item_collected.emit(Item_data)
		return
	 
	print("No item data found") 

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
