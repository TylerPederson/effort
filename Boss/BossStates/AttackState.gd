extends Node

var AIController

# Called when the node enters the scene tree for the first time.
func _ready():
	AIController = get_parent().get_parent()
	if AIController.Awakening:
		await AIController.get_node("AnimationTree").animation_finished
	AIController.attack = true
	AIController.get_node("AnimationTree").get("parameters/playback").travel("Slash")
	AIController.look_at(AIController.global_transform.origin + AIController.direction, Vector3(0,1,0))

func _physics_process(delta: float):
	if AIController:
		AIController.velocity.x = 0
		AIController.velocity.z = 0
