extends RayCast3D

func deal_damage(damage) -> void:
	if not is_colliding():
		return
	var collider = get_collider()
	if collider is not HitboxComponent:
		return
	
	add_exception(collider)
	
	var hb_component : HitboxComponent = collider
	print(hb_component)
	hb_component.receive_damage(damage)
	
	
