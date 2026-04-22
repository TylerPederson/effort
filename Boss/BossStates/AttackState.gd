extends Node
var AIController

# Called when the node enters the scene tree for the first time.
func _ready():	# Waits for current animations to finish then starts attacjs
	AIController = get_parent().get_parent()
	if AIController.Awakening:
		await AIController.get_node("AnimationTree").animation_finished
	AIController.attack = true
	var rng = RandomNumberGenerator.new()	
	var my_int = rng.randi_range(1, 6) 	# Generates a random number between 1 and 6
	match my_int:	# Random number selects an attack
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
			

func _physics_process(delta: float):
	if AIController and AIController.player: # Extra code to make sure boss targetting doesn't glitch out
		AIController.velocity.x = 0
		AIController.velocity.z = 0

		var dir = AIController.player.global_position - AIController.global_position
		dir.y = 0.0

		if dir.length() > 0.1:
			dir = dir.normalized()
			AIController.direction = dir

			var target_angle = atan2(dir.x, dir.z) + PI
			AIController.rotation.y = lerp_angle(AIController.rotation.y,target_angle,AIController.rotate_speed * delta)
