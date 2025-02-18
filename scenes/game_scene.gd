extends Node

signal level_complete

@export var document_scene : PackedScene
@export var documents : Array[DocumentData]

var _highlighted_document : DocumentBase
var _active_document : DocumentBase
var _documents : Array[DocumentData]
var _archived_documents : Array[DocumentData]
var _redacted_documents : Array[DocumentData]
var _processed_documents : Array[DocumentData]

var _last_mouse_position : Vector2
var points_scored : int = 0 :
	set(value):
		points_scored = value
		if is_inside_tree():
			%ScoreLabel.text = "%d" % points_scored

func pickup_inbox_document():
	if is_instance_valid(_active_document):
		return
	if _documents.is_empty():
		return
	var next_document : DocumentData = _documents.pop_back()
	var document_instance : DocumentBase = document_scene.instantiate()
	document_instance.position = _last_mouse_position
	document_instance.document_data = next_document
	document_instance.mouse_entered.connect(_update_highlighted_document)
	document_instance.mouse_exited.connect(_update_highlighted_document)
	%ActiveContainer.add_child(document_instance)
	_active_document = document_instance

func pickup_highlighted_document():
	if is_instance_valid(_active_document):
		return
	_active_document = _highlighted_document
	if _active_document == null : 
		return
	_highlighted_document = null
	_active_document.reparent(%ActiveContainer)
	_update_active_document_position()

func _update_active_document_position():
	if not is_instance_valid(_active_document):
		return
	_active_document.position = _last_mouse_position

func is_level_complete():
	return _processed_documents.size() >= documents.size()

func _finish_level_if_complete():
	if is_level_complete():
		print("LEVEL COMPLETE")
		level_complete.emit()

func drop_document():
	if not is_instance_valid(_active_document):
		return
	if _active_document is DocumentBase:
		if %Outbox2D.is_mouse_over or %Furnace2D.is_mouse_over:
			_processed_documents.append(_active_document.document_data)
			if %Furnace2D.is_mouse_over:
				_redacted_documents.append(_active_document.document_data)
			else:
				_archived_documents.append(_active_document.document_data)
			if _active_document.document_data.is_dangerous == %Furnace2D.is_mouse_over:
				points_scored += 1
			else:
				points_scored -= 1
			_active_document.queue_free()
			_active_document = null
			_finish_level_if_complete()
			return
	_active_document.reparent(%Container)
	_highlighted_document = _active_document
	_active_document = null

func _on_inbox_ui_pressed():
	pickup_inbox_document()

func _ready():
	_documents = documents.duplicate()
	_documents.shuffle()

func _update_highlighted_document():
	var _first_doc_
	var container_children : Array = %Container.get_children()
	container_children.reverse()
	for child in container_children:
		if child is DocumentBase:
			if child.is_mouse_over:
				_highlighted_document = child
				return
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
