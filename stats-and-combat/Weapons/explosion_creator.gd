extends Node3D

var nearby_objects = []

var explosion : PackedScene = preload("res://stats-and-combat/Weapons/explosion.tscn")
@onready var damage_component: DamageComponent = $"../Damage_Component"


func track_object(object):
	nearby_objects.append(object)

func untrack_object(object):
	if object in nearby_objects:
		nearby_objects.erase(object)

func create_explosion():
	for c in nearby_objects:
		if c is HitboxComponent:
			c.receive_damage(damage_component.damage_value / 3)
	
	var instance = explosion.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = global_position
