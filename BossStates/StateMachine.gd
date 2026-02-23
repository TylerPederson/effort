extends Node

var state = {
	"Idle" = preload("res://BossStates/IdleState.gd"),
	"Walk" = preload("res://BossStates/WalkState.gd"),
	"Attack" = preload("res://BossStates/AttackState.gd"),
	"Death" = preload("res://BossStates/DeathState.gd")
	}
func _change_state(newState: String):
	if get_child_count() != 0:
		if !("Death" in get_child(0).name):
			get_child(0).queue_free()
	if state.has(newState):
		var stateTemp = state[newState].new()
		stateTemp.name = newState
		add_child(stateTemp)
