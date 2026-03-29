extends Area3D

@export var scene_to_load : PackedScene

func load_scene():
	get_tree().change_scene_to_packed(scene_to_load)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		call_deferred("load_scene")
