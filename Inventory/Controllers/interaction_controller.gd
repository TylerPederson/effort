extends Node

@onready var raycast: RayCast3D = $"../RayCast3D"
@onready var inventory_controller: Node = %"Inventory Controller/CanvasLayer/Inventory UI"

var inv_open : bool = false

signal invent_on_item_collected(item)

func _ready() -> void:
	invent_on_item_collected.connect(inventory_controller.pickup_item)

func _physics_process(_delta: float) -> void:
	try_taking_item()

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

# Handles adding Item to Inventory
func add_item_to_inventory(Item_data: ItemData) -> void:
	if Item_data != null:
		invent_on_item_collected.emit(Item_data)
		return
	 
	print("No item data found") 

# Handles playing the pickup sound affect of a given item
func play_sound_effect(sound_effect: AudioStream) -> void:
	if not sound_effect:
		return
	
	var audio_player := AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.stream = sound_effect
	
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.play()

# Handles finding the "ItemInteract" nodes of objects
func find_interaction_component(object: Node) -> Node:
	return object.get_node("ItemInteract")
