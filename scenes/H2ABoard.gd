@tool
extends Node2D
class_name Board

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

const STONE = preload("res://mini-game/H2AStone.tscn")

# slot_index : H2AStone
var _stone_map: Dictionary = {}

@onready var line_root = %LineRoot
@onready var stone_root = %StoneRoot

func _ready():
	_update_board()

func reset():
	for stone in _stone_map.values():
		_move_stone(stone, _config.placements[stone.target_slot])
	pass

func _draw():
	_draw_slot()

func _draw_slot():
	for slot_index in H2AConfig.Slot.size():
		var _position = _get_slot_postion(slot_index)
		draw_texture(SLOT_TEXTURE, _position - SLOT_TEXTURE.get_size() / 2)

func _update_board():
	
	if !is_inside_tree():
		return
	
	# 移除所有连接节点
	_remove_all_child(line_root)
	# 移除所有棋子节点
	_remove_all_child(stone_root)
	
	var config: H2AConfig = _config as H2AConfig
	if config:
		var connections: Dictionary = config.connections
		var src_arr: Array = connections.keys()
		for src_index in src_arr:
			var dst_arr: Array = connections[src_index]
			for dst_index in dst_arr:
				var _name = str(min(src_index, dst_index)) + "_" + str(max(src_index, dst_index))
				#连线是双向的，检测是否已经添加过
				if line_root.has_node(_name):
					continue
				
				var line = Line2D.new()
				line.add_point(_get_slot_postion(src_index))
				line.add_point(_get_slot_postion(dst_index))
				
				line.texture = LINE_TEXTURE
				line.width = LINE_TEXTURE.get_height()
				line.texture_mode = Line2D.LINE_TEXTURE_TILE
				line.default_color = Color.WHITE
				line.name = _name
				
				line_root.add_child(line)
		
		for slot_index in range(1, H2AConfig.Slot.size()):
			var stone = STONE.instantiate()
			stone_root.add_child(stone)			
			
			stone.name = str(slot_index)
			stone.target_slot = slot_index
			stone.current_slot = config.placements[slot_index]
			stone.position = _get_slot_postion(stone.current_slot)
			stone.interact.connect(self._request_move.bind(stone))
			
			_stone_map[slot_index] = stone
			
func _request_move(stone: H2AStone):
	var aviables = H2AConfig.Slot.values()
	for _stone in _stone_map.values():
		aviables.erase(_stone.current_slot)
	
	var aviable_slot := aviables[0] as int
	if aviable_slot in _config.connections[stone.current_slot]:
		_move_stone(stone, aviable_slot)
	
func _move_stone(stone: H2AStone, slot: int):
	
	stone.current_slot = slot
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(stone, "position", _get_slot_postion(slot), 0.2)
	tween.tween_callback(self._check)
	
func _check():
	
	for stone in _stone_map.values():
		if !stone.is_pass():
			return

	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	for stone in _stone_map.values():
		tween.tween_property(stone, "modulate:a", 0.0, 0.2)
		tween.tween_property(stone, "modulate:a", 1.0, 0.2)
	
	tween.tween_interval(0.5)
	
	await tween.finished
	
	Game.flags.add("h2a_unlocked")
	SceneChanger.change_scene("res://scenes/H2.tscn")	
	
func _get_slot_postion(slot_index: int) -> Vector2:
	return Vector2.DOWN.rotated(TAU / H2AConfig.Slot.size() * slot_index) * _radis

func _remove_all_child(node: Node):
	var children := node.get_children()
	for child in children:
		node.remove_child(child)
		child.queue_free()
