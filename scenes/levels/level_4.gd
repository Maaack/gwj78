extends GameScene

@export var helped_boss_dialogue : StringName


func _archived_resistance():
	var prev_level_state : LevelState = GameState.get_level_state("level_3")
	if prev_level_state:
		return prev_level_state.special_flags.has("resistance_archived")
	return false


func _play_opening_dialogue():
	if _archived_resistance():
		_documents.append(load("res://scenes/documents/day4/resistance_instructions.tres"))
