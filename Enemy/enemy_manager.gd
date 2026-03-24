extends Node3D
class_name EnemyManager

signal all_enemies_defeated

var enemies : int = 0

# All enemies who are connected to this manager from the editor will register themselves
# when they enter the game_tree
func link(enemy):
	enemy.died.connect(_on_enemy_death)
	enemies += 1

# all enemies in a location that are registered to this manager have been
# defeated. Some other node may hear all_enemies_defeated signal and 
# perform some action or give some reward
func _on_enemy_death():
	enemies -= 1
	if enemies <= 0:
		all_enemies_defeated.emit()
