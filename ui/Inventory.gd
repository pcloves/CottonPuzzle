extends Control

var hand_tween: Tween
var label_tween: Tween

@onready var label: Label = %Label
@onready var timer: Timer = %Timer
@onready var pre: TextureButton = %Pre
@onready var prop: Sprite2D = %Prop
@onready var hand: Sprite2D = %Hand
@onready var next: TextureButton = %Next

# Called when the node enters the scene tree for the first time.
func _ready():
	Game.inventory.changed.connect(self._update_ui)
	hand.hide()
	label.hide()
	
	_update_ui()

func _input(event):
	if event.is_action_pressed("interact") && Game.inventory.active_item:
		print("1")
		# Node._input(ev)会被优先调用，后续会触发Control._input_event(ev)，最后触发
		# Node._unhandled_input(ev)，为了不让后续这两个行为产生异常，因此这里延迟设置
		Game.inventory.set_deferred("active_item", null)

		#手消失动画
		hand_tween = create_tween()
		hand_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
		#并行执行
		hand_tween.tween_property(hand, "scale", Vector2.ONE * 2, 1.5)
		hand_tween.tween_property(hand, "modulate:a", 0.0, 1.5).from(1.0)
		#前两条执行完，再串行执行我
		hand_tween.chain().tween_callback(hand.hide)
		
		timer.start()

func _update_ui():
	var item_count = Game.inventory.get_item_count()
	pre.disabled = item_count <= 1
	next.disabled = item_count <= 1
	visible = item_count > 0
	
	var item: Item = Game.inventory.get_current_item()
	if item:
		label.text = item.description
		prop.texture = item.prop_texture
		
		#物品选择动画
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(prop, "scale", Vector2.ONE, 0.15).from(Vector2.ZERO)
		print("2")

func _show_label():
	if label_tween && label_tween.is_valid():
		label_tween.kill()
		label_tween = null
	label.show()
	label.modulate.a = 1
	timer.start()

func _on_pre_pressed():
	Game.inventory.select_pre()
	
	_show_label()

func _on_next_pressed():
	Game.inventory.select_next()
	
	_show_label()

func _on_use_pressed():
	
	if hand_tween && hand_tween.is_valid():
		return
	
	Game.inventory.active_item = Game.inventory.get_current_item()
	
	#手出现动画
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel()
	tween.tween_property(hand, "scale", Vector2.ONE, 0.15).from(Vector2.ZERO)
	tween.tween_property(hand, "modulate:a", 1.0, 0.15).from(0.0)
	tween.chain().tween_callback(hand.show)
	
	_show_label()

func _on_timer_timeout():
	#隐藏道具名称label
	label_tween = create_tween()
	label_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	label_tween.tween_property(label, "modulate:a", 0.0, 0.2).from(1.0)
	label_tween.tween_callback(label.hide)
