extends Node3D
class_name AttackComponent

# All objects that can attack expect there to be a weapon_holder node that
# holds the transform where the weapon will be at. The weapon_holder should
# have a WeaponComponent child.
@export var weapon_holder: Node3D

var _equipped_weapon: WeaponComponent = null
var _attacking : bool = false
var _auto_attack : bool = false
var bonus_damage : int = 0
var cooldown_reduction : float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_refresh_weapon()

# The attack_component can attempt to attack constantly if auto attack is enabled
func _process(delta: float) -> void:
	if _auto_attack:
		_try_attack()

# Grabs the expected weapon component from the weapon_holder.
func _refresh_weapon():
	if weapon_holder == null:
		return
	for c in weapon_holder.get_children():
		if c is WeaponComponent:
			_equipped_weapon = c
			break

# If a weapon component is available, then attempt to use it in an attack
func _try_attack():
	if _attacking:
		return
	if _equipped_weapon == null:
		return
	if not _equipped_weapon.can_attack():
		return
	
	_attacking = true
	
	_equipped_weapon.attack(bonus_damage, cooldown_reduction)
	
	await _equipped_weapon.attack_finished
	
	_attacking = false

func set_auto_attack(enable: bool):
	_auto_attack = enable

func _on_attack_action():
	_try_attack()
