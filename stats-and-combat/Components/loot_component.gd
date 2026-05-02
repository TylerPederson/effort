extends Node3D
class_name LootSpawner

@export var loot_table: LootTable
@onready var confetti: GPUParticles3D = $Confetti

func drop_loot():
	if loot_table.table.is_empty():
		return
	
	var drop_count: int = randi_range(loot_table.loot_min, loot_table.loot_max)
	var dropped: Array[PackedScene]
	
	confetti.restart()
	
	for i in drop_count:
		var loot_scene = loot_table.table.pick_random()
		
		if loot_table.unique_drops:
			while loot_scene in dropped:
				loot_scene = loot_table.table.pick_random()
			dropped.append(loot_scene)
		
		var loot_instance = loot_scene.instantiate()
		
		get_tree().current_scene.add_child(loot_instance)
		
		# --- Spawn Position (small sphere around origin) ---
		loot_instance.global_position = global_position
		
		# --- Direction (outward + slight upward bias) ---
		var direction = (loot_instance.global_position - global_position).normalized()
		direction.y += loot_table.upward_bias
		direction = direction.normalized()
		
		var force = randf_range(loot_table.spawn_force_min, loot_table.spawn_force_max)
		
		# --- Apply movement ---
		if loot_instance is RigidBody3D:
			loot_instance.linear_velocity = direction * force
			
		elif loot_instance.has_method("launch"):
			loot_instance.launch(direction * force)
			
		if loot_table.random_rot:
			loot_instance.rotation = Vector3(
				randf() * TAU,
				randf() * TAU,
				randf() * TAU
			)
		
