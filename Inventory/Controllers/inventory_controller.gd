extends Control
class_name InventoryController

# Inventory Variables
@onready var player_camera: Camera3D = $"../../../SpringArm3D/Camera3D"
@onready var raycast: RayCast3D = $"../../../RayCast3D"
@onready var inventory_grid: GridContainer = %GridContainer
@onready var context_menu: PopupMenu = PopupMenu.new()
@onready var interaction_controller: Node = $"../../../InteractionController"

var inventory_slot_prefab: PackedScene = load("res://Inventory/inventory_slot.tscn")

var item_slot_count: int = 35
var inventory_slots: Array[InventorySlot] = []
var inventory_full: bool = false

func _ready() -> void:
	# add Inventory slots to the inventory grid and slorts array
	for i in item_slot_count:
		var slot = inventory_slot_prefab.instantiate() as InventorySlot
		inventory_grid.add_child(slot)
		slot.inventory_slot_id = i
		slot.on_item_swapped.connect(_on_item_swapped_on_slot)
		slot.on_item_double_clicked.connect(_on_item_double_clicked)
		slot.on_item_right_clicked.connect(_on_item_right_clicked)
		inventory_slots.append(slot)
	
	add_child(context_menu)
	context_menu.connect("id_pressed", Callable(self, "_on_context_menu_selected"))

# Checks if there is an available slot for an item to go into
func has_free_slot() -> bool:
	for slot in inventory_slots:
		if slot.slot_data == null:
			return true
	return false

# Handles adding an item into the item slot and determining empty slots
func pickup_item(item_data: ItemData) -> void:
	for slot in inventory_slots:
		if not slot.slot_filled:
			slot.fill_slot(item_data)
			inventory_full = not has_free_slot()
			return
	inventory_full = true
	
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var slot: InventorySlot = inventory_slots[data]
	if not slot.slot_data:
		return false
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	drop_collectable(data)
	inventory_full = not has_free_slot()

func _on_item_swapped_on_slot(from_slot_id: int, to_slot_id:int) -> void:
	var to_slot_item: ItemData = inventory_slots[to_slot_id].slot_data
	var from_slot_item: ItemData = inventory_slots[from_slot_id].slot_data
	inventory_slots[to_slot_id].fill_slot(from_slot_item)
	inventory_slots[from_slot_id].fill_slot(to_slot_item)

func _on_item_double_clicked(slot_id) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if not slot.slot_data:
		return
	
	match get_item_action_type(slot.slot_data):
		ActionData.ActionType.CONSUMABLE:
			use_collectable(slot_id)
		ActionData.ActionType.EQUIPMENT:
			return # equip thing
		ActionData.ActionType.INSPECT:
			return # inspect thing

func _on_item_right_clicked(slot_id) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if not slot.slot_data:
		return
		
	context_menu.clear()
	match get_item_action_type(slot.slot_data):
		ActionData.ActionType.CONSUMABLE:
			context_menu.add_item("Use", 0)
			context_menu.add_item("Drop", 1)
		ActionData.ActionType.EQUIPMENT:
			context_menu.add_item("Equip", 0)
			context_menu.add_item("Drop", 1)
		ActionData.ActionType.INSPECT:
			context_menu.add_item("View", 0)
			context_menu.add_item("Drop", 1)
		
	context_menu.set_meta("slot_id", slot_id)
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var rect: Rect2i = Rect2i(mouse_pos.floor(), Vector2i(1,1))
	context_menu.popup(rect)
	

func _on_context_menu_selected(id: int) -> void:
	var slot_id = context_menu.get_meta("slot_id")
	var slot: InventorySlot = inventory_slots[slot_id]
	
	if not slot.slot_data:
		return
	
	match get_item_action_type(slot.slot_data):
		ActionData.ActionType.CONSUMABLE:
			match id:
				0:
					use_collectable(slot_id)
					return
				1:
					drop_collectable(slot_id)
					return
		ActionData.ActionType.EQUIPMENT:
			match id:
				0:
					# equip_collectable return
					return
				1:
					drop_collectable(slot_id)
					return
		ActionData.ActionType.INSPECT:
			match id:
				0:
					# view_collectable return
					return
				1:
					drop_collectable(slot_id)
					return

func get_item_action_type(item_data: ItemData) -> ActionData.ActionType:
	if item_data == null or item_data.item_prefab == null:
		return ActionData.ActionType.INVALID
	
	return item_data.action_data.action_type

# Actions
func use_collectable(slot_id: int) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if not slot.slot_data:
		return
	
	var action_data: ActionData = slot.slot_data.action_data
	match action_data.modifier_name:
		"test_consume":
			interaction_controller.update_test_value(action_data.modifier_value)
	
	inventory_full = not has_free_slot()
	slot.fill_slot(null)

func drop_collectable(slot_id: int) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if not slot.slot_data:
		return

	# 1) Foward Check
	var drop_distance: float = 3.0
	var foward_dir: Vector3 = -raycast.global_transform.basis.y.normalized()
	var target_pos: Vector3 = raycast.global_transform.origin + foward_dir * drop_distance
	var space_state = raycast.get_world_3d().direct_space_state
	
	# 2) obstacle check
	var obstacle_params = PhysicsRayQueryParameters3D.new()
	obstacle_params.from = raycast.global_transform.origin + Vector3(0,0,3)
	obstacle_params.to = target_pos
	
	var obstacle_hit: Dictionary = space_state.intersect_ray(obstacle_params)
	if obstacle_hit:
		print("can't dorp here")
		return
	
	# 3) find the ground
	var ground_params = PhysicsRayQueryParameters3D.new()
	ground_params.from = target_pos + Vector3.UP * 3
	ground_params.to = target_pos - Vector3.UP * 6
	
	var ground_hit: Dictionary = space_state.intersect_ray(ground_params)
	if not ground_hit:
		print("no ground")
		return
	
	var ground_pos: Vector3 = ground_hit.position
	
	var buffer_height: float = 0.5
		
	var instance = slot.slot_data.item_prefab.instantiate() as Node3D
	
	if instance is RigidBody3D:
		get_tree().current_scene.add_child(instance)
		instance.global_transform.origin = ground_pos + Vector3.UP * buffer_height
		instance.freeze = false
		instance.gravity_scale = 1.0
	else:
		instance.global_transform.origin = ground_pos + Vector3.UP * 0.01
	
	inventory_full = not has_free_slot()
	slot.fill_slot(null)
