extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#func _ready():
	#pass # Replace with function body.
	main_buttons.visible = true
	options.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_start_pressed() -> void:
	print("Start button pressed")
	get_tree().change_scene_to_file("res://sandbox_level.tscn")


func _on_setting_pressed() -> void:
	print("setting button pressed")
	main_buttons.visible = false
	options.visible = true


func _on_quit_pressed() -> void:
	print("quit button pressed")
	get_tree().quit()


func _on_button_options_pressed() -> void:
	_ready()
