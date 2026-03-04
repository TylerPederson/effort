extends Node3D
class_name WeaponComponent

signal attack_finished

enum WeaponAttackStyle {
	STAB,
	SWING,
	SHOOT
}


var attackStyle : WeaponAttackStyle = WeaponAttackStyle.SHOOT

@export var projectile_scene : PackedScene
@export var damage : int = 1
@export var cooldown : float = 0.5
@export var attack_range : float = 1.5
var ready_to_use : bool = true
var attacking : bool = false

@onready var timer: Timer = $Timer
@onready var attack_cast: RayCast3D = %AttackCast
@onready var swing_path_follow: PathFollow3D = %SwingPathFollow

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
		
		if attackStyle == WeaponAttackStyle.SWING:
			swing_path_follow.progress_ratio += delta / cooldown
			attack_cast.position = swing_path_follow.position

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
	attack_cast.position = transform.origin
	attack_cast.target_position = Vector3.FORWARD * attack_range

func _swing():
	attacking = true
	attack_cast.enabled = true
	swing_path_follow.progress_ratio = 0.0
	attack_cast.position = swing_path_follow.position
	attack_cast.target_position = Vector3.FORWARD * attack_range

func _shoot():
	attacking = true
	attack_cast.enabled = false
	var projectile = projectile_scene.instantiate()
	get_tree().get_root().add_child(projectile)
	projectile.global_position = global_position
	projectile.global_transform.basis = global_transform.basis
	projectile.global_position += global_transform.basis * Vector3.FORWARD * 1.5
	projectile.set_damage(damage)
	projectile.set_speed(attack_range)
