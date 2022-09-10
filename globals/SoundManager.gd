extends Node

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer


func play_music(path: String):
	if audio_stream_player.playing && audio_stream_player.stream.resource_path == path:
		return
		
	audio_stream_player.stream = load(path)
	audio_stream_player.play()
