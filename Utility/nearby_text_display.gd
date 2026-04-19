@tool
extends Node3D

@onready var area_3d: Area3D = $Area3D
@onready var info_label: Label3D = $InfoLabel
@onready var sub_info_label: Label3D = $SubInfoLabel

@export var info := "Info"
@export var sub_info := ""
@export var position_offset := Vector3(0,0,0)

var nearby := false
var player : CharacterBody3D = null

func _ready():
	info_label.text = info
	info_label.global_position += position_offset
	sub_info_label.text = sub_info
	sub_info_label.global_position += position_offset
	player = get_tree().get_first_node_in_group("Player")

func _process(_delta):
	# Don't do anything if a player isn't yet defined or is not nearby
	if !player:
		return
	if !nearby:
		info_label.hide()
		sub_info_label.hide()
		return
	
	# If the player is nearby, check if they are facing near the node
	# by using the dot product.
	var player_forward = -player.get_facing_direction().z
	var dir_to_self = (global_position - player.global_position).normalized()
	var dot_product = player_forward.dot(dir_to_self)
	print(dot_product)
	
	# Show labels if the player is looking nearby
	if dot_product > 0.9:
		info_label.show()
		sub_info_label.show()
	else:
		info_label.hide()
		sub_info_label.hide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		nearby = true
		print("YO")
		
		# Link to the player if they hadn't before
		if !player:
			player = get_tree().get_first_node_in_group("Player")


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		nearby = false
