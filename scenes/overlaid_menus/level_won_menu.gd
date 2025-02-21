extends LevelWonMenu

var level: GameScene

func _ready():
	var level_state := level.level_state
	var day := GameState.get_current_level()
	var archived_max = 0 #TODO
	var redacted_max = 0 
	%Header.text = "Day "+str(day)+" complete!"
	%ScoreArchive.text = str(level_state.documents_archived) + " / " +str(level_state.documents_intended_archived)
	%ScoreRedactions.text = str(level_state.documents_redacted) + " / " +str(level_state.documents_intended_redacted)
