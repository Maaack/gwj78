class_name Inbox2D
extends Node2D

@export var has_documents : bool = true :
	set(value):
		has_documents = value
		if is_inside_tree():
			%FilesSprite2D.visible = has_documents

var is_mouse_over : bool = false

func _on_area_2d_mouse_entered():
	is_mouse_over = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_area_2d_mouse_exited():
	is_mouse_over = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
