extends Node3D

var speed = 15
var drop = false
var lift = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _drop_door(delta: float):	# Function rotates the door to drop down
	if drop == true:
		if rotation_degrees.z < 90:
			rotation_degrees.z += speed * delta
			if rotation_degrees.z >= 90:	# Makes sure not to go all the way through the ground 
				drop = false
	
func _lift_door(delta: float): # Rotates the door to lift after played enters arena 
	if lift == true:
		#print_debug("Lift is true")
		if rotation_degrees.z >= 0:
			rotation_degrees.z -= speed * delta
			if rotation_degrees.z <= 0:	# Makes sure not to go backwards
				lift = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_drop_door(delta)
	_lift_door(delta)

func _on_area_3d_body_entered(body): # Activates when player enters trigger 
	#print_debug("Entered")
	if body.name == "Player":
		$AudioStreamPlayer3D.play()
		drop = true
	


func _on_area_3d_2_body_exited(body):
	#print_debug("Exited")
	if body.name == "Player":
		$AudioStreamPlayer3D.play()
		lift = true
