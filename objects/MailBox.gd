extends FlagSwitcher


func _on_interactable_interact():
	var item: Item = Game.inventory.get_current_item()
	var item_key: Item = preload("res://items/Key.tres")
	if not item || item != item_key:
		return
	
	Game.flags.add(flag)
	Game.inventory.remove_item(item)
