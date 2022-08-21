extends Interactable
class_name SceneItem

@export var _item: Resource

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

func _ready():
	if Game.flags.has(_get_flag()):
		queue_free()
		return
	
	sprite_2d.texture = _item.scene_texture
	collision_shape_2d.shape.size = sprite_2d.texture.get_size()

func _interact():
	super._interact()
	
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * 1.5, 0.5)
	tween.tween_property(sprite_2d, "modulate:a", 0.0, 0.5)

	# 等待tween动画
	await tween.finished
	
	Game.flags.add(_get_flag())
	queue_free()

func _get_flag():
	return "picked:" + _item.resource_path.get_file()
