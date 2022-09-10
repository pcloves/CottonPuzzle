@tool
extends Resource
class_name H2AConfig

const PrefixPlacements := "placements/"
const PrefixConnections := "connections/"

enum Slot {
	NULL,
	TIME,
	SUN,
	FISH,
	HILL,
	CROSS,
	CHOICE
}

var placements := PackedFloat32Array()
# index -> array[index]
var connections : Dictionary = {}

func _init():
	placements.resize(Slot.size())
	placements.fill(Slot.NULL)
	
	for slot in Slot.values():
		connections[slot] = []

func _get_property_list():
	# 真正要存储到tres内的变量
	var properties := [
		{
			name = "placements",
			type = TYPE_PACKED_INT32_ARRAY,
			usage = PROPERTY_USAGE_STORAGE
		},
		{
			name = "connections",
			type = TYPE_DICTIONARY,
			usage = PROPERTY_USAGE_STORAGE
		}
	]
	
	#显示到右侧Inspector面板的变量
	for slot in Slot.size():
		properties.append({
			name = PrefixPlacements + Slot.keys()[slot],
			type = TYPE_INT,
			usage = PROPERTY_USAGE_EDITOR,
			hint = PROPERTY_HINT_ENUM,
			hint_string = ",".join(PackedStringArray(Slot.keys()))
		})
		
	for slot in Slot.size() - 1:
		var available := PackedStringArray()
		for dst in Slot.size():
			#slot前面的槽位（dst）不允许设置
			available.append("" if dst <= slot else Slot.keys()[dst])
		#print("available:", available)
		
		properties.append({
			name = PrefixConnections + Slot.keys()[slot],
			type = TYPE_INT,
			usage = PROPERTY_USAGE_EDITOR,
			hint = PROPERTY_HINT_FLAGS,
			hint_string = ",".join(available)
		})
		
		print("properties:", properties[properties.size() - 1])
		
	print("----------------------------------------------------------------------------------")
	return properties
	
func _get(property: StringName):
	var property_string = String(property)
	if property_string.begins_with(PrefixPlacements):
		property_string = property_string.trim_prefix(PrefixPlacements)
		var index = Slot[property_string] as int
		
		#print("_get:", String(property), ",value:", placements[index])
		return placements[index]
		
	if property_string.begins_with(PrefixConnections):
		property_string = property_string.trim_prefix(PrefixConnections)
		var index = Slot[property_string] as int
		var value := 0
		for dst in connections[index]:
			if dst in connections[index]:
				value |= (1 << dst)
			
		return value
		
	return null
	
func _set(property, value):
	print("_set:", String(property), ", value:", str(value))
	var property_string = String(property)
	if property_string.begins_with(PrefixPlacements):
		property_string = property_string.trim_prefix(PrefixPlacements)
		var index = Slot[property_string] as int
		
		placements[index] = value
		emit_changed()
		return true
		
	if property_string.begins_with(PrefixConnections):
		property_string = property_string.trim_prefix(PrefixConnections)
		var index = Slot[property_string] as int
		
		for dst in range(index + 1, Slot.size()):
			_set_connected(index, dst, value & (1 << dst))
		emit_changed()
		return true	
		
	return false

func _set_connected(src: int, dst: int, connected: bool):
	var src_arr := connections[src] as Array
	var dst_arr := connections[dst] as Array
	var src_idx := src_arr.find(dst)
	var dst_idx := dst_arr.find(src)
	
	if connected:
		if src_idx == -1:
			src_arr.append(dst)
		if dst_idx == -1:
			dst_arr.append(src)
	else:
		if src_idx != -1:
			src_arr.remove_at(src_idx)
		if dst_idx != -1:
			dst_arr.remove_at(dst_idx)
