@tool
extends Node2D

@export var _radis: float = 100.0:
	set(value):
		_radis = value
		queue_redraw()

@export var _config: Resource:
	set(value):
		var config_old = _config as H2AConfig
		# 移除老配置的监听
		if config_old && config_old.changed.is_connected(self._update_board):
			config_old.changed.disconnect(self._update_board)
		
		_config = value
		
		# 开启新配置的监听
		if _config && !_config.changed.is_connected(self._update_board):
			_config.changed.connect(self._update_board)

const LINE_TEXTURE: Texture2D = preload("res://assets/H2A/CIRCLELINE.png")
const SLOT_TEXTURE: Texture2D = preload("res://assets/H2A/CIRCLE.png")


@onready var line_root = %LineRoot

func _ready():
	_update_board()

func _draw():
	_draw_slot()

func _draw_slot():
	for slot_index in H2AConfig.Slot.size():
		var _position = _get_slot_postion(slot_index)
		draw_texture(SLOT_TEXTURE, _position - SLOT_TEXTURE.get_size() / 2)

func _update_board():
	
	# 移除所有连接节点
	var children := line_root.get_children()
	for child in children:
		line_root.remove_child(child)
		child.queue_free()
	
	var config: H2AConfig = _config as H2AConfig
	if config:
		var connections: Dictionary = config.connections
		var src_arr: Array = connections.keys()
		for src_index in src_arr:
			var dst_arr: Array = connections[src_index]
			for dst_index in dst_arr:
				var name = str(min(src_index, dst_index)) + "_" + str(max(src_index, dst_index))
				#连线是双向的，检测是否已经添加过
				if line_root.has_node(name):
					continue
				
				var line = Line2D.new()
				line.add_point(_get_slot_postion(src_index))
				line.add_point(_get_slot_postion(dst_index))
				
				line.texture = LINE_TEXTURE
				line.width = LINE_TEXTURE.get_height()
				line.texture_mode = Line2D.LINE_TEXTURE_TILE
				line.default_color = Color.WHITE
				line.name = name
				
				line_root.add_child(line)
	

func _get_slot_postion(slot_index: int) -> Vector2:
	return Vector2.DOWN.rotated(TAU / H2AConfig.Slot.size() * slot_index) * _radis
