extends Node3D


func _ready():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "rotation_degrees:y", 360, 4.0).as_relative()
	tween.tween_property(self, "position:y", -0.3, 4).as_relative()
	tween.chain()
	tween.tween_property(self, "rotation_degrees:y", 360, 4.0).as_relative()
	tween.tween_property(self, "position:y", 0.3, 4).as_relative()
	tween.set_loops()
	tween.bind_node(self)
