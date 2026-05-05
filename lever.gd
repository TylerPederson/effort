extends Node3D

@onready var mesh = $MeshInstance3D
@onready var audio = $AudioStreamPlayer1
@onready var bell = $AudioStreamPlayer2
@onready var lantern = $Lantern
@onready var envio_interact: EnvioInteract = $EnvioInteract

func _ready() -> void:
	envio_interact.parent = self

func interact():
	GameManager.lever_activated()
	pull_lever()
	
	if envio_interact.one_shot:
		envio_interact.queue_free()
	
func pull_lever():
	mesh.rotate_x(deg_to_rad(75))
	audio.play() 
	lantern.activate()
	await get_tree().create_timer(1.0).timeout 
	bell.play()
