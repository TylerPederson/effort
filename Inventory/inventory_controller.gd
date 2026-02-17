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
