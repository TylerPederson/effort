extends Node

var AIController
var run: bool

# Called when the node enters the scene tree for the first time.
func _ready():	# Makes sure that attack or getup is not playing before waling
	AIController = get_parent().get_parent()
	if AIController.attack:
		await AIController.get_node("AnimationTree").animation_finished
		AIController.attack = false
	else:
		run = false
		var anim_player = AIController.get_node("BossV2/AnimationPlayer")
		var crouch_length = anim_player.get_animation("Crouch").length
		AIController.get_node("AnimationTree").get("parameters/playback").travel("Crouch")
		await get_tree().process_frame
		AIController.get_node("AnimationTree").set("parameters/Crouch/TimeSeek/seek_request", crouch_length)

		AIController.Awakening = true
		await AIController.get_node("AnimationTree").animation_finished

	run = true
	AIController.Awakening = false
	AIController.get_node("AnimationTree").get("parameters/playback").travel("Walking")
	
func _physics_process(delta: float):
	if AIController and run:		# Extra code to make sure boss targetting doesn't glitch out
		var dir = AIController.player.global_position - AIController.global_position
		dir.y = 0.0

		if dir.length() > 0.1:	 
			dir = dir.normalized()
			AIController.direction = dir

			AIController.velocity.x = dir.x * AIController.speed
			AIController.velocity.z = dir.z * AIController.speed

			#var target = AIController.global_position + dir
			var target_angle = atan2(dir.x, dir.z) + PI
			AIController.rotation.y = lerp_angle(AIController.rotation.y, target_angle, AIController.rotate_speed * delta)
