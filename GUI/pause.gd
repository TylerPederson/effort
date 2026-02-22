extends Control



func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://GUI/item_menu.tscn")

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		queue_free()
		emit_signal("game_unpaused")



func _on_pause_button_pressed() -> void:
	queue_free()
	emit_signal("game_unpaused")
