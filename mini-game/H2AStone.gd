@tool
extends Interactable
class_name H2AStone

@export_range(1, 6, 1) var target_slot: int = 1:
	set(value):
		target_slot = value
		_update_texture()
		
@export_range(1, 6, 1) var current_slot: int = 1:
	set(value):
		current_slot = value
		_update_texture()

@export_node_path(Sprite2D) var sprite_path: NodePath

func _ready():
	_update_texture()

func _update_texture():
	
	if !is_inside_tree():
		return
		
	var sprite: Sprite2D = get_node(sprite_path)
	
	if current_slot != target_slot:
		sprite.texture = load("res://assets/H2A/SS_%02d_x.png" % target_slot)
	else:
		sprite.texture = load("res://assets/H2A/SS_%02d.png" % target_slot)

func is_pass() -> bool:
	return current_slot == target_slot
