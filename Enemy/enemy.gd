extends CharacterBody3D

enum EnemyType {
	Melee,
	Ranged
}

signal died

@onready var animation_tree: AnimationTree = $AnimationTree
var state_machine : AnimationNodeStateMachinePlayback

# Expected enemy manager to be set so that a level or other custom logic can
# be completed when all enemies in a location die
@export var manager : EnemyManager

# Enemy type alters movement and attack type
@export var type : EnemyType

# Basic variables that any enemy will have
@export var move_speed : float = 100.0
@export var health : int = 30
@export var damage : int = 5
@export var attack_range : float = 2.0
@export var attack_cooldown : float = 1.5

# Variables used for range enemies to only move to a safe distance
var closest_chase_dist := 36.0
var closest_backup_dist := 16.0
var backoff_speed_multiplier := 2.0

var player: Node3D
var following : bool = false

# Set all stats from editor
func _ready() -> void:
	if not manager == null:
		manager.link(self)
	
	%HealthComponent.max_hp = health
	%HealthComponent.current_hp = health
	
	%AttackComponent._equipped_weapon.damage = damage
	%AttackComponent._equipped_weapon.cooldown = attack_cooldown
	%AttackComponent._equipped_weapon.attack_range = attack_range
	
	if type == EnemyType.Melee:
		%AttackComponent._equipped_weapon.attackStyle = WeaponComponent.WeaponAttackStyle.STAB
	if type == EnemyType.Ranged:
		%AttackComponent._equipped_weapon.attackStyle = WeaponComponent.WeaponAttackStyle.SHOOT
	
	player = get_tree().get_first_node_in_group("Player")
	state_machine = animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback



# Handle any custom behavior logic each frame
func _process(delta: float) -> void:
	if following:
		# Attempt to attack toward player
		state_machine.travel("move")
		%AttackComponent.set_auto_attack(true)
		look_at(player.position)
		rotation.x = 0
		rotation.z = 0
		
		# Any future logic dependent on enemy type would go here
		if type == EnemyType.Ranged:
			pass
		if type == EnemyType.Melee:
			pass
	else:
		%AttackComponent.set_auto_attack(false)
		state_machine.travel("idle")

# Handle movement from gravity and chasing the player
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	if following:
		var direction =  -global_transform.basis.z
		velocity.x = direction.x * move_speed * delta
		velocity.z = direction.z * move_speed * delta
		
		# Adds a small chance to jump at any given moment, mostly to
		# prevent getting permanently stuck on small ledges
		if randf() < 0.005:
				velocity.y = 3
		
		# Ranged Enemies have a special 'deadzone' where they 
		# will stop chasing the player or move away quickly if the 
		# player is too close
		if type == EnemyType.Ranged:
			var distance = global_position.distance_squared_to(player.global_position)
			
			if distance < closest_chase_dist:
				velocity.z = 0
				velocity.x = 0
			
			if distance < closest_backup_dist:
				var runaway_speed = move_speed * backoff_speed_multiplier
				velocity.z = -direction.x * runaway_speed * delta
				velocity.x = -direction.x * runaway_speed * delta
		
		# Any future changes to melee move algorithms would go here
		if type == EnemyType.Melee:
			pass
	# Stop moving if the player is too far away
	else:
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()

func _on_health_component_death() -> void:
	following = false
	died.emit()
	state_machine.start("die")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		following = true
		player = body



func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		following = false


func _on_weapon_component_attack_started(time: Variant) -> void:
	state_machine.travel("attack")


func _on_health_component_hit_damage(amount: Variant) -> void:
	state_machine.start("hurt")
	following = true


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		queue_free()
