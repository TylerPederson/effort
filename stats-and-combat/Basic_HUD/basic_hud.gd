extends Control
class_name Basic_HUD

@onready var hp_bar: ProgressBar = $HP_Bar
@onready var stamina_bar: ProgressBar = $Stamina_Bar
@onready var charge_bar: ProgressBar = $Charge_Bar
@onready var info_label: Label = $InfoLabel
@onready var buff_label: Label = $BuffLabel


func _ready() -> void:
	var weapon_info = get_node("/root/w")
	hp_bar.max_value = 100
	hp_bar.value = 100
	stamina_bar.max_value = 100
	stamina_bar.value = 100
	info_label.text = ""
	buff_label.text = ""
	


func display_buff(text: String, duration : float = 1.5):
	buff_label.text = text
	await get_tree().create_timer(duration).timeout
	buff_label.text = ""

func display_info(text: String, duration : float = 1.5):
	info_label.text = text
	await get_tree().create_timer(duration).timeout
	info_label.text = ""

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
