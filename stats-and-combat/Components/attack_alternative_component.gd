extends Node3D
class_name AttackAlternativeComponent

var controller : Node3D
var stamina_component : StaminaComponent = null
var attack_component : AttackComponent = null
var stamina_cost_initial := 1.0
var stamina_drain := 4.0

@export var block_ratio := 0.5
@export var heal_amount := 1
@export var damage_increase := 1.5

var performing :bool = false

func _ready() -> void:
	controller = get_parent()
	controller.connect("perform_attack_alternative", _on_perform_begin)
	controller.connect("stop_attack_alternative", _on_perform_end)
	_attach_stamina()
	_attach_attack()

func _process(delta: float) -> void:
	if not performing:
		return
	if stamina_component == null or attack_component == null:
		return
	
	stamina_component.use_stamina(stamina_drain * delta)
	
	match(attack_component._equipped_weapon.attackStyle):
		WeaponComponent.WeaponAttackStyle.STAB:
			_stab_alternative(delta)
		WeaponComponent.WeaponAttackStyle.SWING:
			_swing_alternative(delta)
		WeaponComponent.WeaponAttackStyle.SHOOT:
			_shoot_alternative(delta)
	
	if not stamina_component.has_stamina():
		_on_perform_end()
		return

func _stab_alternative(delta):
	print("Stab alt")
	pass

func _swing_alternative(delta):
	print("swing alt")
	pass

func _shoot_alternative(delta):
	print("shoot alt")
	pass



func _attach_stamina():
		for c in get_parent().get_children():
			if c is StaminaComponent:
				stamina_component = c
				break

func _attach_attack():
	for c in get_parent().get_children():
		if c is AttackComponent:
			attack_component = c
			break

func _on_perform_begin():
	if attack_component == null:
		return
	if stamina_component == null or not stamina_component.has_stamina(stamina_cost_initial):
		return
	
	stamina_component.use_stamina(stamina_cost_initial)
	performing = true


func _on_perform_end():
	if attack_component == null:
		return

	performing = false
