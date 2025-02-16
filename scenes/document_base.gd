@tool
class_name DocumentBase
extends Node2D


signal mouse_entered
signal mouse_exited

@export_multiline var content : String :
	set(value):
		content = value
		if is_inside_tree():
			%DocumentBody.text = content

func _on_area_2d_mouse_entered():
	mouse_entered.emit()

func _on_area_2d_mouse_exited():
	mouse_exited.emit()

func _ready():
	content = content
