extends Control



func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://GUI/pause.tscn")
	

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("go back"):
		get_tree().change_scene_to_file("res://GUI/pause.tscn")
