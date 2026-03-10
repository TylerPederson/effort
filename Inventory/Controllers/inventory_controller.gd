extends Control
class_name InventoryController

# Inventory Variables
@onready var raycast: RayCast3D = $"../../../RayCast3D"
@onready var inventory_grid: GridContainer = %GridContainer
@onready var context_menu: PopupMenu = PopupMenu.new()
@onready var interaction_controller: Node = $"../../../InteractionController"
@onready var tooltip_panel: Control = $Panel/tooltip_panel

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
		slot.on_item_left_clicked.connect(_on_item_left_clicked)
		inventory_slots.append(slot)
		
	add_child(context_menu)
	context_menu.connect("id_pressed", Callable(self, "_on_context_menu_selected"))

func clear_inv_grid() -> void:
	var children := inventory_grid.get_children()
	
	print("before" + str(inventory_slots))
	for i in range(children.size() - 1, -1, -1):
		var child = children[i]
		child.queue_free()
	print("after" + str(inventory_slots))

# Checks if there is an available slot for an item to go into
func has_free_slot() -> bool:
	for slot in inventory_slots:
		if slot.slot_data == null:
			return true
	return false

# Handles adding an item into the item slot and determining empty slots
func pickup_item(item_data: ItemData) -> void:
	for slot in inventory_slots:
		if can_stack(slot, item_data):
				print("stack items called")
				stack_item(slot.slot_data, item_data, true)
				slot.update_lable()
				print("stack items complete")
				print("New Stack: " + str(slot.slot_data.items_stacked))
				
				return
		elif not slot.slot_filled:
			print("item can't stack, start new stack")
			slot.fill_slot(item_data)
			inventory_full = not has_free_slot()
			return
	inventory_full = true

func can_stack(curr_slot: InventorySlot, inc_item: ItemData):
	var names_matched: bool
	var lim_reached: bool
	
	if curr_slot.slot_data == null:
		return false
	
	if curr_slot.slot_data.item_name == inc_item.item_name:
		names_matched = true
	else: 
		names_matched = false
	
	if curr_slot.slot_data.items_stacked < curr_slot.slot_data.stack_limit:
		lim_reached = false
	else: 
		lim_reached = true
	
	return true if names_matched and not lim_reached else false

func stack_item(stored_item: ItemData, incoming_item: ItemData, overflow_slot: bool) -> void:
	var stored := stored_item
	var incoming := incoming_item
	
	var remaining_stack: int = stored.stack_limit - stored.items_stacked
	print("Can stack: " + str(remaining_stack) + " items")
	print(str(incoming.items_stacked) + " incoming items")
	var to_add: int = min(remaining_stack, incoming.items_stacked)
	print("attempting to add: " + str(to_add) + " items")
	
	if remaining_stack > 0:
		stored.items_stacked += to_add
		print("new item stack: " + str(stored.items_stacked))
		incoming.items_stacked = incoming.items_stacked - to_add
		print("current item stack post leftover update: " + str(stored.items_stacked))
		print("leftover items: " + str(incoming.items_stacked))
		
		# incoming.items_stacked = 0
	if incoming.items_stacked > 0 and overflow_slot:
		print("Placing leftover stack")
		for slot in inventory_slots:
			if not slot.slot_filled:
				slot.fill_slot(incoming_item)
				inventory_full = not has_free_slot()
				print("Added new stack")
				return
	#print(str(stored.items_stacked))
	# return stored

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var slot: InventorySlot = inventory_slots[data]
	if not slot.slot_data:
		return false
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	drop_collectable(data, true)
	inventory_full = not has_free_slot()

func _on_item_swapped_on_slot(from_slot_id: int, to_slot_id:int) -> void:
	var to_slot_item: ItemData = inventory_slots[to_slot_id].slot_data
	var from_slot_item: ItemData = inventory_slots[from_slot_id].slot_data
	
	if inventory_slots[from_slot_id].slot_filled:
		if can_stack(inventory_slots[to_slot_id], from_slot_item):
			stack_item(to_slot_item, from_slot_item, false)
			inventory_slots[to_slot_id].update_lable()
			if inventory_slots[from_slot_id].slot_data.items_stacked < 1:
				inventory_full = not has_free_slot()
				inventory_slots[from_slot_id].fill_slot(null)
			else:
				inventory_slots[from_slot_id].fill_slot(inventory_slots[from_slot_id].slot_data)
			return
	
	inventory_slots[to_slot_id].fill_slot(from_slot_item)
	inventory_slots[from_slot_id].fill_slot(to_slot_item)
	
	# to_slot_item = inventory_slots[to_slot_id].slot_data
	align_inventory()

