extends Control
class_name InventoryController

signal equip_change(slot: String, equip_data)

# Inventory Variables
@onready var inventory_grid: GridContainer = %GridContainer
@onready var tooltip_panel: Control = %tooltip_panel
@onready var panel: Panel = $Panel
@onready var context_menu: PopupMenu = PopupMenu.new()
@onready var player_HUD = get_tree().get_first_node_in_group("Player").get_node("Basic_HUD")

var inventory_slot_prefab: PackedScene = load("res://Inventory/inventory_slot.tscn")

var inventory_slots: Array[InventorySlot] = []
var hidden_items: Array[ItemData] = []

var equipped_slots: Dictionary[int, InventorySlot] = {}

# Item data is passed here for reference
var equipped_items: Dictionary[String, ItemData] = {
	"armor_helm": null,
	"armor_body": null,
	"armor_feet": null,
	"weapon_melee": null,
	"weapon_ranged": null,
	"hotbar1": null,
	"hotbar2": null,
	"hotbar3": null
}

var raycast: RayCast3D
var interaction_controller: Node

var inventory_full: bool = false
var item_slot_count: int = 35

func _ready() -> void:
	# Add Inventory slots to the inventory grid and slots array, place Equipment slots
	setup_inventory()
	setup_equip_slots()
	
	# Create right lcick context menu
	add_child(context_menu)
	context_menu.connect("id_pressed", Callable(self, "_on_context_menu_selected"))

# Add slot to grid and inventory array, set id and icon, and connect slot singals to this node
func setup_inventory() -> void:
	for i in item_slot_count:
		var slot = inventory_slot_prefab.instantiate() as InventorySlot
		inventory_grid.add_child(slot)
		slot.inventory_slot_id = i
		slot.default_icon = load("res://Inventory/SlotIcons/slotBase.png")
		slot.update_base_slot()
		slot.on_item_swapped.connect(_on_item_swapped_on_slot)
		slot.on_item_double_clicked.connect(_on_item_double_clicked)
		slot.on_item_right_clicked.connect(_on_item_right_clicked)
		slot.on_item_left_clicked.connect(_on_item_left_clicked)
		inventory_slots.append(slot)

# Place inventory slots where they belong with unqieu ids and icons based on what slots it's supposed to be
# and connect all signals
func setup_equip_slots() -> void:
	for i in range(8):
		var slot = inventory_slot_prefab.instantiate() as InventorySlot
		slot.inventory_slot_id = i + 90
		slot.on_item_swapped.connect(_on_item_swapped_on_slot)
		slot.on_item_double_clicked.connect(_on_item_double_clicked)
		slot.on_item_right_clicked.connect(_on_item_right_clicked)
		slot.on_item_left_clicked.connect(_on_item_left_clicked)
		
		match i:
			0:
				# Hotbar1
				slot.global_position = Vector2(698, 368)
				slot.default_icon = load("res://Inventory/SlotIcons/slotHot.png")
				slot.update_base_slot()
				equipped_slots.set(slot.inventory_slot_id, slot)
			1:
				
				#Hotbar2
				slot.global_position = Vector2(794, 368)
				slot.default_icon = load("res://Inventory/SlotIcons/slotHot.png")
				slot.update_base_slot()
				equipped_slots.set(slot.inventory_slot_id, slot)
			2:
				#Hotbar3
				slot.global_position = Vector2(890, 368)
				slot.default_icon = load("res://Inventory/SlotIcons/slotHot.png")
				slot.update_base_slot()
				equipped_slots.set(slot.inventory_slot_id, slot)
			3:
				#Feet
				slot.global_position = Vector2(794, 240)
				slot.default_icon = load("res://Inventory/SlotIcons/slotFeet.png")
				slot.update_base_slot()
				equipped_slots.set(slot.inventory_slot_id, slot)
			4:
				#Body
				slot.global_position = Vector2(794, 144)
				slot.default_icon = load("res://Inventory/SlotIcons/slotBody.png")
				slot.update_base_slot()
				equipped_slots.set(slot.inventory_slot_id, slot)
			5:
				#Helm
				slot.global_position = Vector2(794, 48)
				slot.default_icon = load("res://Inventory/SlotIcons/slotHelm.png")
				slot.update_base_slot()
				equipped_slots.set(slot.inventory_slot_id, slot)
			6:
				#Weapon
				slot.global_position = Vector2(699, 144)
				slot.default_icon = load("res://Inventory/SlotIcons/slotMelee.png")
				slot.update_base_slot()
				equipped_slots.set(slot.inventory_slot_id, slot)
			7:
				#Ranged
				slot.global_position = Vector2(890, 144)
				slot.default_icon = load("res://Inventory/SlotIcons/slotRanged.png")
				slot.update_base_slot()
				equipped_slots.set(slot.inventory_slot_id, slot)
		panel.add_child(slot)

