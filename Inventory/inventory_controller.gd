extends Control
class_name InventoryController

# Inventory Variables
var inventory_slot_prefab: PackedScene = load("res://Inventory/inventory_slot.tscn")

var item_slot_count: int = 20
var inventory_slots: Array[InventorySlot] = []
var inventory_full: bool = false

@onready var inventory_grid: GridContainer = %GridContainer

func _ready() -> void:
	# add Inventory slots to the inventory grid and slorts array
	for i in item_slot_count:
		var slot = inventory_slot_prefab.instantiate() as InventorySlot
		inventory_grid.add_child(slot)
		# add slot ID
		# Link drag/drop and use item
		inventory_slots.append(slot)

# Handles adding an item into the item slot and determining empty slots
func pickup_item(item_data: ItemData) -> void:
	for slot in inventory_slots:
		if not slot.slot_filled:
			slot.fill_slot(item_data)
			inventory_full = not has_free_slot()
			return
	inventory_full = true

# Checks if there is an available slot for an item to go into
func has_free_slot() -> bool:
	for slot in inventory_slots:
		if slot.slot_data == null:
			return true
	return false
