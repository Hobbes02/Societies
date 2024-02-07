extends Node

func assemble_linked_lists(keys: Array, values: Array) -> Dictionary:
	@warning_ignore("unassigned_variable")
	var res: Dictionary
	for i in range(len(keys)):
		if i < len(values):
			res[keys[i]] = values[i]
	return res


func slice_string(string: String, from: int, to: int) -> String:
	var res: String
	
	for i in range(from, to, 1):
		res += string[i]
	
	return res
