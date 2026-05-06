extends Node3D


func _ready():
	%OmniLight3D.visible = false
	trigger()

func trigger():
	await get_tree().create_timer(0.02).timeout
	%Particles.emitting = true
	%OmniLight3D.visible = true
	await get_tree().create_timer(1.0).timeout
	%OmniLight3D.visible = false
	queue_free()
