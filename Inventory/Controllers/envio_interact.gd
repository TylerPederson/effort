extends Node
class_name EnvioInteract

@export var remove_on_interact: bool = false
@export var one_shot: bool = false
@export var interaction_sound_effect: AudioStreamMP3

var parent

func interact() -> void:
	parent.interact()
