extends Area3D
class_name DamageComponent

signal successful_hit

@export var damage_value : int = 10
@export var cooldown : float = 1.0
var ready_to_damage: bool = true

var cooldown_timer: Timer

func _ready():
	connect("area_entered", _on_area_entered)
	cooldown_timer = %CooldownTimer
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.autostart = false
	cooldown_timer.connect("timeout", on_cooldown_timer_timeout)


func _on_area_entered(body):
	if body is not HitboxComponent:
		return
	if not ready_to_damage:
		return
	
	
	for group in body.get_parent().get_groups():
		if group in get_parent().get_groups():
			return
	
	var hitbox : HitboxComponent = body
	hitbox.receive_damage(damage_value)
	successful_hit.emit()
	
	ready_to_damage = false
	cooldown_timer.start()

func on_cooldown_timer_timeout():
	ready_to_damage = true

func set_damage(_damage: int):
	damage_value = _damage
