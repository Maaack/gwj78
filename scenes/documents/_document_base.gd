@tool
class_name DocumentBase
extends Node2D

signal mouse_entered
signal mouse_exited

var is_mouse_over : bool = false
var modulate_tween: Tween
var is_turned : bool = false

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
	
func play_pickup_sound(from_inbox: bool) -> void:
	if from_inbox:
		%OpenedStreamPlayer2D.play()
	else:
		if not %OpenedStreamPlayer2D.playing:
			%OnMoveShuffleSound.play()

func modulate_state(state_key: String) -> void:
	var state_machine = %HoverModulationTree["parameters/playback"] as AnimationNodeStateMachinePlayback
	state_machine.travel(state_key)


func has_second_page() -> bool:
	if not document_data:
		return false
	
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
