extends Node

@export var item_data: ItemData
@export var collect_sound_effect: AudioStreamMP3

signal item_collected(item: Node)

# Called when item is interacted with
func interact() -> void:
	print("singal emitted")
	emit_signal("item_collected", get_parent())
