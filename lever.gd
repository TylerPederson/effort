extends Node3D

@onready var mesh = $MeshInstance3D
@onready var envio_interact: EnvioInteract = $EnvioInteract

func _ready() -> void:
	envio_interact.parent = self

func interact():
	print("TRIED")
	print("Lever activated!")

	GameManager.lever_activated()
	pull_lever()
	
	if envio_interact.one_shot:
		envio_interact.queue_free()
	
func pull_lever():
	mesh.rotate_y(deg_to_rad(45)) 