# Remove all slot children in the inventory grid 
func clear_inventory() -> void:
	var grid_children := inventory_grid.get_children()
	for i in range(grid_children.size() - 1, -1, -1):
		var child = grid_children[i]
		child.queue_free()
	
# Remove all Equipemnt slot children from the inventory
func clear_equip_slots() -> void:
	var panel_children := panel.get_children()
	for i in range(panel_children.size() - 1, -1, -1):
		var child = panel_children[i]
		if child is InventorySlot:
			child.queue_free()

# Based on the method, sort the inventory by hiding itms that don't belong in a seperate array
# Then removing them from te inventory Array. Sorting again puts all hiden items back before sorting
func sort_inventory(method: String) -> void:
	var item_list: Array[ItemData] = []
	for slot in inventory_slots:
		if not slot.slot_filled:
			break
		item_list.append(slot.slot_data)
	
	match method:
		"alpha":
			if not hidden_items.is_empty():
				for item in hidden_items:
					item_list.append(item)
				hidden_items.clear()
			
			item_list.sort_custom(func(a: ItemData, b: ItemData):
				return a.item_name < b.item_name
			)
		"equipment":
			if not hidden_items.is_empty():
				for item in hidden_items:
					item_list.append(item)
				hidden_items.clear()
			
			for i in range(item_list.size() -1, -1, -1):
				if item_list[i].action_data.action_type != ActionData.ActionType.EQUIPMENT:
					hidden_items.append(item_list[i])
					item_list.pop_at(i)
				
		"consumable":
			if not hidden_items.is_empty():
				for item in hidden_items:
					item_list.append(item)
				hidden_items.clear()
			
			for i in range(item_list.size() -1, -1, -1):
				if item_list[i].action_data.action_type != ActionData.ActionType.CONSUMABLE:
					hidden_items.append(item_list[i])
					item_list.pop_at(i)
		"inspect":
			if not hidden_items.is_empty():
				for item in hidden_items:
					item_list.append(item)
				hidden_items.clear()
			
			for i in range(item_list.size() -1, -1, -1):
				if item_list[i].action_data.action_type != ActionData.ActionType.INSPECT:
					hidden_items.append(item_list[i])
					item_list.pop_at(i)
		"all":
			if not hidden_items.is_empty():
				for item in hidden_items:
					item_list.append(item)
				hidden_items.clear()
			
			item_list.sort_custom(func(a: ItemData, b: ItemData):
				return a.action_data.action_type < b.action_data.action_type
			)
	
	clear_inventory()
	inventory_slots.clear()
	setup_inventory()
	
	var i := 0
	for item in item_list:
		inventory_slots[i].fill_slot(item)
		i += 1

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
				stack_item(slot.slot_data, item_data, true)
				slot.update_lable()
				return
		elif not slot.slot_filled:
			slot.fill_slot(item_data)
			inventory_full = not has_free_slot()
			return
		
	inventory_full = true

# Handles checking if an item can stack with the items in a slot
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

# Handle stacking similar items togther, creates a new slot for leftover items if the stack limit is reachded
func stack_item(stored_item: ItemData, incoming_item: ItemData, overflow_slot: bool) -> void:
	var stored := stored_item
	var incoming := incoming_item
	print(stored)
	var remaining_stack: int = stored.stack_limit - stored.items_stacked
	var to_add: int = min(remaining_stack, incoming.items_stacked)
	
	if remaining_stack > 0:
		stored.items_stacked += to_add
		incoming.items_stacked = incoming.items_stacked - to_add
		
	if incoming.items_stacked > 0 and overflow_slot:
		for slot in inventory_slots:
			if not slot.slot_filled:
				slot.fill_slot(incoming_item)
				inventory_full = not has_free_slot()

