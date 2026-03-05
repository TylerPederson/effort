extends Node3D
class_name StaminaComponent

@export var max_stamina := 20.0
@export var exhaustion_cooldown_time := 2.0
@export var use_cooldown_time := 0.5
@export var stamina_regen_rate := 3.0

var current_stamina
var regenerating_stamina : bool = true

@onready var regen_timer: Timer = $RegenTimer

func _ready():
	current_stamina = max_stamina

func _process(delta: float) -> void:
	if regenerating_stamina == false:
		return
	
	if current_stamina <= 0.0:
		regenerating_stamina = false
		regen_timer.start(exhaustion_cooldown_time)
		return
	
	gain_stamina(stamina_regen_rate * delta)

func has_stamina(amount: float = 0.1) -> bool:
	return current_stamina > amount

func use_stamina(amount: float):
	current_stamina = max(0.0, current_stamina - amount)
	regenerating_stamina = false
	regen_timer.start(use_cooldown_time)
	print("Used some stamina: ", amount, current_stamina)

func gain_stamina(amount: float):
	current_stamina = min(max_stamina, current_stamina + amount)


func _on_regen_timer_timeout() -> void:
	regenerating_stamina = true
