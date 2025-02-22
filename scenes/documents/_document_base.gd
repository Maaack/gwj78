@tool
class_name DocumentBase
extends Node2D

signal mouse_entered
signal mouse_exited

var is_mouse_over : bool = false
var is_turned : bool = false

@export var document_data : DocumentData :
	set(value):
		document_data = value
		if is_inside_tree() and document_data:
			%DocumentBody.text = document_data.content

@export var disabled : bool = false

func _ready():
	document_data = document_data


func get_bounds() -> RectangleShape2D:
	var rect = %CollisionShape2D.shape as RectangleShape2D
	return rect


func play_pickup_sound() -> void:
	if %OpenedStreamPlayer2D.playing : return
	%OnMoveShuffleSound.play()


func has_second_page() -> bool:
	return document_data.content_page_2 != null and not document_data.content_page_2.is_empty()


func turn_page() -> void:
	if not has_second_page():
		return
		
	is_turned = !is_turned
	if is_turned:
		%DocumentBody.text = document_data.content_page_2
	else:
		%DocumentBody.text = document_data.content


func _on_area_2d_mouse_entered():
	if disabled: return
	is_mouse_over = true
	mouse_entered.emit()

func _on_area_2d_mouse_exited():
	if disabled: return
	is_mouse_over = false
	mouse_exited.emit()
