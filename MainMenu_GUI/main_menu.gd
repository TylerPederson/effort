extends Control

const SETTINGS_MENU_SCENE = preload("res://Settings_menu/Settings.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	print("Start button pressed")
	Choice_Tray.reset_available_collectibles()
	get_tree().change_scene_to_file("res://sandbox_level.tscn")


func _on_setting_pressed() -> void:
	print("setting button pressed")
	var settings_menu = SETTINGS_MENU_SCENE.instantiate()
	settings_menu.opened_from = "main_menu"
	get_tree().current_scene.add_child(settings_menu)


func _on_quit_pressed() -> void:
	print("quit button pressed")
	get_tree().quit()


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://CreditsMenu/credits_page.tscn")
