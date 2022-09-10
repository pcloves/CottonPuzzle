extends TextureRect
class_name TitleScene

@onready var load_button: Button = %Load

func _ready():
	load_button.disabled = not Game.has_save_file()

func _on_exit_pressed():
	Game.exit_game()

func _on_load_pressed():
	Game.load_game()

func _on_new_pressed():
	Game.new_game()
