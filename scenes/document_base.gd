@tool
class_name DocumentBase
extends Node2D


signal mouse_entered
signal mouse_exited

var is_mouse_over : bool = false

@export_multiline var content : String :
	set(value):
		content = value
		if is_inside_tree():
			%DocumentBody.text = content

func _on_area_2d_mouse_entered():
	is_mouse_over = true
	mouse_entered.emit()

func _on_area_2d_mouse_exited():
	is_mouse_over = false
	mouse_exited.emit()

func _ready():
	content = content
