extends Node
class_name WeaponComponent

signal attack_finished

enum WeaponAttackStyle {
	STAB,
	SWING,
	SHOOT
}


var attackStyle : WeaponAttackStyle = WeaponAttackStyle.STAB

@export var damage : int = 1
@export var cooldown : float = 0.5
@export var attack_range : float = 1.5
var ready_to_use : bool = true
var attacking : bool = false

@onready var timer: Timer = $Timer
@onready var attack_cast: RayCast3D = %AttackCast

func set_attack_style(style: String):
	match style.to_lower():
		"stab":
			attackStyle = WeaponAttackStyle.STAB
		"swing":
			attackStyle = WeaponAttackStyle.SWING
		"shoot":
			attackStyle = WeaponAttackStyle.SHOOT
		_:
			attackStyle = WeaponAttackStyle.STAB


func _physics_process(delta: float) -> void:
	if attacking:
		attack_cast.deal_damage(damage)

func can_attack() -> bool:
	return ready_to_use

func attack():
	ready_to_use = false
	timer.start(cooldown)
	attack_cast.clear_exceptions()
	
	match attackStyle:
		WeaponAttackStyle.STAB:
			_stab()
		WeaponAttackStyle.SWING:
			_swing()
		WeaponAttackStyle.SHOOT:
			_shoot()


func _on_timer_timeout() -> void:
	ready_to_use = true
	attacking = false
	attack_cast.enabled = false
	attack_finished.emit()


func _stab():
	attacking = true
	attack_cast.enabled = true
	attack_cast.target_position = -Vector3.FORWARD * attack_range

func _swing():
	pass

func _shoot():
	pass
