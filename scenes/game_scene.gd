class_name GameScene
extends Node

signal level_complete

const INITIAL_PICKUP_OFFSET_FRACTION: float = 0.5
const PICKUP_ROTATION : float = -5

@export var document_scene : PackedScene
@export var documents : Array[DocumentData]
@export var dialogue_balloon_scene : PackedScene
@export var dialogue_resource : DialogueResource
@export var opening_dialogue : StringName

var _highlighted_document : DocumentBase
var _active_document : DocumentBase
var _documents : Array[DocumentData]
var _archived_documents : Array[DocumentData]
var _redacted_documents : Array[DocumentData]
var _processed_documents : Array[DocumentData]

var level_state : LevelState
var _pickup_offset : Vector2
var _last_mouse_position : Vector2
var points_scored : int = 0 :
	set(value):
		points_scored = value
		_update_level_data()
		_update_score_label()

func _update_score_label():
	if is_inside_tree():
		%ScoreLabel.text = "%d" % points_scored

func _update_level_data():
	if level_state:
		level_state.points = points_scored

func pickup_inbox_document():
	if is_instance_valid(_active_document):
		return
	if _documents.is_empty():
		return
	var next_document : DocumentData = _documents.pop_back()
	var document_instance : DocumentBase = document_scene.instantiate()
	_pickup_offset = Vector2(0, (document_instance.get_bounds().size.y * 0.5) * INITIAL_PICKUP_OFFSET_FRACTION)
	document_instance.rotation_degrees = PICKUP_ROTATION
	document_instance.position = _last_mouse_position + _pickup_offset
	document_instance.document_data = next_document
	document_instance.mouse_entered.connect(_update_highlighted_document)
	document_instance.mouse_exited.connect(_update_highlighted_document)
	%ActiveContainer.add_child(document_instance)
	_active_document = document_instance
	%Inbox2D.has_documents = !(_documents.is_empty())

func pickup_highlighted_document():
	if is_instance_valid(_active_document):
		return
	_active_document = _highlighted_document
	if _active_document == null : 
		return
	_highlighted_document = null
	_pickup_offset = -(_last_mouse_position - _active_document.position)
	_active_document.rotation_degrees = PICKUP_ROTATION
	_active_document.reparent(%ActiveContainer)
	_update_active_document_position()

func _update_active_document_position():
	if not is_instance_valid(_active_document):
		return
	#Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	_active_document.position = _last_mouse_position + _pickup_offset

func is_level_complete():
	return _processed_documents.size() >= documents.size()

func _finish_level_if_complete():
	if is_level_complete():
		level_complete.emit()

func get_mouse_over_outbox() -> Outbox2D:
	for child in %Outboxes.get_children():
		if child is Outbox2D:
			if child.is_mouse_over: 
				return child
	return null

func drop_document():
	if not is_instance_valid(_active_document):
		return
	if _active_document is DocumentBase and _active_document.document_data:
		var outbox := get_mouse_over_outbox()
		if outbox is Outbox2D:
			outbox.process_document(_active_document)
			_active_document = null
			_finish_level_if_complete()
			return
	_active_document.rotation_degrees = 0
	_active_document.reparent(%Container)
	_highlighted_document = _active_document
	_active_document = null

func document_processed(document_data : DocumentData):
	_processed_documents.append(document_data)
	_finish_level_if_complete()

func _should_document_be_redacted(document_data : DocumentData) -> bool:
	for rule in _find_rules():
		if rule.should_redact(document_data):
			return true
	return false

func _on_document_archived(document_data : DocumentData):
	_archived_documents.append(document_data)
	var should_redact := _should_document_be_redacted(document_data)
	points_scored += 1 if not should_redact else -1
	for rule in _find_rules():
		rule.on_archived(document_data)
	document_processed(document_data)

func _on_document_redacted(document_data : DocumentData):
	_redacted_documents.append(document_data)
	var should_redact := _should_document_be_redacted(document_data)
	points_scored += 1 if should_redact else -1
	for rule in _find_rules():
		rule.on_redacted(document_data)
	document_processed(document_data)

func _on_inbox_ui_pressed():
	pickup_inbox_document()

func _connect_document_signals():
	for child in %Container.get_children():
		if child is DocumentBase:
			child.mouse_entered.connect(_update_highlighted_document)
			child.mouse_exited.connect(_update_highlighted_document)

func _find_rules() -> Array[Rule]:
	var rules: Array[Rule] = []
	for rule in %Rules.get_children():
		if rule is Rule:
			rules.append(rule)
		#search one level deeper in case we want reusable rule "packs"
		for inner_rule in rule.get_children():
			if inner_rule is Rule:
				rules.append(inner_rule)
	return rules

func _play_opening_dialogue():
	if dialogue_resource and opening_dialogue:
		DialogueManager.show_dialogue_balloon_scene(dialogue_balloon_scene, dialogue_resource, opening_dialogue)

func _ready():
	_documents = documents.duplicate()
	_documents.shuffle()
	_connect_document_signals()
	_play_opening_dialogue()
	#pass rules to rulebook
	if is_instance_valid(%Rulebook) and %Rulebook is Rulebook:
		var rulebook := %Rulebook as Rulebook
		rulebook.setup_rules(_find_rules())

	level_state = GameState.get_level_state(scene_file_path.get_file().get_basename())

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
			elif _highlighted_document:
				pickup_highlighted_document()
			elif %Inbox2D.is_mouse_over:
				pickup_inbox_document()

func _on_outbox_2d_document_processed(document_data):
	_on_document_archived(document_data)

func _on_furnace_2d_document_processed(document_data):
	_on_document_redacted(document_data)
