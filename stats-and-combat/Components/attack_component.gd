extends Node3D
class_name AttackComponent

@export var weapon_holder: Node3D

var _equipped_weapon: WeaponComponent = null
var _attacking : bool = false
var _auto_attack : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_refresh_weapon()

func _process(delta: float) -> void:
	if _auto_attack:
		_try_attack()

func _refresh_weapon():
	if weapon_holder == null:
		return
	for c in weapon_holder.get_children():
		if c is WeaponComponent:
			_equipped_weapon = c
			break

func _try_attack():
	if _attacking:
		return
	if _equipped_weapon == null:
		return
	if not _equipped_weapon.can_attack():
		return
	
	_attacking = true
	
	_equipped_weapon.attack()
	
	await _equipped_weapon.attack_finished
	
	_attacking = false
