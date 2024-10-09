extends Node2D

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var texture_progress_bar_2: TextureProgressBar = $TextureProgressBar2

func _physics_process(delta: float) -> void:
	texture_progress_bar.value = Global.sprint_value
	texture_progress_bar_2.value = Global.sprint_value
