extends Node3D
class_name SprintComponent

var controller : Node3D
var stamina_component : StaminaComponent = null
var stamina_cost_initial := 3.0
var stamina_drain := 1.5
var stamina_use_ratio := 1.0
var sprint_bonus_multiplier := 1.0
var particles = null

@export var sprint_amplifier := 1.5

var sprinting :bool = false

func _ready() -> void:
	controller = get_parent()
	controller.connect("perform_sprint", _on_sprint_begin)
	controller.connect("stop_sprint", _on_sprint_end)
	_attach_stamina()
	particles = controller.get_node_or_null("Hero_Rig/SprintParticles")

func _attach_stamina():
		for c in get_parent().get_children():
			if c is StaminaComponent:
				stamina_component = c
				break

func _on_sprint_begin():
	if stamina_component == null:
		sprinting = true
		return
	
	if not stamina_component.has_stamina(stamina_cost_initial * stamina_use_ratio):
		return
	
	stamina_component.use_stamina(stamina_cost_initial * stamina_use_ratio)
	sprinting = true

	if particles:
		particles.emitting = true

func _on_sprint_end():
	if stamina_component == null:
		sprinting = false
		return
	
	sprinting = false
	if particles:
		particles.emitting = false

func apply_sprint(movement_speed, delta):
	if !sprinting:
		return movement_speed
	
	if !stamina_component:
		return movement_speed * sprint_amplifier
	
	
	stamina_component.use_stamina(stamina_drain * stamina_use_ratio * delta)
	if not stamina_component.has_stamina():
		_on_sprint_end()
	
	return movement_speed * sprint_amplifier * sprint_bonus_multiplier