# Handles checking if the item data can be droppped at the mouse poition when dragging
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var slot: InventorySlot
	if data > inventory_slots.size():
		slot = equipped_slots[data]
	else: 
		slot = inventory_slots[data]
	if not slot.slot_data:
		return false
	
	
	
	return true

# Handles what happens when an item is dropped on top of another one, or outside the inventory (which drops it)
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	drop_collectable(data, true)
	inventory_full = not has_free_slot()

func _on_item_swapped_on_slot(from_slot_id: int, to_slot_id:int) -> void:
	if from_slot_id > inventory_slots.size():
		unequip_item(from_slot_id, to_slot_id)
		return
	
	if to_slot_id > inventory_slots.size():
		equip_item(from_slot_id, to_slot_id)
		return
	
	var to_slot_item: ItemData = inventory_slots[to_slot_id].slot_data
	var from_slot_item: ItemData = inventory_slots[from_slot_id].slot_data
	
	if inventory_slots[from_slot_id].slot_filled:
		if can_stack(inventory_slots[to_slot_id], from_slot_item):
			stack_item(to_slot_item, from_slot_item, false)
			inventory_slots[to_slot_id].update_lable()
			if inventory_slots[from_slot_id].slot_data.items_stacked < 1:
				inventory_full = not has_free_slot()
				inventory_slots[from_slot_id].fill_slot(null)
				align_inventory()
			else:
				inventory_slots[from_slot_id].fill_slot(inventory_slots[from_slot_id].slot_data)
				align_inventory()
			return
	
	inventory_slots[to_slot_id].fill_slot(from_slot_item)
	inventory_slots[from_slot_id].fill_slot(to_slot_item)
	
	# to_slot_item = inventory_slots[to_slot_id].slot_data
	align_inventory()

# Hanles equipping an item to an item slot, only allows items matching the slot type to be equipped
# to_slot_id is -1 when an item is double clicked for automatcally equipping rather than dragging and dropping
func equip_item(from_slot_id: int, to_slot_id:int):
	var from_slot_item: ItemData = inventory_slots[from_slot_id].slot_data
	if to_slot_id < 0:
		match from_slot_item.action_data.equipement_type:
			EquipmentAction.EquipmentType.FEET:
				if equipped_slots[93].slot_filled:
					inventory_slots[from_slot_id].fill_slot(equipped_slots[93].slot_data)
					equipped_slots[93].fill_slot(from_slot_item)
					update_equip_dict(93)
					align_inventory()
					return
				equipped_slots[93].fill_slot(from_slot_item)
				inventory_full = not has_free_slot()
				inventory_slots[from_slot_id].fill_slot(null)
				update_equip_dict(93)
				align_inventory()
			EquipmentAction.EquipmentType.BODY:
				if equipped_slots[94].slot_filled:
					inventory_slots[from_slot_id].fill_slot(equipped_slots[94].slot_data)
					equipped_slots[94].fill_slot(from_slot_item)
					update_equip_dict(94)
					align_inventory()
					return
				equipped_slots[94].fill_slot(from_slot_item)
				inventory_full = not has_free_slot()
				inventory_slots[from_slot_id].fill_slot(null)
				update_equip_dict(94)
				align_inventory()
			EquipmentAction.EquipmentType.HELM:
				if equipped_slots[95].slot_filled:
					inventory_slots[from_slot_id].fill_slot(equipped_slots[95].slot_data)
					equipped_slots[95].fill_slot(from_slot_item)
					update_equip_dict(95)
					align_inventory()
					return
				equipped_slots[95].fill_slot(from_slot_item)
				inventory_full = not has_free_slot()
				inventory_slots[from_slot_id].fill_slot(null)
				update_equip_dict(95)
				align_inventory()
			EquipmentAction.EquipmentType.MELEE:
				if equipped_slots[96].slot_filled:
					inventory_slots[from_slot_id].fill_slot(equipped_slots[96].slot_data)
					equipped_slots[96].fill_slot(from_slot_item)
					update_equip_dict(96)
					align_inventory()
					return
				equipped_slots[96].fill_slot(from_slot_item)
				inventory_full = not has_free_slot()
				inventory_slots[from_slot_id].fill_slot(null)
				update_equip_dict(96)
				align_inventory()
			EquipmentAction.EquipmentType.RANGED:
				if equipped_slots[97].slot_filled:
					inventory_slots[from_slot_id].fill_slot(equipped_slots[97].slot_data)
					equipped_slots[97].fill_slot(from_slot_item)
					update_equip_dict(97)
					align_inventory()
					return
				equipped_slots[97].fill_slot(from_slot_item)
				inventory_full = not has_free_slot()
				inventory_slots[from_slot_id].fill_slot(null)
				update_equip_dict(97)
				align_inventory()
		return
	
	var to_slot_item: ItemData = equipped_slots[to_slot_id].slot_data
	
	if not equipment_matched(from_slot_item, to_slot_id):
		return
	
	if equipped_slots[to_slot_id].slot_filled:
		equipped_slots[to_slot_id].fill_slot(from_slot_item)
		inventory_slots[from_slot_id].fill_slot(to_slot_item)
	else:
		equipped_slots[to_slot_id].fill_slot(from_slot_item)
		inventory_full = not has_free_slot()
		inventory_slots[from_slot_id].fill_slot(null)
	
	update_equip_dict(to_slot_id)
	align_inventory()

