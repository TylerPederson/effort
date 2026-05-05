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
		var light_tween = create_tween()
		light_tween.tween_property(mat, "shader_parameter/blend_factor", 1.0, 2.0)

func turn_off():
	$OmniLight3D.visible = false
	var mat = $Ball.get_active_material(0)
	if mat:
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/blend_factor", 0.0, 2.0)
	
