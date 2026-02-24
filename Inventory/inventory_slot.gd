extends Control
class_name InventorySlot

@onready var icon_slot: TextureRect = $TextureRect
var slot_filled: bool = false
var slot_data: ItemData

# Called when item is to be put into an item slot
func fill_slot(item_data: ItemData) -> void:
	slot_data = item_data
	if slot_data:
		slot_filled = true
		icon_slot.texture = item_data.Item_icon
		
	else:
		slot_filled = false
		icon_slot.texture = null