# Handles uneqipping an item from the equipemnt slot back into the inventory, and swapping out equipment
# if dragged onto another item of the same type. to_slot_id is -1 when quick unequipping by double clicking the item
func unequip_item(from_slot_id: int, to_slot_id:int):
	if to_slot_id < 0:
		pickup_item(equipped_slots[from_slot_id].slot_data)
		equipped_slots[from_slot_id].fill_slot(null)
		update_equip_dict(from_slot_id)
		align_inventory()
		return
	
	var to_slot: InventorySlot
	var from_slot:InventorySlot
	
	if to_slot_id > inventory_slots.size():
		to_slot = equipped_slots[to_slot_id]
	else:
		to_slot = inventory_slots[to_slot_id]
	
	if from_slot_id > inventory_slots.size():
		from_slot = equipped_slots[from_slot_id]
	else:
		from_slot = inventory_slots[from_slot_id]
	
	var to_slot_item: ItemData = to_slot.slot_data
	var from_slot_item: ItemData = from_slot.slot_data
	
	if to_slot.slot_filled:
		if not equipment_matched(to_slot_item, from_slot_id):
			return
		
		to_slot.fill_slot(from_slot_item)
		from_slot.fill_slot(to_slot_item)
	else:
		if equipment_matched(from_slot_item, to_slot_id):
			to_slot.fill_slot(from_slot_item)
			from_slot.fill_slot(null)
	
	update_equip_dict(from_slot_id)
	update_equip_dict(to_slot_id)
	align_inventory()
	
# Checks if the equipment passed into this function matches the slot it is attempting to be put into
func equipment_matched(item:ItemData, equip_id:int) -> bool:
	match equip_id:
		90, 91, 92:
			if item.action_data.action_type == ActionData.ActionType.CONSUMABLE:
				return true
			
			return false
		93:
			if item.action_data.action_type == ActionData.ActionType.EQUIPMENT:
				if item.action_data.equipement_type == EquipmentAction.EquipmentType.FEET:
					return true
				return false
			return false
		94:
			if item.action_data.action_type == ActionData.ActionType.EQUIPMENT:
				if item.action_data.equipement_type == EquipmentAction.EquipmentType.BODY:
					return true
				return false
			return false
		95:
			if item.action_data.action_type == ActionData.ActionType.EQUIPMENT:
				if item.action_data.equipement_type == EquipmentAction.EquipmentType.HELM:
					return true
				return false
			return false
		96:
			if item.action_data.action_type == ActionData.ActionType.EQUIPMENT:
				if item.action_data.equipement_type == EquipmentAction.EquipmentType.MELEE:
					return true
				return false
			return false
		97:
			if item.action_data.action_type == ActionData.ActionType.EQUIPMENT:
				if item.action_data.equipement_type == EquipmentAction.EquipmentType.RANGED:
					return true
				return false
			return false
	return true

