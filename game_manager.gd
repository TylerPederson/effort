extends Node

var levers_pulled = 0
var total_levers = 3

signal all_levers_pulled

func lever_activated():
	levers_pulled += 1
	print("Levers pulled:", levers_pulled)

	if levers_pulled >= total_levers:
		emit_signal("all_levers_pulled") 
		print("THE FINAL DOOR IS OPEN. GO FORTH WITH EFFORT")
