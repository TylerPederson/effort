extends Node3D

@onready var light = $OmniLight3D
@onready var audio = $AudioStreamPlayer3D
@onready var item_interact: Node = $ItemInteract

var used = false
var pulsating = true
var t = 0.0 
var base_energy = 1.0
var pulse_strength = 2.0 
var pulse_speed = 2.0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_interact.remove_from_world_on_collect = false
	item_interact.triggered.connect(_on_item_interact_triggered)
	pass
	 	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if pulsating:
		t+= delta 
		var pulse = sin(t * pulse_speed) * 0.5 + 0.5 
		light.light_energy = base_energy + pulse * pulse_strength
	pass

func interact():	
	if used:
		return
		
	used = true
	pulsating = false 
	light.light_energy = base_energy
	audio.play()
	
func _on_item_interact_triggered() -> void:
	interact()
	pass # Replace with function body.
