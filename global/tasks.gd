extends Node

var active_tasks: Array = []
var completed_tasks: Array = []

var task_history: Array[Array] = []


func _ready() -> void:
	SaveManager.about_to_save.connect(_about_to_save)
	
	active_tasks = SaveManager.save_data.get("tasks", {}).get("active_tasks", active_tasks)
	completed_tasks = SaveManager.save_data.get("tasks", {}).get("completed_tasks", completed_tasks)


func _about_to_save(reason: SaveManager.SaveReason) -> void:
	SaveManager.save_data.tasks = SaveManager.save_data.get("tasks", SaveManager.DEFAULT_SAVE_DATA.tasks)
	SaveManager.save_data.tasks.active_tasks = active_tasks
	SaveManager.save_data.tasks.completed_tasks = completed_tasks


func assign_task(task_name: String, show_notification: bool = true) -> void:
	active_tasks.append(task_name)
	task_history.append(["add", task_name])


func complete_task(task_name: String, show_notification: bool = true) -> void:
	if task_name not in active_tasks:
		return
	
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
