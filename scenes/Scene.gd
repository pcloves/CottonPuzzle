extends Node2D

#场景的背景路径
@export_node_path(Sprite2D) var background_path

func _ready():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(get_node(background_path), "scale", Vector2.ONE, 0.4).from(Vector2.ONE * 1.05)
