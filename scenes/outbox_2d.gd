extends Node2D

var is_mouse_over : bool = false

func _on_area_2d_mouse_entered():
	is_mouse_over = true

func _on_area_2d_mouse_exited():
	is_mouse_over = false
