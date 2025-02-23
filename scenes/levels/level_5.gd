extends GameScene

func _archived_resistance():
	var prev_level_state : LevelState = GameState.get_level_state("level_4")
	if prev_level_state:
		return prev_level_state.special_flags.has("resistance_path_archived")
	return false


func _play_opening_dialogue():
	if _archived_resistance():
		GameEventsState.resistance_path_level_4 = true
	else:
		GameEventsState.resistance_path_level_4 = false
	super._play_opening_dialogue()
