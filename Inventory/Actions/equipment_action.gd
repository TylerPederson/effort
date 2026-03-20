extends ActionData
class_name EquipmentAction

enum EquipmentType {HELM, BODY, FEET, MELEE, RANGED}

@export var equipement_type: EquipmentType
@export var weapon_damage: int
@export var weapon_cooldown: float
@export var weapon_range: float
@export var armor_value: int

func _init() -> void:
	action_type = ActionType.EQUIPMENT
