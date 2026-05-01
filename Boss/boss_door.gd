extends Node3D

@onready var door_right = $CSGBox3D
@onready var door_left = $CSGBox3D2
@onready var area = $Area3D

var door_right_open: Vector3 
var door_right_closed: Vector3 

var door_left_open: Vector3 
var door_left_closed: Vector3 

@export var slide_right:= 8.0 
@export var slide_left:= -8.0 
@export var speed:= 1

var opening:= false
var closing:= false 

var unlocked = false


# Called when the node enters the scene tree for the first time.
func _ready():
	
	GameManager.all_levers_pulled.connect(unlock_door)
	
	door_right_closed = door_right.position 
	door_left_closed = door_left.position 
	
	door_right_open = door_right_closed + Vector3(slide_right,0,0)
	door_left_open = door_left_closed + Vector3(slide_left,0,0)
	
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if opening:
		door_right.position = door_right.position.lerp(door_right_open, speed * _delta)
		door_left.position = door_left.position.lerp(door_left_open, speed * _delta)
		if door_right.position.distance_to(door_right_open) < 0.05:
			opening = false
		if door_left.position.distance_to(door_left_open) < 0.05:
			opening = false
			
	if closing:
		door_right.position = door_right.position.lerp(door_right_closed, speed * _delta)
		door_left.position = door_left.position.lerp(door_left_closed, speed * _delta)
		if door_right.position.distance_to(door_right_closed) < 0.05:
			closing = false 
		if door_left.position.distance_to(door_left_closed) < 0.05:
			closing = false
	pass

func _on_body_entered(body): 	
	if not unlocked:
		print("Door is Locked")
		return
			
	if body is CharacterBody3D:
		opening = true
		closing = false 

func _on_body_exited(body):
	if body is CharacterBody3D:
		closing = true
		opening = false

func unlock_door():
	unlocked = true
	print("Door Is Unlocked")
	
