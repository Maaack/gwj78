class_name GameScene
extends Node

signal level_complete

const INITIAL_PICKUP_OFFSET_FRACTION: float = 0.5
const PICKUP_ROTATION : float = -5

const MONEY_CORRECT_PROCESS: int = 10
const MONEY_INCORRECT_ARCHIVAL: int = -5
const MONEY_INCORRECT_REDACTION: int = -15
const MONEY_INCORRECT_MESSAGED: int = -5

@export var document_scene : PackedScene
@export var resistance_document_scene : PackedScene
@export var documents : Array[DocumentData]
@export var dialogue_balloon_scene : PackedScene
@export var dialogue_resource : DialogueResource
@export var opening_dialogue : StringName
@export var dialogue_misarchival: DialogueResource
@export var dialogue_misredaction: DialogueResource

var _highlighted_document : DocumentBase
var _active_document : DocumentBase
var _documents : Array[DocumentData]
var _archived_documents : Array[DocumentData]
var _redacted_documents : Array[DocumentData]
var _messaged_documents : Array[DocumentData]
var _processed_documents : Array[DocumentData]

var level_state : LevelState
var _pickup_offset : Vector2
var _last_mouse_position : Vector2
var _in_dialogues: int = 0

var has_moved_picked_doc := false

func _ready():
	_documents = documents.duplicate()
	_connect_document_signals()
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	_play_opening_dialogue()
	#pass rules to rulebook
	if is_instance_valid(%Rulebook) and %Rulebook is Rulebook:
		var rulebook := %Rulebook as Rulebook
		rulebook.setup_rules(_find_rules())
	#reset state in case of level restart
	GameState.clear_level_state(scene_file_path.get_file().get_basename())
	level_state = GameState.get_level_state(scene_file_path.get_file().get_basename())
	var previous_level_states = GameState.get_level_states_before(scene_file_path.get_file().get_basename())
	for previous_state in previous_level_states:
		level_state.money_total += previous_state.money_total
	#pass level state to rules
	for rule in _find_rules():
		rule.level_state = level_state
	_update_money_label()
	
func _update_score_label():
	if is_inside_tree():
		%ScoreLabel.text = "%d" % level_state.points_total
		
func _update_money_label():
	if is_inside_tree():
		%MoneyLabel.text = "%d$" % level_state.money_total

func pickup_inbox_document():
	if is_instance_valid(_active_document):
		return
	if _documents.is_empty():
		return
	var next_document : DocumentData = _documents.pop_front() as DocumentData
	var picked_document_scene = document_scene
	if len(next_document.document_scenes) > 0:
		picked_document_scene = next_document.document_scenes.pick_random()
	elif next_document.is_resistance:
		picked_document_scene = resistance_document_scene
	var document_instance : DocumentBase = picked_document_scene.instantiate() as DocumentBase
	_pickup_offset = Vector2(0, (document_instance.get_bounds().size.y * 0.5) * INITIAL_PICKUP_OFFSET_FRACTION)
	document_instance.rotation_degrees = PICKUP_ROTATION
	document_instance.position = _last_mouse_position + _pickup_offset
	document_instance.document_data = next_document
	document_instance.mouse_entered.connect(_update_highlighted_document)
	document_instance.mouse_exited.connect(_update_highlighted_document)
	%ActiveContainer.add_child(document_instance)
	document_instance.play_pickup_sound(true)
	_active_document = document_instance
	%Inbox2D.has_documents = not _documents.is_empty()

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
	_active_document.play_pickup_sound(false)
	_update_active_document_position()

func _update_active_document_position():
	if not is_instance_valid(_active_document):
		return
	#Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	_active_document.position = _last_mouse_position + _pickup_offset
	var document_data := _active_document.document_data
	var outbox := get_mouse_over_outbox()
	if _active_document is DocumentBase and document_data and outbox is Outbox2D and outbox.active:
		if (outbox == %MessagePipe and document_data.is_messageable) or (outbox != %MessagePipe and document_data.is_processable):
			if outbox == %Furnace:
				_active_document.modulate_state("furnace")
			elif outbox == %ArchivePipe:
				_active_document.modulate_state("archive")
			elif outbox == %MessagePipe:
				_active_document.modulate_state("message")
			if is_instance_valid(CursorFollower.instance):
				CursorFollower.instance.set_text(outbox.hover_label)
			return
	#else:
	if is_instance_valid(CursorFollower.instance):
		CursorFollower.instance.clear_text()
	_active_document.modulate_state("normal")
	has_moved_picked_doc = true


