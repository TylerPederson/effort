extends Control


#const SETTINGS_MENU_SCENE = preload("res://Settings_menu/Settings.tscn")
#var settings_menu_instance = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = true
	
#func _unhandled_input(event: InputEvent) -> void:
#	if event.is_action_pressed("ui_cancel"):
#		_on_resume_button_pressed()

func _on_resume_button_pressed() -> void:
	print("Resume has been pressed")
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()


func _on_setting_button_pressed() -> void:
	print("Settings has been pressed")
	# Put your settings menu code here later


func _on_quit_button_pressed() -> void:
	print("Quit has been pressed")
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://MainMenu_GUI/MainMenu.tscn")


	#mouse capture code
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if _is_paused else Input.MOUSE_MODE_CAPTURED
