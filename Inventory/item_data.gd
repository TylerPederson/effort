extends Resource
class_name ItemData

@export var item_name: String
@export var Item_icon: Texture2D
@export var action_data: ActionData
@export var stack_limit: int
@export var item_desc: String

var item_prefab: PackedScene
var items_stacked: int = 1
