extends CharacterBody3D
var speed = 1
@onready var state_controller = get_node("StateMachine")
@export var player: CharacterBody3D
var direction: Vector3
var Awakening: bool = false
var attack: bool = false
var health: int = 100
var damage: int = 5
var dead: bool = false
var hit: bool = false

func _ready():
	state_controller._change_state("Idle")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if player:
		direction = (player.global_transform.origin - self.global_transform.origin.normalized())
		direction.y = 0
	move_and_slide()

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
	if "get up" in anim_name:
		Awakening = false
	elif  "Slash" in anim_name:
		if (player in get_node("AttackPlayer").get_overlapping_bodies()) and !dead:
			state_controller._change_state("Attack")
	elif  "Dying" in anim_name:
		_death()
		
func  _death():
	self.queue_free()
