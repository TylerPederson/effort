extends Node

var AIController

# Called when the node enters the scene tree for the first time.
func _ready():	# Plays idle animation 
	AIController = get_parent().get_parent()
	if AIController.Awakening:
		await AIController.get_node("AnimationTree").animation_finished
	AIController.get_node("AnimationTree").get("parameters/playback").travel("Idle")
	
func _physics_process(delta: float):	# Makes sure boss doesn't slide while idle 
	if AIController:
		AIController.velocity.x = 0
		AIController.velocity.z = 0
