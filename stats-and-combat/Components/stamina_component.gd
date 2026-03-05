extends Node3D
class_name StaminaComponent

@export var max_stamina := 20.0
@export var exhaustion_cooldown_time := 2.5
@export var use_cooldown_time := 1.0
@export var stamina_regen_rate := 3.0

var current_stamina
var regenerating_stamina : bool = true
const MIN_STAMINA = 0.07

@onready var regen_timer: Timer = $RegenTimer

func _ready():
	current_stamina = max_stamina

func _process(delta: float) -> void:
	if not regenerating_stamina:
		return
	
	gain_stamina(stamina_regen_rate * delta)

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
	current_stamina = min(max_stamina, current_stamina + amount)


func _on_regen_timer_timeout() -> void:
	current_stamina = max(MIN_STAMINA, current_stamina)
	regenerating_stamina = true
