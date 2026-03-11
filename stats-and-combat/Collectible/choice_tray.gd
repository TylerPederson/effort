extends Node3D

static var to_collect = [
	Collectible.TYPE.HP_REGEN,
	Collectible.TYPE.HP_BOOST,
	Collectible.TYPE.STAMINA_REGEN,
	Collectible.TYPE.STAMINA_BOOST,
	Collectible.TYPE.BONUS_FLAT_ARMOR,
	Collectible.TYPE.BONUS_RATIO_ARMOR,
	Collectible.TYPE.SPRINT_USE_RATIO,
	Collectible.TYPE.SPRINT_SPEED_BOOST,
	Collectible.TYPE.DAMAGE_BOOST,
	Collectible.TYPE.DAMAGE_COOLDOWN
]


func _ready() -> void:
	%Collectible1.set_type(select_available())
	%Collectible2.set_type(select_available())
	%Collectible3.set_type(select_available())
	process_mode = Node.PROCESS_MODE_DISABLED
	%Collectible1.visible = false
	%Collectible2.visible = false
	%Collectible3.visible = false

func activate():
	process_mode = Node.PROCESS_MODE_INHERIT
	%Collectible1.visible = true
	%Collectible2.visible = true
	%Collectible3.visible = true


func select_available() -> Collectible.TYPE:
	if to_collect.is_empty():
		return Collectible.TYPE.HP_REGEN
		
	var type = to_collect.pick_random()
	to_collect.erase(type)
	return type

func _on_collectible_1_collected(type: Collectible.TYPE) -> void:
	to_collect.append(%Collectible2.type)
	to_collect.append(%Collectible3.type)
	queue_free()


func _on_collectible_2_collected(type: Collectible.TYPE) -> void:
	to_collect.append(%Collectible1.type)
	to_collect.append(%Collectible3.type)
	queue_free()


func _on_collectible_3_collected(type: Collectible.TYPE) -> void:
	to_collect.append(%Collectible1.type)
	to_collect.append(%Collectible2.type)
	queue_free()
