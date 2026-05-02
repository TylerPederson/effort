extends Node3D
class_name AttackAlternativeComponent

signal perform_active(flag: bool, total: float)
signal perform_charge_change(amount)

var controller : Node3D
var stamina_component : StaminaComponent = null
var attack_component : AttackComponent = null
var armor_component : ArmorComponent = null
var stamina_cost_initial := 1.0
var stamina_drain := 4.0

@export var flat_armor_amount_rate := 3.0
@export var flat_armor_time := 5.0
@export var ratio_armor_time_rate := 1.5
@export var ratio_armor_amount := 0.7
@export var jump_charge_rate : float = 2.5

var performing :bool = false

var perform_charge : float = 0.0:
	set(amount):
		perform_charge = amount
		perform_charge_change.emit(perform_charge)

func _ready() -> void:
	controller = get_parent()
	controller.connect("perform_attack_alternative", _on_perform_begin)
	controller.connect("stop_attack_alternative", _on_perform_end)
	_attach_stamina()
	_attach_attack()
	_attach_armor()

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
		_:
			pass
	
	if not stamina_component.has_stamina():
		_on_perform_end()
		return

func _stab_alternative(delta):
	perform_charge += flat_armor_amount_rate * delta

func _swing_alternative(delta):
	perform_charge += ratio_armor_time_rate * delta

func _shoot_alternative(delta):
	perform_charge += jump_charge_rate * delta



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

func _attach_armor():
	for c in get_parent().get_children():
		if c is ArmorComponent:
			armor_component = c
			break

func _on_perform_begin():
	if attack_component == null:
		return
	if stamina_component == null or not stamina_component.has_stamina(stamina_cost_initial):
		return
	
	controller.basic_hud.display_info("Charging ability...")
	stamina_component.use_stamina(stamina_cost_initial)
	
	perform_charge = 0.0
	performing = true
	
	var max_charge_possible = _get_max_charge_possible()
	
	perform_active.emit(true, max_charge_possible)


func _on_perform_end():
	if attack_component == null:
		return
	
	if perform_charge > 0.5:
		match(attack_component._equipped_weapon.attackStyle):
			WeaponComponent.WeaponAttackStyle.STAB:
				var armor_bonus = FlatArmorStrategy.new(ceil(perform_charge), flat_armor_time)
				armor_component.add_armor_source(armor_bonus)
				controller.basic_hud.display_buff("Temporary " + str(ceil(perform_charge)) + " Armor!", flat_armor_time)
			WeaponComponent.WeaponAttackStyle.SWING:
				var armor_bonus = RatioArmorStrategy.new(ratio_armor_amount, perform_charge)
				armor_component.add_armor_source(armor_bonus)
				controller.basic_hud.display_buff("Temporary Proptection for " + str(snappedf(perform_charge, 0.1)), ratio_armor_time_rate * perform_charge)
			WeaponComponent.WeaponAttackStyle.SHOOT:
				controller.velocity.y += perform_charge
				controller.basic_hud.display_buff("Super Jump Strength: " +  str(snappedf(perform_charge, 0.1)))
			_:
				pass
	
	var previous_charge = perform_charge
	perform_charge = 0.0
	performing = false
	perform_active.emit(false, previous_charge)


func _get_max_charge_possible():
	var total_stamina = stamina_component.get_total_stamina() - stamina_cost_initial
	var perform_units = total_stamina / stamina_drain
	
	match (attack_component._equipped_weapon.attackStyle):
		WeaponComponent.WeaponAttackStyle.STAB:
			return perform_units * flat_armor_amount_rate
		WeaponComponent.WeaponAttackStyle.SWING:
			return perform_units * ratio_armor_time_rate
		WeaponComponent.WeaponAttackStyle.SHOOT:
			return perform_units * jump_charge_rate
		_:
			return perform_units
