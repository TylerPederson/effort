extends Control
class_name InventoryController

# Inventory Variables
@onready var inventory_grid: GridContainer = %GridContainer
@onready var context_menu: PopupMenu = PopupMenu.new()

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
			return #use thing
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
					# use_collectable return
					return
				1:
					# drop_collectable return
					return
		ActionData.ActionType.EQUIPMENT:
			match id:
				0:
					# equip_collectable return
					return
				1:
					# drop_collectable return
					return
		ActionData.ActionType.INSPECT:
			match id:
				0:
					# view_collectable return
					return
				1:
					# drop_collectable return
					return

func get_item_action_type(item_data: ItemData) -> ActionData.ActionType:
	if item_data == null or item_data.item_prefab == null:
		return ActionData.ActionType.INVALID
	
	return item_data.action_data.action_type
