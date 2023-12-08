extends Resource

@export var records: Array


func parse_remove_empty_eol() -> void:
	if len(records) < 1 or typeof(records[0]) != TYPE_ARRAY:
		return
	
	for line in records:
		if typeof(line) != TYPE_ARRAY:
			continue
		
		if typeof(line[-1]) == TYPE_STRING and line[-1] == "":
			line.remove_at(len(line) - 1)
