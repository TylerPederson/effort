extends Node3D

@onready var light = $OmniLight3D
@onready var audio = $AudioStreamPlayer3D

var pulsating = true
var t = 0.0 

var base_energy = 1.0
var pulse_strength = 2.0 
var pulse_speed = 2.0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if pulsating:
		t+= delta 
		var pulse = sin(t * pulse_speed) * 0.5 + 0.5 
		light.light_energy = base_energy + pulse * pulse_strength
	pass

func interact():
	if not pulsating:
		return
		
	pulsating = false 
	
	light.light_energy = base_energy
	
	audio.play()
