extends Node

signal time_of_day_changed(to: String)

var time_of_day = "day": 
	set(new_value):
		time_of_day = new_value
		time_of_day_changed.emit(new_value)


var chunks_data: Dictionary = {}
