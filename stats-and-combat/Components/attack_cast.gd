extends RayCast3D

func set_group(group : String):
	add_to_group(group)

func deal_damage(damage) -> void:
	if not is_colliding():
		return
	var collider = get_collider()
	if collider is not HitboxComponent:
		return
	
	add_exception(collider)
	
	for group in get_groups():
		if group in collider.get_parent().get_groups():
			return
	
	var hb_component : HitboxComponent = collider
	hb_component.receive_damage(damage)
	
