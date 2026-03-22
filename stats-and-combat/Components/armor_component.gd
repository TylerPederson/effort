extends Node3D
class_name ArmorComponent


@export var base_flat_reduction : int = 0:
	set(amount):
		base_flat_reduction = amount
		_update_sources()
@export var base_ratio_multiplier : float = 1.0:
	set(amount):
		base_ratio_multiplier = amount
		_update_sources()
var flat_reduction := 0
var ratio_multiplier := 1.0

var equip_flat = 0

const MIN_DAMAGE = 1

var upgrades : Array[BaseArmorStrategy] = []

func _process(delta: float) -> void:
	var live_upgrades : Array[BaseArmorStrategy] = []
	var need_to_update := false
	for upgrade in upgrades:
		upgrade.lifetime -= delta
		if upgrade.lifetime > 0.0:
			live_upgrades.append(upgrade)
		else:
			need_to_update = true
	
	upgrades = live_upgrades
	if need_to_update:
		_update_sources()

func add_armor_source(strategy: BaseArmorStrategy):
	upgrades.append(strategy)
	_update_sources()

func _update_sources():
	var new_flat : int = base_flat_reduction + equip_flat
	var new_ratio := base_ratio_multiplier
	for upgrade in upgrades:
		new_flat = upgrade.apply_flat_reduction(new_flat)
		new_ratio = upgrade.apply_ratio_reduction(new_ratio)
	flat_reduction = new_flat
	ratio_multiplier = new_ratio

func modify_damage(damage: int) -> int:
	var flat_mitigated = damage - flat_reduction
	var ratio_mitigated = floor(flat_mitigated * ratio_multiplier)
	return max(ratio_mitigated, MIN_DAMAGE)

func update_equipment(equip_dict):
	var helm = equip_dict["armor_helm"]
	var body = equip_dict["armor_body"]
	var feet = equip_dict["armor_feet"]
	
	var armor_sum = 0
	if helm:
		armor_sum += helm.action_data.armor_value
	if body:
		armor_sum += body.action_data.armor_value
	if feet:
		armor_sum += feet.action_data.armor_value
	equip_flat = armor_sum
	_update_sources()
