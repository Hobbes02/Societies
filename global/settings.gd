extends Node

var tab: int = 0

var settings_file: String = "user://settings.txt"

var write_read: FileAccess = FileAccess.open(settings_file, FileAccess.WRITE_READ)
