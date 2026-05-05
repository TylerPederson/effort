extends Node3D

@export var color : Color

func _ready():
	%Label.modulate = color
	%Label.modulate.a = 0

func damage_display(damage_num):
	%Label.text = str(damage_num)
	$AnimationPlayer.play("damage_display")
	var tween = create_tween()
	tween.tween_property(%Label, "modulate:a", 1.0, 0.315)
	tween.tween_property(%Label, "modulate:a", 0.0, 0.315)

func finish():
	queue_free()
