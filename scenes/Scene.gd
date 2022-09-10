extends Node2D
class_name Scene

#场景的背景路径
@export_node_path(Sprite2D) var background_path
@export_file("*.mp3") var bgm: String = "res://assets/Music/PaperWings.mp3"


# Called when the node enters the scene tree for the first time.
func _ready():
	SoundManager.play_music(bgm)
