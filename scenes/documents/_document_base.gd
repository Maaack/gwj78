@tool
class_name DocumentBase
extends Node2D

signal mouse_entered
signal mouse_exited

var is_mouse_over : bool = false

@export var document_data : DocumentData :
	set(value):
		document_data = value
		if is_inside_tree():
			if document_data:
				%DocumentBody.text = document_data.content	
			_update_collider()

@export var disabled : bool = false

func _ready():
	document_data = document_data
	
func _update_collider() -> void:
	await get_tree().process_frame #wait one frame for content size to update
	var collider = %CollisionShape2D.shape as RectangleShape2D
	collider.size = %PanelContainer.size
	
func get_bounds() -> RectangleShape2D:
	var collider = %CollisionShape2D.shape as RectangleShape2D
	return collider
	
func play_pickup_sound() -> void:
	if %OpenedStreamPlayer2D.playing : return
	%OnMoveShuffleSound.play()

func _on_area_2d_mouse_entered():
	if disabled: return
	is_mouse_over = true
	mouse_entered.emit()

func _on_area_2d_mouse_exited():
	if disabled: return
	is_mouse_over = false
	mouse_exited.emit()
