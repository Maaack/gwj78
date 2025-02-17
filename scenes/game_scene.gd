extends Node

@export var document_scene : PackedScene
@export var documents : Array[DocumentData]

var _highlighted_document : Node2D
var _active_document : Node2D
var _documents : Array[DocumentData]

var _last_mouse_position : Vector2

func pickup_inbox_document():
	if is_instance_valid(_active_document):
		return
	if _documents.is_empty():
		return
	var next_document : DocumentData = _documents.pop_back()
	var document_instance : DocumentBase = document_scene.instantiate()
	document_instance.position = _last_mouse_position
	document_instance.content = next_document.content
	document_instance.mouse_entered.connect(_highlight_document.bind(document_instance))
	document_instance.mouse_exited.connect(_unhighlight_document.bind(document_instance))
	%ActiveContainer.add_child(document_instance)
	_active_document = document_instance

func pickup_highlighted_document():
	if is_instance_valid(_active_document):
		return
	_active_document = _highlighted_document
	if _active_document == null : return
	_highlighted_document = null
	_active_document.reparent(%ActiveContainer)
	_update_active_document_position()

func _update_active_document_position():
	if not is_instance_valid(_active_document):
		return
	_active_document.position = _last_mouse_position

func drop_document():
	if not is_instance_valid(_active_document):
		return
	_active_document.reparent(%Container)
	_active_document = null

func _on_inbox_ui_pressed():
	pickup_inbox_document()

func _ready():
	_documents = documents.duplicate()
	_documents.shuffle()

func _highlight_document(document_node : Node2D):
	_highlighted_document = document_node

func _unhighlight_document(document_node : Node2D):
	if _highlighted_document == document_node:
		_highlighted_document = null

func _input(event):
	if event is InputEventMouseMotion:
		_last_mouse_position = event.position
		_update_active_document_position()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if _active_document:
				drop_document()
			else:
				pickup_highlighted_document()
