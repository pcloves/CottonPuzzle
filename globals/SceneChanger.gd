extends CanvasLayer

signal scene_loaded

@onready var color_rect: ColorRect = %ColorRect
@onready var progress_bar: ProgressBar = %ProgressBar

var loading: bool = false
var loading_path: String

func _ready():
	set_process(false)

func change_scene(path: String):
	
	if loading:
		return
	
	var tween = create_tween()
	
	#先显示出来
	tween.tween_callback(color_rect.show)
	#透明渐变黑
	tween.tween_property(color_rect, "color:a", 1.0, 0.2)
	
	print("----load request----")
	#多线程加载
	ResourceLoader.load_threaded_request(path, "", true)
	
	loading = true
	progress_bar.visible = true
	loading_path = path
	
	set_process(true)
	
	#等待加载完毕
	await scene_loaded
	
	#竟然不能继续使用上面的tween，否则会有报错~
	var tween1 = create_tween()
	#黑色渐变透明
	tween1.tween_property(color_rect, "color:a", 0.0, 0.2)
	#隐藏
	tween1.tween_callback(color_rect.hide)
	#切换场景
	tween1.tween_callback(get_tree().change_scene_to_packed.bind(ResourceLoader.load_threaded_get(loading_path)))
	
	loading = false	
	progress_bar.visible = false
	loading_path = ""
	
	set_process(false)	

func _process(_delta):
	
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(loading_path, progress)
	
	match status:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			progress_bar.ratio = progress[0]
			print("load in progress:", progress_bar.ratio)
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			print("load loaded")
			scene_loaded.emit()
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			print("load failed")
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			print("load invalid resource")
