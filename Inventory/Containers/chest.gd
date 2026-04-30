extends Node3D
class_name Chest

@onready var envio_interact: EnvioInteract = $EnvioInteract
@onready var loot_component: LootSpawner = $LootComponent
@onready var chest_lid: MeshInstance3D = $Armature/Bone/Bone_001/Chest_Top
@onready var open_lid_collison: CollisionShape3D = $OpenLidCollison

func _ready() -> void:
	envio_interact.parent = self
	open_lid_collison.disabled = true

func interact() -> void:
	var tween = create_tween()
	tween.tween_property(chest_lid, "rotation_degrees:x", -230, 0.5)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	open_lid_collison.disabled = false
	loot_component.drop_loot()
	
	if envio_interact.one_shot:
		envio_interact.queue_free()
