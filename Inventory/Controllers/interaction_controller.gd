extends Node

@onready var raycast: RayCast3D = $"../RayCast3D"
@onready var inventory_controller: Node = $"../Inventory Controller/CanvasLayer/Inventory UI"

var player : Node3D

var inv_open : bool = false

signal invent_on_item_collected(item)

func _ready() -> void:
	invent_on_item_collected.connect(inventory_controller.pickup_item)
	
	inventory_controller.raycast = raycast
	inventory_controller.interaction_controller = self
	
	player = get_parent()

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
			inventory_controller.hide_panel()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			# Here we would re-enable whatever was disabled above
			inv_open = false
	
	if Input.is_action_just_pressed("Hot1"):
		inventory_controller.use_collectable(90)
	if Input.is_action_just_pressed("Hot2"):
		inventory_controller.use_collectable(91)
	if Input.is_action_just_pressed("Hot3"):
		inventory_controller.use_collectable(92)

# Handles interaction using RayCast3D
# Object must have "ItemInteract" to be an item that is interactable
# "ItemInteract" holds item/action data, "EnvioInteract" calls the interact function of an enviorment object
func try_taking_item() -> void:
	if !Input.is_action_just_pressed("interact"):
		return
	if !raycast.is_colliding():
		return
	print("collided")
	var obj = find_interaction_component(raycast.get_collider())
	print(str(raycast.get_collider()))
	if obj == null:
		return
	
	if !obj.has_method("interact"):
		return
		
	if obj is ItemInteract:
		obj.item_collected.connect(_on_item_collected)
	if obj is EnvioInteract:
		play_sound_effect(obj.interaction_sound_effect)
	
	obj.interact()

# Signal emmited when item is picked up
func _on_item_collected(item: Node):	
	var ic = find_interaction_component(item)
	if not ic:
		return
	
	# Add item to player inventory
	add_item_to_inventory(ic.item_data)
	# play item pickup sound effect
	play_sound_effect(ic.collect_sound_effect)
	# delete item from 3D world
	if ic.remove_from_world_on_collect:
		item.queue_free()

# Handles adding Item to Inventory
func add_item_to_inventory(Item_data: ItemData) -> void:
	if Item_data != null:
		invent_on_item_collected.emit(Item_data)
		return
	 
# Handles playing the pickup sound affect of a given item
func play_sound_effect(sound_effect: AudioStream) -> void:
	if not sound_effect:
		return
	
	var audio_player := AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.stream = sound_effect
	audio_player.bus = "SFX"
	
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.play()

# Handles finding the "ItemInteract" nodes of objects
func find_interaction_component(object: Node) -> Node:
	var item = object.get_node_or_null("ItemInteract")
	var inter = object.get_node_or_null("EnvioInteract")
	
	if !item:
		return inter
	
	return item
	 

# Put all action code here!
func modify_health(modifier_value: int) -> void:
	for c in player.get_children():
		if c is HealthComponent:
			c.current_hp += modifier_value
			return

func modify_stamina(modifier_value: int) -> void:
	for c in player.get_children():
		if c is StaminaComponent:
			c.current_stamina += modifier_value
			return

func modify_armor(modifier_value: int) -> void:
	for c in player.get_children():
		if c is ArmorComponent:
			var armor_bonus = RatioArmorStrategy.new(0.5, modifier_value)
			c.add_armor_source(armor_bonus)
			return