# Updates equipped_items dictionary with the item to be able to pass references to other nodes
func update_equip_dict(slot_id: int):
	if slot_id < 90:
		return
	
	var item_data: ItemData = equipped_slots[slot_id].slot_data
	var item_present: bool = true
	
	if not item_data:
		item_present = false
	
	match slot_id:
		90:
			if item_present:
				equipped_items["hotbar1"] = item_data
			else:
				equipped_items["hotbar1"] = null
		91:
			if item_present:
				equipped_items["hotbar2"] = item_data
			else:
				equipped_items["hotbar2"] = null
		92:
			if item_present:
				equipped_items["hotbar3"] = item_data
			else:
				equipped_items["hotbar3"] = null
		93:
			if item_present:
				equipped_items["armor_feet"] = item_data
			else:
				equipped_items["armor_feet"] = null
			equip_change.emit("armor_feet", equipped_items)
			print("moley")
		94:
			if item_present:
				equipped_items["armor_body"] = item_data
			else:
				equipped_items["armor_body"] = null
			equip_change.emit("armor_body", equipped_items)
		95:
			if item_present:
				equipped_items["armor_helm"] = item_data
			else:
				equipped_items["armor_helm"] = null
			equip_change.emit("armor_helm", equipped_items)
		96:
			if item_present:
				equipped_items["weapon_melee"] = item_data
			else:
				equipped_items["weapon_melee"] = null
			equip_change.emit("weapon_melee", equipped_items)
		97:
			if item_present:
				equipped_items["weapon_ranged"] = item_data
			else:
				equipped_items["weapon_ranged"] = null
			equip_change.emit("weapon_ranged", equipped_items)
	


# Calls align slot for every slot in the inventory
func align_inventory() -> void:
	for slot in inventory_slots:
		align_slot(slot.inventory_slot_id)

# Aligns the passed slot as far up the inventory array as possible
# used so there are no gaps in the inventory after moving or using an item
func align_slot(init_slot_id: int) -> void:
	if not inventory_slots[init_slot_id].slot_filled:
		return
	
	var prev_empty: bool = true
	var next_open_slot_id: int
	var i = 1
	while prev_empty:
		var prev := inventory_slots[init_slot_id - i]
		if prev.slot_filled:
			next_open_slot_id = (init_slot_id - i) + 1
			
			if next_open_slot_id == init_slot_id: break
			
			inventory_slots[next_open_slot_id].fill_slot(inventory_slots[init_slot_id].slot_data)
			inventory_slots[init_slot_id].fill_slot(null)
			break
		if (init_slot_id - i) <= 0:
			next_open_slot_id = 0
			
			if next_open_slot_id == init_slot_id: break
			
			inventory_slots[next_open_slot_id].fill_slot(inventory_slots[init_slot_id].slot_data)
			inventory_slots[init_slot_id].fill_slot(null)
			break
		i += 1

# Handles double_clicks on slots
func _on_item_double_clicked(slot_id) -> void:
	var equipped_item: bool
	var slot: InventorySlot
	if slot_id > inventory_slots.size():
		slot = equipped_slots[slot_id]
		equipped_item = true
	else: 
		slot = inventory_slots[slot_id]
		equipped_item = false
		
	if not slot.slot_data:
		return
	
	match get_item_action_type(slot.slot_data):
		ActionData.ActionType.CONSUMABLE:
			use_collectable(slot_id)
		ActionData.ActionType.EQUIPMENT:
			if equipped_item:
				unequip_item(slot_id, -1)
			else:
				equip_item(slot_id, -1)
		ActionData.ActionType.INSPECT:
			return # inspect thing

# Handles updating the tooltip panel when a slot is left clicked with an item in it
func _on_item_left_clicked(slot_id: int) -> void:
	var slot: InventorySlot
	if slot_id > inventory_slots.size():
		slot = equipped_slots[slot_id]
	else: 
		slot = inventory_slots[slot_id]
	
	if not slot.slot_data:
		return
	if slot.slot_filled:
		tooltip_panel.update_panel(slot.slot_data)

# Handles the context menu when a slot with an item is right clicked
func _on_item_right_clicked(slot_id: int) -> void:
	var equipped_item: bool
	var slot: InventorySlot
	if slot_id > inventory_slots.size():
		slot = equipped_slots[slot_id]
		equipped_item = true
	else: 
		slot = inventory_slots[slot_id]
		equipped_item= false
	
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
			if equipped_item:
				context_menu.add_item("Unequip", 2)
				context_menu.add_item("Drop", 1)
			else:
				context_menu.add_item("Equip", 0)
				context_menu.add_item("Drop", 1)
		ActionData.ActionType.INSPECT:
			context_menu.add_item("View", 0)
			context_menu.add_item("Drop", 1)
		
	context_menu.set_meta("slot_id", slot_id)
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var rect: Rect2i = Rect2i(mouse_pos.floor(), Vector2i(1,1))
	context_menu.popup(rect)

