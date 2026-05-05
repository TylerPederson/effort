extends Node3D
class_name StaminaComponent

signal stamina_change(current_stamina, total_stamina)

@export var max_stamina := 20.0
@export var exhaustion_cooldown_time := 2.5
@export var use_cooldown_time := 1.0
@export var stamina_regen_rate := 1.0

var stamina_regen_rate_bonus := 0.0

var current_stamina := 1.0:
	set(new_stamina):
		current_stamina = max(0, new_stamina)
		current_stamina = min(current_stamina, max_stamina + bonus_stamina)
		stamina_change.emit(current_stamina, max_stamina+bonus_stamina)
var bonus_stamina := 0.0:
	set(new_bonus):
		bonus_stamina = max(0, bonus_stamina + new_bonus)
		current_stamina = max(current_stamina, bonus_stamina + current_stamina)
		stamina_change.emit(current_stamina, max_stamina+bonus_stamina)
var regenerating_stamina : bool = true
const MIN_STAMINA := 0.07

@onready var regen_timer: Timer = $RegenTimer

func _ready():
	current_stamina = max_stamina

func _process(delta: float) -> void:
	if not regenerating_stamina:
		return
	
	gain_stamina((stamina_regen_rate + stamina_regen_rate_bonus) * delta)

func has_stamina(amount: float = MIN_STAMINA) -> bool:
	return current_stamina > amount

func use_stamina(amount: float):
	current_stamina = max(0.0, current_stamina - amount)
	regenerating_stamina = false
	
	if current_stamina < MIN_STAMINA:
		regen_timer.start(exhaustion_cooldown_time)
	else:
		regen_timer.start(use_cooldown_time)

func gain_stamina(amount: float):
	current_stamina = min(max_stamina + bonus_stamina, current_stamina + amount)

func is_full_stamina() -> bool:
	return current_stamina == max_stamina + bonus_stamina

func _on_regen_timer_timeout() -> void:
	current_stamina = max(MIN_STAMINA, current_stamina)
	regenerating_stamina = true

func get_total_stamina() -> float:
	return max_stamina + bonus_stamina
