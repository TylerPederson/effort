extends Node3D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	turn_off()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func activate(): 
	$OmniLight3D.visible = true
	$OmniLight3D.light_energy = 0
	
	var mat = $MeshInstance3D.get_active_material(0)
	if mat:
		mat.emission_enable = true
		mat.emission = Color(0.812, 0.0, 0.0, 1.0)
		mat.emission_energy = 10 
		
	var tween = create_tween()
	
	tween.tween_property($OmniLight3D, "light_energy", 3.0, 1.5)
	if mat: 
		tween.parallel().tween_property(mat, "emission_energy", 2.0,1.0)

func turn_off():
	$OmniLight3D.visible = false
	var mat = $MeshInstance3D.get_active_material(0)
	if mat:
		mat.emission_enable = false 
	
