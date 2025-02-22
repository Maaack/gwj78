class_name CursorFollower extends Node2D

static var instance: CursorFollower

func _ready() -> void:
	instance = self

func _process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	position = mouse_position
		
func set_text(text: String) -> void:
	%CursorHint.text = text
	%CursorHintPanel.show()
	
func clear_text() -> void:
	%CursorHint.text = ""
	%CursorHintPanel.hide()
