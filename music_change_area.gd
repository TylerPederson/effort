extends Area3D


@export var music1: AudioStreamPlayer
@export var music2: AudioStreamPlayer

@export var level_environment : Resource
@export var boss_environment : Resource

var changed := false

func _on_body_entered(body: Node3D) -> void:
	if changed:
		return

	if body.is_in_group("Player"):
		changed = true
		music1.stop()
		music2.play()
		var env = get_tree().get_first_node_in_group("WorldEnvironment") as WorldEnvironment
		env.environment = boss_environment
