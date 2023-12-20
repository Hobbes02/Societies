extends Node

var active_tasks: Array = []
var completed_tasks: Array = []

var task_history: Array[Array] = []


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
