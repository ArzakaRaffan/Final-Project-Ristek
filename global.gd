extends Node

var sprint_value = 100

func _process(delta: float) -> void:
	if sprint_value > 100:
		sprint_value = 100
	elif sprint_value < 0:
		sprint_value = 0
