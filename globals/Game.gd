extends Node

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

var flags: Flags = Flags.new()
var inventory: Inventory = Inventory.new()