func align_inventory() -> void:
	for slot in inventory_slots:
		if slot.slot_data != null:
			align_slot(slot.inventory_slot_id)

func align_slot(init_slot_id: int) -> void:
	print("Starting align")
	var prev_empty: bool = true
	var next_open_slot_id: int
	var i = 1
	while prev_empty:
		var prev := inventory_slots[init_slot_id - i]
		print ("Checking slot id:" + str(init_slot_id - i))
		if prev.slot_filled:
			print("Slot was filled, breaking")
			next_open_slot_id = (init_slot_id - i) + 1
			
			if next_open_slot_id == init_slot_id: break
			
			print("aligning to id: " + str(next_open_slot_id))
			inventory_slots[next_open_slot_id].fill_slot(inventory_slots[init_slot_id].slot_data)
			inventory_slots[init_slot_id].fill_slot(null)
			break
		if (init_slot_id - i) <= 0:
			print("Slot was id 0, breaking")
			next_open_slot_id = 0
			
			if next_open_slot_id == init_slot_id: break
			
			print("Aligning to id 0")
			inventory_slots[next_open_slot_id].fill_slot(inventory_slots[init_slot_id].slot_data)
			inventory_slots[init_slot_id].fill_slot(null)
			break
		i += 1
	print("slot align complete")

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

func _on_item_left_clicked(slot_id: int) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if slot.slot_filled:
		tooltip_panel.update_panel(slot.slot_data)

func _on_item_right_clicked(slot_id: int) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if not slot.slot_data:
		return
		
	context_menu.clear()
	match get_item_action_type(slot.slot_data):
		ActionData.ActionType.CONSUMABLE:
			context_menu.add_item("Use", 0)
			context_menu.add_item("Drop", 1)
			if slot.slot_data.items_stacked > 1:
				context_menu.add_item("Drop Stack", 2)
		ActionData.ActionType.EQUIPMENT:
			context_menu.add_item("Equip", 0)
			context_menu.add_item("Drop", 1)
			if slot.slot_data.items_stacked > 1:
				context_menu.add_item("Drop Stack", 2)
		ActionData.ActionType.INSPECT:
			context_menu.add_item("View", 0)
			context_menu.add_item("Drop", 1)
			if slot.slot_data.items_stacked > 1:
				context_menu.add_item("Drop Stack", 2)
		
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
					drop_collectable(slot_id, false)
					return
				2:
					drop_collectable(slot_id, true)
					return
		ActionData.ActionType.EQUIPMENT:
			match id:
				0:
					# equip_collectable return
					return
				1:
					drop_collectable(slot_id, false)
					return
				2:
					drop_collectable(slot_id, true)
					return
		ActionData.ActionType.INSPECT:
			match id:
				0:
					# view_collectable return
					return
				1:
					drop_collectable(slot_id, false)
					return
				2:
					drop_collectable(slot_id, true)
					return

func hide_panel() -> void:
	tooltip_panel.hide_panel()

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
		"test_unique_consume":
			interaction_controller.update_test_value(-action_data.modifier_value)
	
	slot.slot_data.items_stacked -= 1
	slot.update_lable()
	
	if slot.slot_data.items_stacked < 1:
		inventory_full = not has_free_slot()
		slot.fill_slot(null)
	align_inventory()


func drop_collectable(slot_id: int, all: bool) -> void:
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
	obstacle_params.from = raycast.global_transform.origin + Vector3(0,3,3)
	obstacle_params.to = target_pos + Vector3(0,3,0)
	
	var obstacle_hit: Dictionary = space_state.intersect_ray(obstacle_params)
	if obstacle_hit:
		print("can't drop here")
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
	var ic = instance.get_node("ItemInteract")
	
	if all:
		ic.item_data.items_stacked = slot.slot_data.items_stacked
		
		inventory_full = not has_free_slot()
		slot.fill_slot(null)
	else:
		ic.item_data.items_stacked = 1
		slot.slot_data.items_stacked -= 1
		slot.update_lable()
		if slot.slot_data.items_stacked < 1:
			inventory_full = not has_free_slot()
			slot.fill_slot(null)
		
	
	align_inventory()
	
	if instance is RigidBody3D:
		get_tree().current_scene.add_child(instance)
		instance.global_transform.origin = ground_pos + Vector3.UP * buffer_height
		instance.freeze = false
		instance.gravity_scale = 1.0
	else:
		instance.global_transform.origin = ground_pos + Vector3.UP * 0.01
