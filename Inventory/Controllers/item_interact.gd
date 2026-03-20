extends Node

@export var item_data: ItemData
@export var collect_sound_effect: AudioStreamMP3
@onready var label_3d: Label3D = $"../Label3D"

signal item_collected(item: Node)

func _ready() -> void:
	var scene_path = get_parent().scene_file_path
	item_data.item_prefab = load(scene_path)

# Called when item is interacted with
func interact() -> void:
	emit_signal("item_collected", get_parent())
