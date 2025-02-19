extends GameScene

var boss_points : int = 0 :
	set(value):
		boss_points = value
		_update_score_label()
var _messaged_documents : Array[DocumentData]

func _update_score_label():
	if is_inside_tree():
		%ScoreLabel.text = "%d (%d boss)" % [points_scored, boss_points]
	
func _should_document_be_messaged(document_data : DocumentData) -> bool:
	for rule in _find_rules():
		if rule.should_message(document_data):
			return true
	return false

func _on_document_messaged(document_data : DocumentData):
	_messaged_documents.append(document_data)
	var should_message := _should_document_be_messaged(document_data)
	boss_points += 1 if should_message else -1
	document_processed(document_data)

func _on_message_pipe_2d_document_processed(document_data):
	_on_document_messaged(document_data)
