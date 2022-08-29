extends Node2D
class_name FlagSwitcher

@export var flag: String

@export_node_path(Node2D) var default_node_path: NodePath
@export_node_path(Node2D) var switched_node_path: NodePath

@onready var default_node: Node2D = get_node(default_node_path)
@onready var switched_node: Node2D = get_node(switched_node_path)

func _ready():
	Game.flags.changed.connect(self._update_node)
	_update_node()

func _update_node():
	if Game.flags.has(flag):
		default_node.visible = false
		switched_node.visible = true
	else:
		default_node.visible = true
		switched_node.visible = false
