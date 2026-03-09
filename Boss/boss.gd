extends CharacterBody3D
var speed = 1
@onready var state_controller = get_node("StateMachine")
@export var player: CharacterBody3D
var direction: Vector3
var awake: bool = false
var attack: bool = false
var health: int = 100
var damage: int = 5
var dead: bool = false
var hit: bool = false

func _ready():
	state_controller.change_state("Idle")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if player:
		direction = (player.global_transform.origin - self.global_transform.origin.normalized())
