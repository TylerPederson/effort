extends ShapeCast3D

func set_group(group : String):
	add_to_group(group)

func deal_damage(damage) -> void:
	if not is_colliding():
		return
	
	if get_collision_count() < 1:
		return
		
	for i in range(get_collision_count()):
		var c = get_collider(i)
		if c is CollisionShape3D:
			add_exception(c)
			force_shapecast_update()
		if c is HitboxComponent:
			add_exception(c)
			force_shapecast_update()
			for group in get_groups():
				if group in c.get_parent().get_groups():
					break
				
				var hb_component : HitboxComponent = c
				hb_component.receive_damage(damage)
	
	
