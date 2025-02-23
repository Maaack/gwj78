extends GameScene

func _helped_boss_previous_level():
	var prev_level_state : LevelState = GameState.get_level_state("level_2")
	if prev_level_state:
		return prev_level_state.special_flags.has("boss_evidence_messaged")
	return false

func _play_opening_dialogue():
	if _helped_boss_previous_level():
		GameEventsState.helped_boss_level_2 = true
	else:
		GameEventsState.helped_boss_level_2 = false
	super._play_opening_dialogue()
