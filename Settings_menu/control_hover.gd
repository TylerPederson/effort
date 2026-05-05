extends Panel


func _on_mouse_entered() -> void:
	%ControlsTexture.visible = true


func _on_mouse_exited() -> void:
	%ControlsTexture.visible = false
