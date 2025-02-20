extends GameScene

@export var helped_boss_dialogue : StringName

var boss_points : int = 0 :
	set(value):
		boss_points = value
		_update_score_label()
		_update_level_data()
var _messaged_documents : Array[DocumentData]

func _update_score_label():
	if is_inside_tree():
		%ScoreLabel.text = "%d (%d boss)" % [points_scored, boss_points]

func _update_level_data():
	super._update_level_data()
	level_state.boss_points = boss_points

func _should_document_be_messaged(document_data : DocumentData) -> bool:
	for rule in _find_rules():
		if rule.should_message(document_data):
			return true
	return false

func _helped_boss_previous_level():
	var prev_level_state : LevelState = GameState.get_level_state("level_2")
	if prev_level_state:
		return prev_level_state.boss_points > 0
	return false

func _play_opening_dialogue():
	if _helped_boss_previous_level():
		DialogueManager.show_dialogue_balloon_scene(dialogue_balloon_scene, dialogue_resource, helped_boss_dialogue)
	else:
		super._play_opening_dialogue()

func _on_document_messaged(document_data : DocumentData):
	_messaged_documents.append(document_data)
	var should_message := _should_document_be_messaged(document_data)
	boss_points += 1 if should_message else -1
	document_processed(document_data)

func _on_message_pipe_2d_document_processed(document_data):
	_on_document_messaged(document_data)
