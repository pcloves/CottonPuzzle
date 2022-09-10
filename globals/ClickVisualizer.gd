extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	layer = 99
	

func _input(event):
	if not event.is_action("interact"):
		return
	
	var sprite: Sprite2D = Sprite2D.new()
	
	sprite.texture = preload("res://assets/UI/click.svg")
	sprite.global_position = get_viewport().get_mouse_position()
	
	add_child(sprite)
	
	var tween = create_tween()
	
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.3).from(Vector2.ONE * 0.5)
	tween.parallel().tween_property(sprite, "modulate:a", 1.0, 0.3).from(0.0)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_callback(sprite.queue_free)
