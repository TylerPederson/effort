extends Node3D


@onready var collectible_tray = preload("res://stats-and-combat/Collectible/choice_tray.tscn")
var instance = null

func spawn_collectible_tray():
	if not instance == null:
		return
	instance = collectible_tray.instantiate()
	add_child(instance)
	instance.activate()
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.basic_hud.display_info("All enemies in room defeated. Power ups available", 5.0)
