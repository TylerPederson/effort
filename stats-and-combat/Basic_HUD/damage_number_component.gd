extends Node3D

@export var color : Color

func _ready():
	%Label.modulate = color
	%Label.modulate.a = 0
	%Label.outline_modulate = Color.BLACK
	%Label.outline_modulate.a = 0

func damage_display(damage_num):
	%Label.text = str(damage_num)
	var tween = create_tween().set_parallel()
	tween.tween_property(%Label, "modulate:a", 1.0, 0.315)
	tween.tween_property(%Label, "outline_modulate:a", 1.0, 0.315)
	tween.tween_property(%Label, "position:y", 0.6, 0.315)
	
	tween.chain().tween_property(%Label, "modulate:a", 0.0, 0.315)
	tween.tween_property(%Label, "outline_modulate:a", 0.0, 0.315)
	tween.tween_property(%Label, "position:y", 1.0, 0.315)

func finish():
	queue_free()
