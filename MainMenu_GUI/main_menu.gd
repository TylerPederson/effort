extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	print("Start button pressed")
	get_tree().change_scene_to_file("res://sandbox_level.tscn")


func _on_setting_pressed() -> void:
	print("setting button pressed")


func _on_quit_pressed() -> void:
	print("quit button pressed")
	get_tree().quit()
