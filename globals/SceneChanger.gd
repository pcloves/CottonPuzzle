extends CanvasLayer

@onready var color_rect: ColorRect = %ColorRect

func change_scene(path: String):
	var tween = create_tween()
	
	#先显示出来
	tween.tween_callback(color_rect.show)
	#透明渐变黑
	tween.tween_property(color_rect, "color:a", 1.0, 0.2)
	#切换场景
	tween.tween_callback(get_tree().change_scene.bind(path))
	#黑色渐变透明
	tween.tween_property(color_rect, "color:a", 0.0, 0.2)
	#隐藏
	tween.tween_callback(color_rect.hide)
