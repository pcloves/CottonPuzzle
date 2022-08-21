extends Control
class_name DialogBubble

@onready var content: Label = %Content

# 对话内容
var _dialogs: Array[String] = [];
# 当前对话索引
var _current_line: int = -1;

func _ready():
	hide()

func _show_dialog(dialogs: Array[String]):
	if _dialogs == dialogs and _current_line != -1:
		_advanced()
	else:
		_dialogs = dialogs
		show()
		_show_line(0)
	
func _show_line(line: int):
	_current_line = line
	content.text = _dialogs[_current_line]

func _advanced():
	if _current_line + 1 < _dialogs.size():
		_show_line(_current_line + 1)
	else:
		_current_line = -1
		hide()

func _on_content_gui_input(event):
	if event.is_action_pressed("interact"):
		_advanced()
