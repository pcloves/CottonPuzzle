extends Area2D
class_name Interactable

signal interact

func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("interact"):
		_interact();
	
func _interact():
	interact.emit()
