extends Node3D


var speed := 30
var lifetime := 2.0

var start_damage
var damage_falloff = 0

@onready var damage_component: DamageComponent = $Damage_Component
@onready var life_timer: Timer = $LifeTimer
@onready var damage_falloff_per_tick = 1

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
	start_damage = _damage

func _on_hit():
	queue_free()


func _on_life_timer_timeout() -> void:
	queue_free()


func _on_falloff_timer_timeout() -> void:
	damage_falloff += damage_falloff_per_tick
	damage_component.set_damage(max(0, start_damage - damage_falloff))


func _on_falloff_start_timer_timeout() -> void:
	%FalloffTimer.start()
