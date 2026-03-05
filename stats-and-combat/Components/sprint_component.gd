extends Node3D
class_name SprintComponent

var controller : Node3D
var stamina_component : StaminaComponent = null
var stamina_cost_initial := 5.0
var stamina_drain := 2.0

@export var sprint_amplifier := 1.5

var sprinting :bool = false

func _ready() -> void:
	controller = get_parent()
	controller.connect("perform_sprint", _on_sprint_begin)
	controller.connect("stop_sprint", _on_sprint_end)
	_attach_stamina()

func _attach_stamina():
		for c in get_parent().get_children():
			if c is StaminaComponent:
				stamina_component = c
				break

func _on_sprint_begin():
	if stamina_component == null:
		sprinting = true
		print("Starting sprint")
		return
	
	if not stamina_component.has_stamina(stamina_cost_initial):
		print("Not enough stamina to sprint")
		return
	
	stamina_component.use_stamina(stamina_cost_initial)
	sprinting = true
	print("Starting sprint")

func _on_sprint_end():
	if stamina_component == null:
		print("Ending sprint")
		sprinting = false
		return
	
	print("Ending sprint")
	sprinting = false

func apply_sprint(movement_speed, delta):
	if !sprinting:
		return movement_speed
	
	if !stamina_component:
		return movement_speed * sprint_amplifier
	
	if not stamina_component.has_stamina(stamina_drain * delta):
		_on_sprint_end()
		return movement_speed
	
	stamina_component.use_stamina(stamina_drain * delta)
	return movement_speed * sprint_amplifier
