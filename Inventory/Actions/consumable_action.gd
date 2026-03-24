extends ActionData
class_name ConsuambleAction

@export var modifier_name: String
@export var modifier_value: int

func _init() -> void:
	action_type = ActionType.CONSUMABLE
