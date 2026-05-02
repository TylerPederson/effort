extends Area3D


@export var music1: AudioStreamPlayer
@export var music2: AudioStreamPlayer



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		music1.stop()
		music2.play()
