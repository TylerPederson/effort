extends Node
class_name HealthComponent

signal death
signal health_change(current_hp, total_hp)

@export var max_hp : int = 50
@export var regen : int = 0
var damage_numbers  := preload("res://stats-and-combat/Basic_HUD/damage_number_component.tscn")
var current_hp : int = 50:
	set(new_health):
		current_hp = max(0, new_health)
		current_hp = min(new_health, max_hp + bonus_hp)
		health_change.emit(current_hp, max_hp+bonus_hp)
var bonus_hp : int = 0:
	set(new_bonus):
		bonus_hp = max(0, bonus_hp + new_bonus)
		current_hp = max(current_hp, bonus_hp + current_hp)
		health_change.emit(current_hp, max_hp+bonus_hp)

var died : bool = false

var armor_component : ArmorComponent = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_hp = max_hp
	_attach_armor()

func _attach_armor():
	for c in get_parent().get_children():
		if c is ArmorComponent:
			armor_component = c
			break


func take_damage(damage: int) -> void:
	if died:
		return
	
	if not armor_component == null:
		damage = armor_component.modify_damage(damage)
	
	
	current_hp -= damage
	if get_parent().get_node_or_null("Marker3D"):
		var display_damage = damage_numbers.instantiate()
		get_parent().add_child(display_damage)
		display_damage.global_position = get_parent().get_node("Marker3D").global_position
		display_damage.damage_display(damage)
	
	
	if current_hp <= 0:
		death.emit()
		print("object died")
		died = true

func set_bonus_hp(amount: int) -> void:
	if died:
		return
	bonus_hp += amount

func heal_damage(amount: int) -> void:
	if died:
		return
	current_hp += amount


func _on_regen_timer_timeout() -> void:
	if regen > 0:
		current_hp += regen
