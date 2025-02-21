extends LevelWonMenu

@export var summary_entry_scene: PackedScene

var level: GameScene

func _ready():
	var level_state := level.level_state
	var day := GameState.get_current_level()
	%Header.text = "Day "+str(day + 1)+" complete!"
	%ScoreArchive.text = str(level_state.documents_archived) + " / " +str(level_state.documents_intended_archived)
	%ScoreRedactions.text = str(level_state.documents_redacted) + " / " +str(level_state.documents_intended_redacted)
	for extra_line in level_state.special_flag_summaries.values():
		var entry := summary_entry_scene.instantiate() as LevelSummaryEntry
		entry.set_text(extra_line)
		%Scores.add_child(entry)
