extends Node3D


var speed := 30
var lifetime := 2.0

@onready var damage_component: DamageComponent = $Damage_Component
@onready var life_timer: Timer = $LifeTimer

func _ready():
	damage_component.connect("successful_hit", _on_hit)
	life_timer.start(lifetime)

func _physics_process(delta: float) -> void:
	global_position += basis * Vector3.FORWARD * speed * delta

func set_direction(direction: Basis):
	global_basis = direction

func set_speed(_speed : int):
	speed = _speed

func set_damage(_damage: int):
	damage_component.set_damage(_damage)

func _on_hit():
	print("projectile hit something")


func _on_life_timer_timeout() -> void:
	queue_free()
