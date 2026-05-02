extends Node3D
class_name WeaponComponent

signal attack_start(cooldown: float)
signal attack_finished
signal attack_started(time)


enum WeaponAttackStyle {
	STAB,
	SWING,
	SHOOT
}


var attackStyle : WeaponAttackStyle = WeaponAttackStyle.SHOOT

@export var projectile_scene : PackedScene = null
@export var damage : int = 1
@export var cooldown : float = 0.5
@export var attack_range : float = 1.5
@export var weilder : Node3D
var ready_to_use : bool = true
var attacking : bool = false
var player = null

@onready var timer: Timer = %Timer
@onready var attack_cast: ShapeCast3D = %AttackCast
@onready var swing_path_follow: PathFollow3D = %SwingPathFollow
@onready var stab_start_position: Node3D = %StabStartPosition

var extra_damage := 0

func _ready():
	for group in weilder.get_groups():
		%AttackCast.set_group(group)
	
	player = get_tree().get_first_node_in_group("Player")

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
		attack_cast.deal_damage(damage + extra_damage)
		
		if attackStyle == WeaponAttackStyle.SWING:
			swing_path_follow.progress_ratio += delta / timer.wait_time
			attack_cast.position = swing_path_follow.position

func can_attack() -> bool:
	return ready_to_use

func attack(bonus_damage:int = 0, cooldown_reduction:float = 1.0):
	extra_damage = bonus_damage
	ready_to_use = false
	timer.start(cooldown * cooldown_reduction)
	attack_started.emit(cooldown * cooldown_reduction)
	
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
	if projectile_scene == null:
		print("No ammo equipped")
		if player:
			player.basic_hud.display_info("No ammo equipped")
		return
	attacking = true
	attack_cast.enabled = false
	var projectile = projectile_scene.instantiate()
	get_tree().get_root().add_child(projectile)
	projectile.global_position = global_position
	projectile.global_transform.basis = global_transform.basis
	projectile.global_position += global_transform.basis * Vector3.FORWARD * 1.5
	projectile.set_damage(damage + extra_damage)
	projectile.set_speed(attack_range)
	for group in weilder.get_groups():
		projectile.add_to_group(group)

func update_weapon(equip_dict):
	var main_weapon = equip_dict["weapon_melee"]
	
	if main_weapon:
		var data : ActionData = main_weapon.action_data
		damage = data.weapon_damage
		cooldown = data.weapon_cooldown
		attack_range = data.weapon_range
		
		if data.equipement_type == EquipmentAction.EquipmentType.MELEE:
			match data.attack_type:
				EquipmentAction.AttackMethod.STAB:
					attackStyle = WeaponAttackStyle.STAB
				EquipmentAction.AttackMethod.SWING:
					attackStyle = WeaponAttackStyle.SWING
				EquipmentAction.AttackMethod.SHOOT:
					attackStyle = WeaponAttackStyle.SHOOT
				_:
					attackStyle = WeaponAttackStyle.STAB
					
	var offhand_weapon = equip_dict["weapon_ranged"]
	if offhand_weapon == null:
		projectile_scene = null
		return
		
	var offhand_data : ActionData = offhand_weapon.action_data
	projectile_scene = offhand_data.ammo_packed_scene