# Handles what happens when a context menu option is clicked
func _on_context_menu_selected(id: int) -> void:
	var slot_id = context_menu.get_meta("slot_id")
	
	var slot: InventorySlot
	if slot_id > inventory_slots.size():
		slot = equipped_slots[slot_id]
	else: 
		slot = inventory_slots[slot_id]
	
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
					equip_item(slot_id, -1)
					return
				1:
					drop_collectable(slot_id, false)
					return
				2:
					unequip_item(slot_id, -1)
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

# hide the tooltip Panel
func hide_panel() -> void:
	tooltip_panel.hide_panel()

# Grabs the item type, if it exists
func get_item_action_type(item_data: ItemData) -> ActionData.ActionType:
	if item_data == null or item_data.item_prefab == null:
		return ActionData.ActionType.INVALID
	
	return item_data.action_data.action_type

# Handles using a consumable item
func use_collectable(slot_id: int) -> void:
	var slot: InventorySlot
	var equipped_item: bool
	if slot_id > inventory_slots.size():
		slot = equipped_slots[slot_id]
		equipped_item = true
	else: 
		slot = inventory_slots[slot_id]
		equipped_item = false
	
	if not slot.slot_data:
		return
	
	if %ConsumableTimer.time_left > 0.0:
		return
	
	# Add all consumable item actions here!
	var action_data: ActionData = slot.slot_data.action_data
	match action_data.modifier_name:
			"modify_health":
				if interaction_controller.modify_health(action_data.modifier_value):
					%ConsumableTimer.start()
				else:
					player_HUD.display_info("Already Full Health", 2.0)
					return
			"modify_stamina":
				if interaction_controller.modify_stamina(action_data.modifier_value):
					%ConsumableTimer.start()
				else:
					player_HUD.display_info("Already Full Stamina", 2.0)
					return
			"modify_armor":
				%ConsumableTimer.start()
				interaction_controller.modify_armor(action_data.modifier_value)
	
	slot.slot_data.items_stacked -= 1
	slot.update_lable()
	
	if slot.slot_data.items_stacked < 1:
		inventory_full = not has_free_slot()
		slot.fill_slot(null)
		if equipped_item:
			update_equip_dict(slot_id)
	align_inventory()

# Handles dropping an item and adding back into the world as a 3d object
func drop_collectable(slot_id: int, all: bool) -> void:
	var equipped_item: bool
	var slot: InventorySlot
	if slot_id > inventory_slots.size():
		slot = equipped_slots[slot_id]
		equipped_item = true
	else: 
		slot = inventory_slots[slot_id]
		equipped_item = false
		
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
		return
	
	# 3) find the ground
	var ground_params = PhysicsRayQueryParameters3D.new()
	ground_params.from = target_pos + Vector3.UP * 3
	ground_params.to = target_pos - Vector3.UP * 6
	
	var ground_hit: Dictionary = space_state.intersect_ray(ground_params)
	if not ground_hit:
		return
	
	var ground_pos: Vector3 = ground_hit.position
	
	var buffer_height: float = 0.5
		
	var instance = slot.slot_data.item_prefab.instantiate() as Node3D
	var ic = instance.get_node("ItemInteract")
	
	if all:
		ic.item_data.items_stacked = slot.slot_data.items_stacked
		
		if equipped_item:
			inventory_full = not has_free_slot()
		slot.fill_slot(null)
	else:
		ic.item_data.items_stacked = 1
		slot.slot_data.items_stacked -= 1
		slot.update_lable()
		if slot.slot_data.items_stacked < 1:
			if equipped_item:
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

# Sort Button signals
func _on_alpha_sort_pressed() -> void:
	sort_inventory("alpha") # Sorts all items alphabetically

func _on_equipment_sort_pressed() -> void:
	sort_inventory("equipment") # only shows equipment

func _on_comsumable_sort_pressed() -> void:
	sort_inventory("consumable") # Only shows consumables

func _on_inspect_sort_pressed() -> void:
	sort_inventory("inspect") # Only shows inspectable items

func _on_all_sort_pressed() -> void:
	sort_inventory("all") # Sorts all items by type
