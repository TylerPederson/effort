extends Node

var AIController
var run: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	AIController = get_parent().get_parent()
	if AIController.attack:
		await AIController.get_node("AnimationTree").animation_finished
		AIController.attack = false
	else:
		run = false
		AIController.get_node("AnimationTree").get("parameters/playback").travel("get up")
		AIController.Awakening = true
		await AIController.get_node("AnimationTree").animation_finished
	run = true
	AIController.Awakening = false
	AIController.get_node("AnimationTree").get("parameters/playback").travel("Walking")
	
func _physics_process(delta: float):
	if AIController and run:
		AIController.velocity.x = AIController.direction.x * AIController.speed
		AIController.velocity.z = AIController.direction.z * AIController.speed
		AIController.look_at(AIController.global_transform.origin + AIController.direction, Vector3(0,1,0))
