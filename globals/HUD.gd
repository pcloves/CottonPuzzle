extends CanvasLayer

func _enter_tree():
	get_tree().node_added.connect(self._node_added)

func _on_menu_pressed():
	Game.back_to_title()

func _node_added(node: Node):
	if node is Scene:
		visible = true
	if node is TitleScene:
		visible = false
