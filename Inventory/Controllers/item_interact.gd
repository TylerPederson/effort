extends Node
class_name ItemInteract

@export var item_data: ItemData
@export var collect_sound_effect: AudioStreamMP3

signal item_collected(item: Node)
signal triggered
var remove_from_world_on_collect : bool = true

func _ready() -> void:
	var scene_path = get_parent().scene_file_path
	item_data.item_prefab = load(scene_path)

# Called when item is interacted with
func interact() -> void:
	emit_signal("item_collected", get_parent())
	emit_signal("triggered")
