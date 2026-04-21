extends Node
var AIController

# Called when the node enters the scene tree for the first time.
func _ready():	# Waits for current animations to finish then starts attacjs
	AIController = get_parent().get_parent()
	if AIController.Awakening:
		await AIController.get_node("AnimationTree").animation_finished
	AIController.attack = true
	var rng = RandomNumberGenerator.new()
	var my_int = rng.randi_range(1, 6) 
	match my_int:
		1:
			AIController.get_node("AnimationTree").get("parameters/playback").travel("Attack")
		2:
			AIController.get_node("AnimationTree").get("parameters/playback").travel("Attack 2")
		3:
			AIController.get_node("AnimationTree").get("parameters/playback").travel("Attack 3")
		4:
			AIController.get_node("AnimationTree").get("parameters/playback").travel("Attack 4")
		5:
			AIController.get_node("AnimationTree").get("parameters/playback").travel("Attack 5")
		6:
			AIController.get_node("AnimationTree").get("parameters/playback").travel("Attack 6")
			
	AIController.look_at(AIController.global_transform.origin + AIController.direction, Vector3.UP)
func _physics_process(delta: float):
	if AIController:		# Makes sure boss doesn't slide while attacking
		AIController.velocity.x = 0
		AIController.velocity.z = 0
