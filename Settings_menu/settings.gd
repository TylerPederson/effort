extends Control

var opened_from: String = "pause"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_h_slider_value_changed(value: float) -> void:
	pass # Replace with function body.

func _on_check_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.

func _on_back_button_pressed() -> void:
	if opened_from == "pause":
		queue_free()
	elif opened_from == "main_menu":
		get_tree().change_scene_to_file("res://MainMenu_GUI/MainMenu.tscn")
