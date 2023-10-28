extends Node

var active_tasks: Array = []
var completed_tasks: Array = []

var task_history: Array[Array] = []


func _ready() -> void:
	SaveManager.about_to_save.connect(_about_to_save)
	SaveManager.just_loaded.connect(_just_loaded)


func _about_to_save() -> void:
	SaveManager.save_data.tasks.active_tasks = active_tasks
	SaveManager.save_data.tasks.completed_tasks = completed_tasks


func _just_loaded() -> void:
	active_tasks = SaveManager.get_value("tasks/active_tasks", active_tasks)
	completed_tasks = SaveManager.get_value("tasks/completed_tasks", completed_tasks)


func assign_task(task_name: String) -> void:
	active_tasks.append(task_name)
	task_history.append(["add", task_name])


func complete_task(task_name: String) -> void:
	active_tasks.erase(task_name)
	task_history.append(["complete", task_name])
	completed_tasks.append(task_name)


func remove_task(task_name: String) -> void:
	active_tasks.erase(task_name)
	task_history.append(["remove", task_name])


func is_doing_task(task_name: String) -> bool:
	return task_name in active_tasks


func has_completed_task(task_name: String) -> bool:
	return task_name in completed_tasks
