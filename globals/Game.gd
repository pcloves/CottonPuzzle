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

var flags: Flags = Flags.new()
