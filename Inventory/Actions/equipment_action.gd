extends ActionData
class_name EquipmentAction

enum EquipmentType {HELM, BODY, FEET, MELEE, RANGED}
enum AttackMethod {STAB, SWING, SHOOT}

@export var equipement_type: EquipmentType
@export var weapon_damage: int
@export var weapon_cooldown: float
@export var weapon_range: float
@export var armor_value: int
@export var attack_type: AttackMethod = AttackMethod.STAB
@export var ammo_packed_scene : PackedScene

func _init() -> void:
	action_type = ActionType.EQUIPMENT
