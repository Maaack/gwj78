@tool
class_name DocumentBase
extends Node2D

signal mouse_entered
signal mouse_exited

var is_mouse_over : bool = false

@export var document_data : DocumentData :
	set(value):
		document_data = value
		if is_inside_tree() and document_data:
			%DocumentBody.text = document_data.content

@export var disabled : bool = false

func get_bounds() -> RectangleShape2D:
	var rect = %CollisionShape2D.shape as RectangleShape2D
	return rect

func _on_area_2d_mouse_entered():
	if disabled: return
	is_mouse_over = true
	mouse_entered.emit()

func _on_area_2d_mouse_exited():
	if disabled: return
	is_mouse_over = false
	mouse_exited.emit()

func _ready():
	document_data = document_data
