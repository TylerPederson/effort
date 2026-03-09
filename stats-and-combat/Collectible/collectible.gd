extends Area3D
class_name Collectible

enum TYPE {
	HP_REGEN,
	HP_BOOST,
	STAMINA_REGEN,
	STAMINA_BOOST,
	BONUS_FLAT_ARMOR,
	BONUS_RATIO_ARMOR,
	SPRINT_USE_RATIO,
	SPRINT_SPEED_BOOST,
	DAMAGE_BOOST,
	DAMAGE_COOLDOWN
}

const upgrade_dict = {
	TYPE.HP_REGEN : 1,
	TYPE.HP_BOOST : 50,
	TYPE.STAMINA_REGEN : 1.0,
	TYPE.STAMINA_BOOST : 10,
	TYPE.BONUS_FLAT_ARMOR : 3,
	TYPE.BONUS_RATIO_ARMOR : 0.8,
	TYPE.SPRINT_USE_RATIO : 0.7,
	TYPE.SPRINT_SPEED_BOOST : 1.35,
	TYPE.DAMAGE_BOOST : 5,
	TYPE.DAMAGE_COOLDOWN : 0.75
}

@export var type : TYPE = TYPE.HP_REGEN

func _ready() -> void:
	set_data()
	connect_signal()

func set_data():
	pass

func connect_signal() -> void:
	connect("body_entered", collect)

func collect(body : Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	
	var player = body
	var child_components = player.get_children()
	
	match type:
		TYPE.HP_REGEN:
			for child in child_components:
				if child is HealthComponent:
					child.regen = upgrade_dict[type]
					print("HP_REGEN")
		TYPE.HP_BOOST:
			for child in child_components:
				if child is HealthComponent:
					child.bonus_hp = upgrade_dict[type]
					print("HP_BOOST")
		TYPE.STAMINA_REGEN:
			for child in child_components:
				if child is StaminaComponent:
					child.stamina_regen_rate_bonus = upgrade_dict[type]
					print("STAMINA_REGEN")
		TYPE.STAMINA_BOOST:
			for child in child_components:
				if child is StaminaComponent:
					child.bonus_stamina = upgrade_dict[type]
					print("STAMINA_BOOST")
		TYPE.BONUS_FLAT_ARMOR:
			for child in child_components:
				if child is ArmorComponent:
					child.base_flat_reduction = upgrade_dict[type]
					print("BONUS_FLAT_ARMOR")
		TYPE.BONUS_RATIO_ARMOR:
			for child in child_components:
				if child is ArmorComponent:
					child.base_ratio_multiplier = upgrade_dict[type]
					print("BONUS_RATIO_ARMOR")
		TYPE.SPRINT_USE_RATIO:
			for child in child_components:
				if child is SprintComponent:
					child.stamina_use_ratio = upgrade_dict[type]
					print("SPRINT_USE_RATIO")
		TYPE.SPRINT_SPEED_BOOST:
			for child in child_components:
				if child is SprintComponent:
					child.sprint_bonus_multiplier = upgrade_dict[type]
					print("SPRINT_SPEED_BOOST")
		TYPE.DAMAGE_BOOST:
			for child in child_components:
				if child is AttackComponent:
					child.bonus_damage = upgrade_dict[type]
					print("DAMAGE_BOOST")
		TYPE.DAMAGE_COOLDOWN:
			for child in child_components:
				if child is AttackComponent:
					child.cooldown_reduction = upgrade_dict[type]
					print("DAMAGE_COOLDOWN")
		_:
			print("collect error")
	queue_free()
