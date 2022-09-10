extends Interactable

@onready var gear: Sprite2D = %Gear
@onready var board: Board = %Board

func _interact():
	super._interact()
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(gear, "rotation", 360, 0.5).as_relative()
	tween.tween_callback(board.reset)
