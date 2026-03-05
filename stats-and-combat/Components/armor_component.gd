extends Node3D
class_name ArmorComponent


@export var flat_reduction : int = 0
@export var ratio_multiplier : float = 1.0
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
	var new_flat := 0
	var new_ratio := 1.0
	for upgrade in upgrades:
		new_flat = upgrade.apply_flat_reduction(new_flat)
		new_ratio = upgrade.apply_ratio_reduction(new_ratio)
	flat_reduction = new_flat
	ratio_multiplier = new_ratio

func modify_damage(damage: int) -> int:
	var flat_mitigated = damage - flat_reduction
	var ratio_mitigated = floor(flat_mitigated * ratio_multiplier)
	return max(ratio_mitigated, MIN_DAMAGE)
