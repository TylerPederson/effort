extends Resource
class_name ItemData

@export var item_name: String
@export var Item_icon: Texture2D
@export var action_data: ActionData

var item_prefab: PackedScene
var parent_node: Node

signal item_collected(item: Node)

func interact() -> void:
	print("singal emitted")
	emit_signal("item_collected", parent_node)
