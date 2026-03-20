extends Node3D

@onready var target_dummy_mesh: Node3D = $TargetDummyMesh
@onready var destroyed_mesh: Node3D = $DestroyedMesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is HealthComponent:
			child.death.connect(_on_death)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_death():
	target_dummy_mesh.visible = false
	destroyed_mesh.visible = true
	await get_tree().create_timer(2.0).timeout
	queue_free()
	
