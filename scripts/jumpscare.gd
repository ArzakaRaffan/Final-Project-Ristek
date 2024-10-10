extends Node2D
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer

func _on_video_stream_player_finished() -> void:
	get_tree().quit()
