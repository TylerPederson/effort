extends Node3D

var speed = 5
var drop = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _drop_door(drop: bool):	# Function rotates the door to drop down
	if drop == true:
		if rotation_degrees.z < 90:
			rotation_degrees.z += speed * get_physics_process_delta_time()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_drop_door(drop)


func _on_area_3d_body_entered(body):
	#print_debug("Entered")
	drop = true
	
