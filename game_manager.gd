extends Node

var levers_pulled = 0
var total_levers = 3

signal all_levers_pulled

func lever_activated():
	levers_pulled += 1
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.basic_hud.display_info("Levers pulled: " +  str(levers_pulled), 2.5)

	if levers_pulled >= total_levers:
		emit_signal("all_levers_pulled") 
		player.basic_hud.display_info("THE FINAL DOOR IS OPEN. GO FORTH WITH EFFORT", 5.0)

func reset_levers_count():
	levers_pulled = 0
