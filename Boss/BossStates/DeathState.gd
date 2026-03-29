extends Node

var AIController

# Called when the node enters the scene tree for the first time.
func _ready():	# Just plays dying animation
	AIController = get_parent().get_parent()
	if AIController.Awakening:
		await AIController.get_node("AnimationTree").animation_finished
	AIController.get_node("AnimationTree").get("parameters/playback").travel("Dying")
	AIController.dead = true
	
	
func _physics_process(delta: float):		# Makes sure boss doesn't slide around while dying
	if AIController:
		AIController.velocity.x = 0
		AIController.velocity.z = 0
