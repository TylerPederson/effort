extends Node3D


@onready var collectible_tray = preload("res://stats-and-combat/Collectible/choice_tray.tscn")
var instance = null

func spawn_collectible_tray():
	if not instance == null:
		return
	instance = collectible_tray.instantiate()
	add_child(instance)
	instance.activate()
