extends Node3D

var used = false

@onready var mesh = $MeshInstance3D
@onready var item_interact: Node = $ItemInteract

func _ready() -> void:
	item_interact.remove_from_world_on_collect = false

func interact():
	print("TRIED")
	if used:
		return

	used = true
	print("Lever activated!")
	item_interact.queue_free()

	GameManager.lever_activated()
	pull_lever()
	
func pull_lever():
	mesh.rotate_x(deg_to_rad(75)) 
