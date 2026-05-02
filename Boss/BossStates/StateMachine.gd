extends Node
# Loads the script for each state
var state = {
	"Idle" = preload("res://Boss/BossStates/IdleState.gd"),
	"Walk" = preload("res://Boss/BossStates/WalkState.gd"),
	"Attack" = preload("res://Boss/BossStates/AttackState.gd"),
	"Death" = preload("res://Boss/BossStates/DeathState.gd")
	}
func _change_state(newState: String):	# Changes state if it is not dead
	if newState != "Walk":
		$"../BossV2/WalkingAudio".stop()
	if newState == "Walk":
		$"../BossV2/WalkingAudio".play()
	if get_child_count() != 0:	# Remove the last states if not dead
		if !("Death" in get_child(0).name):
			get_child(0).queue_free()
	if state.has(newState):	# Gets the new stats
		var stateTemp = state[newState].new()
		stateTemp.name = newState
		add_child(stateTemp)
