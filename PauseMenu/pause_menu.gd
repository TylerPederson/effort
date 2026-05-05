extends Control

const SETTINGS_MENU_SCENE = preload("res://Settings_menu/Settings.tscn")
#const CONTROLS_SCENE = preload()

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
	var settings_menu = SETTINGS_MENU_SCENE.instantiate()
	add_child(settings_menu)


func _on_quit_button_pressed() -> void:
	if %QuitButton.text == "Click again to confirm":
		get_tree().quit()
	%QuitButton.text = "Click again to confirm"

func _on_quit_button_mouse_exited() -> void:
	%QuitButton.text = "Quit"


func _on_menu_button_pressed() -> void:
	if %MenuButton.text == "Click again to confirm":
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file("res://MainMenu_GUI/MainMenu.tscn")
	%MenuButton.text = "Click again to confirm"

func _on_menu_button_mouse_exited() -> void:
	%MenuButton.text = "Menu"
