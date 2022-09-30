extends Node

const SAVE_PATH := "user://data.sav"

class Flags:
	signal changed
	
	var _flags: Array[String] = []
	
	func has(flag: String) -> bool:
		return flag in _flags
		
	func add(flag: String):
		if has(flag):
			return
		else:
			_flags.append(flag)
			changed.emit()
			
	func to_dict():
		return {
			"flags": _flags,
		}
		
	func from_dict(dict: Dictionary):
		_flags = dict["flags"]
		changed.emit()

	func reset():
		_flags.clear()
		changed.emit()

class Inventory:
	signal changed
	
	# 当前使用中的道具，外界直接修改
	var active_item: Item
	
	var _items : Array[Item] = []
	var _current_item_index := -1
	
	func get_item_count() -> int:
		return _items.size()
		
	func get_current_item() -> Item:
		if _current_item_index == -1:
			return null
		return _items[_current_item_index]
		
	func add_item(item: Item):
		if item in _items:
			return
		_items.append(item)
		# 这是第一个道具，那就自动选中
		if _items.size() == 1:
			select_next()
		changed.emit()
	
	func remove_item(item: Item):
		var index = _items.find(item)
		if index == -1:
			return
		
		_items.remove_at(index)
		# 如果删除的是当前道具或前面的道具，需要把索引往前调一下
		if index <= _current_item_index:
			_current_item_index -= 1
		changed.emit()
		
	func select_next():
		#if _current_item_index == -1:
		#	return
		_current_item_index = (_current_item_index + 1) % _items.size()
		changed.emit()
		
	func select_pre():
		#if _current_item_index == -1:
		#	return
		_current_item_index = (_current_item_index - 1 + _items.size()) % _items.size()
		changed.emit()

	func to_dict():
		
		var names: Array[String] = []
		for item in _items:
			names.append(item.resource_path)
		
		return {
			"items": names,
			"current_item_index": _current_item_index
		}
		
	func from_dict(dict: Dictionary):
		
		_current_item_index = dict["current_item_index"]
		_items.clear()
		
		for item_path in dict["items"]:
			_items.append(load(item_path))
		
		changed.emit()

	func reset():
		_items.clear()
		_current_item_index = -1
		changed.emit()


var flags: Flags = Flags.new()
var inventory: Inventory = Inventory.new()

func back_to_title():
	save_game()
	SceneChanger.change_scene("res://ui/TitleScene.tscn")

func new_game():
	inventory.reset()
	flags.reset()
	SceneChanger.change_scene("res://scenes/H1.tscn")

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	
	var data := {
		"inventory": inventory.to_dict(),
		"flags": flags.to_dict(),
		"current_scene_file_path": get_tree().current_scene.get_scene_file_path()
	}
	
	file.store_string(JSON.stringify(data, "\t"))
	
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)	

	
func load_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
		
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	
	inventory.from_dict(data["inventory"])
	flags.from_dict(data["flags"])
	SceneChanger.change_scene(data["current_scene_file_path"])
	
func exit_game():
	get_tree().quit(0)
