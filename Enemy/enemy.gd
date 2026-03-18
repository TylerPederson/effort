extends CharacterBody3D

enum EnemyType {
	Melee,
	Ranged
}

@export var type : EnemyType
@export var move_speed : float = 100.0
@export var health : int = 30
@export var damage : int = 5
@export var attack_range : float = 2.0
@export var attack_cooldown : float = 1.5

var player: Node3D
var following : bool = false

func _ready() -> void:
	%HealthComponent.max_hp = health
	%HealthComponent.current_hp = health
	
	%AttackComponent._equipped_weapon.damage = damage
	%AttackComponent._equipped_weapon.cooldown = attack_cooldown
	%AttackComponent._equipped_weapon.attack_range = attack_range
	
	
	if type == EnemyType.Melee:
		%AttackComponent._equipped_weapon.attackStyle = WeaponComponent.WeaponAttackStyle.STAB
	if type == EnemyType.Ranged:
		%AttackComponent._equipped_weapon.attackStyle = WeaponComponent.WeaponAttackStyle.SHOOT

func _process(delta: float) -> void:
	if following:
		%AttackComponent.set_auto_attack(true)
		look_at(player.position)
		rotation.x = 0
		rotation.z = 0
		if type == EnemyType.Ranged:
			pass
		if type == EnemyType.Melee:
			pass
	else:
		%AttackComponent.set_auto_attack(false)

func _physics_process(delta: float) -> void:
	if following:
		var direction =  -global_transform.basis.z
		velocity.x = direction.x * move_speed * delta
		velocity.z = direction.z * move_speed * delta
		
		move_and_slide()
		
		if type == EnemyType.Ranged:
			pass
		if type == EnemyType.Melee:
			pass
			

func _on_health_component_death() -> void:
	queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		following = true
		player = body



func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		following = false
