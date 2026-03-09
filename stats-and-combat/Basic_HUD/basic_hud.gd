extends Control

@onready var hp_bar: ProgressBar = $HP_Bar
@onready var stamina_bar: ProgressBar = $Stamina_Bar
@onready var charge_bar: ProgressBar = $Charge_Bar


func _ready() -> void:
	hp_bar.max_value = 100
	hp_bar.value = 100
	stamina_bar.max_value = 100
	stamina_bar.value = 100


func _on_health_component_health_change(current_hp: Variant, total_hp: Variant) -> void:
	hp_bar.max_value = total_hp
	hp_bar.value = current_hp


func _on_stamina_component_stamina_change(current_stamina: Variant, total_stamina: Variant) -> void:
	stamina_bar.max_value = total_stamina
	stamina_bar.value = current_stamina


func _on_attack_alternative_component_perform_active(flag: bool, amount: float) -> void:
	charge_bar.visible = flag
	charge_bar.max_value = amount

func _on_attack_alternative_component_perform_charge_change(amount: Variant) -> void:
	charge_bar.value = amount