func is_level_complete():
	#to account for messageable but not processable documents
	var processable_documents = 0
	for document in documents:
		if document.is_processable:
			processable_documents += 1
	var processed_documents = 0
	for document in _processed_documents:
		if document.is_processable:
			processed_documents += 1
	return processed_documents >= processable_documents

func _finish_level_if_complete():
	if is_level_complete():
		while _in_dialogues > 0:
			await DialogueManager.dialogue_ended
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
	var document_data := _active_document.document_data
	var outbox := get_mouse_over_outbox()
	if _active_document is DocumentBase and document_data and outbox is Outbox2D and outbox.active:
		if (outbox == %MessagePipe and document_data.is_messageable) or (outbox != %MessagePipe and document_data.is_processable):
			outbox.process_document(_active_document)
			_active_document = null
			return
	_active_document.rotation_degrees = 0
	_active_document.reparent(%Container)
	_highlighted_document = _active_document
	_active_document = null
	has_moved_picked_doc = false

func document_processed(document_data : DocumentData):
	_processed_documents.append(document_data)
	if document_data.is_processable:
		if document_data.is_dangerous:
			level_state.documents_intended_redacted += 1
		else:
			level_state.documents_intended_archived += 1
	_update_score_label()
	_update_money_label()
	_finish_level_if_complete()

func _should_document_be_redacted(document_data : DocumentData) -> bool:
	for rule in _find_rules():
		if rule.should_redact(document_data):
			return true
	return false
	
func _is_messaging_document_legal(document_data : DocumentData) -> bool:
	for rule in _find_rules():
		if rule.is_messaging_legal(document_data):
			return true
	return false

func _on_document_archived(document_data : DocumentData):
	_archived_documents.append(document_data)
	for rule in _find_rules():
		rule.on_archived(document_data)
	if not _should_document_be_redacted(document_data):
		level_state.points_total += 1
		level_state.money_total += MONEY_CORRECT_PROCESS
		level_state.documents_archived_correctly += 1
	else:
		level_state.points_total -= 1
		level_state.money_total += MONEY_INCORRECT_REDACTION
		level_state.documents_archived_incorrectly += 1
		DialogueManager.show_dialogue_balloon_scene(dialogue_balloon_scene, dialogue_misarchival)
	#dialogue manager call_deffered's the dialogue start, so to wait for it...
	document_processed.call_deferred(document_data)

func _on_document_redacted(document_data : DocumentData):
	_redacted_documents.append(document_data)
	for rule in _find_rules():
		rule.on_redacted(document_data)
	if _should_document_be_redacted(document_data):
		level_state.points_total += 1
		level_state.money_total += MONEY_CORRECT_PROCESS
		level_state.documents_redacted_correctly += 1
	else:
		level_state.points_total -= 1
		level_state.money_total += MONEY_INCORRECT_REDACTION
		level_state.documents_redacted_incorrectly += 1
		DialogueManager.show_dialogue_balloon_scene(dialogue_balloon_scene, dialogue_misredaction)
	#dialogue manager call_deffered's the dialogue start, so to wait for it...
	document_processed.call_deferred(document_data)

func _on_document_messaged(document_data : DocumentData):
	_messaged_documents.append(document_data)
	level_state.documents_messaged += 1
	if not _is_messaging_document_legal(document_data):
		level_state.money_total += MONEY_INCORRECT_MESSAGED
	for rule in _find_rules():
		rule.on_messaged(document_data)
	#dialogue manager call_deffered's the dialogue start, so to wait for it...
	document_processed.call_deferred(document_data)

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
		has_moved_picked_doc = true
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if _active_document:
				if _active_document.has_second_page():
					if Input.is_action_just_released("click") and not has_moved_picked_doc:
						_active_document.turn_page()
					drop_document()
				else:
					drop_document()
			elif _highlighted_document:
				pickup_highlighted_document()
				has_moved_picked_doc = false
			elif %Inbox2D.is_mouse_over:
				pickup_inbox_document()
				has_moved_picked_doc = false

func _on_outbox_2d_document_processed(document_data: DocumentData) -> void:
	_on_document_archived(document_data)

func _on_furnace_2d_document_processed(document_data: DocumentData) -> void:
	_on_document_redacted(document_data)

func _on_message_pipe_document_processed(document_data: DocumentData) -> void:
	_on_document_messaged(document_data)

func _on_cheat_skip_level_pressed() -> void:
	level_complete.emit()

func _on_dialogue_started(resource: DialogueResource) -> void:
	_in_dialogues += 1
	
func _on_dialogue_ended(resource: DialogueResource) -> void:
	_in_dialogues -= 1
