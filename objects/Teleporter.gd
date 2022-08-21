extends Interactable
class_name Teleporter

@export_file("*.tscn") var target_scene : String

func _interact():
	super._interact()
	SceneChanger.change_scene(target_scene)
