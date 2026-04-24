
extends Node3D

@onready var collision_shape_3d: CollisionShape3D = $AnimatableBody3D/CollisionShape3D

var player
var player_bottom_offset = 0.7

func _ready():
	player = get_tree().get_first_node_in_group("Player")


func _process(delta: float) -> void:
	# disables the collision of the platform if the bottom of the player is lower than the platform
	# this prevents them from being crushed
	if player.global_position.y - player_bottom_offset < collision_shape_3d.global_position.y:
		collision_shape_3d.disabled = true
	else:
		collision_shape_3d.disabled = false
