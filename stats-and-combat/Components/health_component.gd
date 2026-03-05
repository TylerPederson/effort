extends Node
class_name HealthComponent

signal death

@export var max_hp : int = 50
var current_hp : int = 50
var bonus_hp : int = 0
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
	print("Took damage: ", damage)
	
	if current_hp <= 0:
		death.emit()
		print("object died")
		died = true

func set_bonus_hp(amount: int) -> void:
	if died:
		return
	bonus_hp = max(0, bonus_hp + amount)
	current_hp = max(current_hp, bonus_hp + current_hp)

func heal_damage(amount: int) -> void:
	if died:
		return
	current_hp = min(max_hp + bonus_hp, current_hp + amount)
