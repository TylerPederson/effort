extends CharacterBody3D
var speed = 6
var rotate_speed: float = 6.0
var death_scene = preload("res://Boss/boss_death.tscn")
@onready var state_controller = get_node("StateMachine")
@export var player: CharacterBody3D
var direction: Vector3
var Awakening: bool = false
var attack: bool = false
var health: int = 300
var boss_damage: int = 8
var dead: bool = false

func _ready():
	state_controller._change_state("Crouch loop")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if player:	# Tracks towards the player
		direction = (player.global_transform.origin - self.global_transform.origin.normalized())
		direction.y = 0
	move_and_slide()
# The following 4 functions just change state depending how far the player is
func _on_detect_player_body_entered(body):
	if body.name == "Player" and !dead:
		state_controller._change_state("Walk")

func _on_detect_player_body_exited(body):
	if body.name == "Player" and !dead:
		state_controller._change_state("Idle")

func _on_attack_player_body_entered(body):
	if body.name == "Player" and !dead:
		state_controller._change_state("Attack")

func _on_attack_player_body_exited(body):
	if body.name == "Player" and !dead:
		state_controller._change_state("Walk")

func _on_animation_tree_animation_finished(anim_name):
	if "Crouch" in anim_name:
		Awakening = false	#set to false so other states can start
	elif  attack:#"Attack" in anim_name or "Attack 2" in anim_name or "Attack 3" in anim_name or "Attack 4" in anim_name or "Attack 5" in anim_name or "Attack 6" in anim_name:	#Loops attack animation in near
		if (player in get_node("AttackPlayer").get_overlapping_bodies()) and !dead:
			state_controller._change_state("Attack")

func  _death():	#deletss boss
	var instance = death_scene.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = global_position
	await get_tree().create_timer(5.0).timeout
	self.queue_free()
	get_tree().change_scene_to_file("res://MainMenu_GUI/MainMenu.tscn")


func _on_player_hit_detection_body_entered(body):	# Damage player function
	if body.name == "Player" and attack and !dead:
		body.get_node("Health_Component").take_damage(boss_damage)
		#print_debug("Hit")
		

func _hit(damage: int):	# Player damages boss function
	health -= damage
	if health < 0:
		state_controller._change_state("Death")
		_death()


func _on_player_hit_L(body):	# Damage player function
	if body.name == "Player" and attack and !dead:
		var hit_effect = $"BossV2/Armature_004/Skeleton3D/Left Hand/SwordL/WeaponTrail/boss_hit_effect/AnimationPlayer"
		hit_effect.play("hit_animation")
		body.get_node("Health_Component").take_damage(boss_damage)
		#print_debug("Hit")

func _on_player_hit_R(body):	# Damage player function
	if body.name == "Player" and attack and !dead:
		var hit_effect = $"BossV2/Armature_004/Skeleton3D/Right Hand/SwordR/WeaponTrail/boss_hit_effect/AnimationPlayer"
		hit_effect.play("hit_animation")
		body.get_node("Health_Component").take_damage(boss_damage)
		#print_debug("Hit")
