extends Node3D

var speed = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _drop_door(delta):	# Function rotates the door to drop down
	while rotation_degrees.z < 90:
		rotation_degrees.z += speed * delta
		if rotation_degrees.z > 90:
			break		
	pass			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_drop_door(delta)
