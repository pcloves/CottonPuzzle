@tool
extends Node2D

@export var _radis: float = 100.0:
	set(value):
		_radis = value
		update()

@export var _config: Resource:
	set(value):
		var config_old = _config as H2AConfig
		_config = value
		_update_board(config_old)

const LINE_TEXTURE: Texture2D = preload("res://assets/H2A/CIRCLELINE.png")
const SLOT_TEXTURE: Texture2D = preload("res://assets/H2A/CIRCLE.png")


@onready var line_root = %LineRoot

func _ready():
	pass

func _draw():
	_draw_slot()

func _draw_slot():
	for slot_index in H2AConfig.Slot.size():
		var _position = _get_slot_postion(slot_index)
		draw_texture(SLOT_TEXTURE, _position - SLOT_TEXTURE.get_size() / 2)

func _update_board(config_old: H2AConfig):
	# 移除老配置的监听
	if config_old && config_old.changed.is_connected(self._update_board):
		config_old.changed.disconnect(self._update_board)
	
	# 开启新配置的监听
	if _config && !_config.changed.is_connected(self._update_board):
		_config.changed.connect(self._update_board)
	
	# 移除所有连接节点
	var children := line_root.get_children()
	for child in children:
		line_root.remove_child(child)
		child.queue_free()
	
	
	
	
	
	
	

func _get_slot_postion(slot_index: int) -> Vector2:
	return Vector2.DOWN.rotated(TAU / H2AConfig.Slot.size() * slot_index) * _radis