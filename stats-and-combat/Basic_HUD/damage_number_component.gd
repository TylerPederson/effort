extends Node3D

func damage_display(damage_num):
	$Node3D/Label3D.text = str(damage_num)
	$AnimationPlayer.play("damage_display")
	

func finish():
	queue_free()
