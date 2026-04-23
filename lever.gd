extends Node3D

var used = false

@onready var mesh = $MeshInstance3D
@onready var envio_interact: EnvioInteract = $EnvioInteract

func _ready() -> void:
	envio_interact.parent = self

func interact():
	print("TRIED")
	if used:
		return

	used = true
	print("Lever activated!")

	GameManager.lever_activated()
	pull_lever()
	
func pull_lever():
	mesh.rotate_y(deg_to_rad(45)) 
