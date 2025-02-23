extends GameScene


func _archived_resistance():
	var prev_level_state : LevelState = GameState.get_level_state("level_3")
	if prev_level_state:
		return prev_level_state.special_flags.has("resistance_helped")
	return false


func _play_opening_dialogue():
	if _archived_resistance():
		GameEventsState.resistance_path_level_3 = true
		_documents.push_front(load("res://scenes/documents/day4/resistance_instructions.tres"))
	else:
		GameEventsState.resistance_path_level_3 = false
		
	super._play_opening_dialogue()
