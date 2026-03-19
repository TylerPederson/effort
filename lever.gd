extends Node3D

var used = false

func interact():
	if used:
		return

	used = true
	print("Lever (box) activated!")

	GameManager.lever_activated()
	
	activate_vis()
	
func activate_vis():
	rotate_x(deg_to_rad(30))
