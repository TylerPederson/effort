extends Node3D
class_name HitboxComponent

@export var health_component: HealthComponent

func receive_damage(damage: int):
	if health_component:
		health_component.take_damage(damage)
