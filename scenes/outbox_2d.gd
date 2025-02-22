class_name Outbox2D
extends Node2D

signal document_processed(document_data: DocumentData)

@export var active: bool = true
@export var hover_label: String

var is_mouse_over : bool = false

func process_document(document_base : DocumentBase):
	document_base.disabled = true
	# Run any animation of the document getting processed
	var document_data = document_base.document_data
	document_base.queue_free()
	%OnProcessSound.play()
	%OnProcessParticles.restart()
	await get_tree().create_timer(0.5).timeout
	document_processed.emit(document_data)

func _on_area_2d_mouse_entered():
	is_mouse_over = true

func _on_area_2d_mouse_exited():
	is_mouse_over = false
