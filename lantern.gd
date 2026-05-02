extends Node3D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	turn_off()
	pass # Replace with function body.


func activate(): 
	$OmniLight3D.visible = true
	$OmniLight3D.light_energy = 0
	
	var tween = create_tween()
	tween.tween_property($OmniLight3D, "light_energy", 3.0, 1.5)
	
	var mat = $Ball.get_active_material(0)
	if mat:
		mat.emission_enable = true
		mat.emission = Color(0.812, 0.0, 0.0, 1.0)
		#mat.emission_energy = 50
		var light_tween = create_tween()
		light_tween.tween_property(mat, "emission_energy_multiplier", 50.0, 3.0)

func turn_off():
	$OmniLight3D.visible = false
	var mat = $Ball.get_active_material(0)
	if mat:
		mat.emission_enable = false 
		mat.emission_energy = 0
	
