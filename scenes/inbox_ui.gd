extends Control

signal pressed

func _on_texture_button_pressed():
	pressed.emit()
