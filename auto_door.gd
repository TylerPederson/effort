extends Node3D

@onready var door_mesh = $CSGBox3D 
@onready var area = $Area3D
@onready var audio = $AudioStreamPlayer3D

var closed_position : Vector3
var open_position : Vector3

@export var slide_distance := 5.0
@export var speed := 2.0

var opening := false
var closing := false

func _ready():
	closed_position = door_mesh.position
	open_position = closed_position + Vector3(slide_distance, 0, 0)

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _process(delta):
	if opening:
		door_mesh.position = door_mesh.position.lerp(open_position, speed * delta)
		
		if door_mesh.position.distance_to(open_position) < 0.05:
			opening = false

	if closing:
		door_mesh.position = door_mesh.position.lerp(closed_position, speed * delta)
		
		if door_mesh.position.distance_to(closed_position) < 0.05:
			closing = false

func _on_body_entered(body):
	if body is CharacterBody3D:
		opening = true
		closing = false
		audio.play()
		

func _on_body_exited(body):
	if body is CharacterBody3D:
		closing = true
		opening = false
		audio.play()
		
