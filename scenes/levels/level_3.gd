extends GameScene

@export var helped_boss_dialogue : StringName

func _helped_boss_previous_level():
	var prev_level_state : LevelState = GameState.get_level_state("level_2")
	if prev_level_state:
		return prev_level_state.special_flags.has("boss_evidence_messaged")
	return false

func _play_opening_dialogue():
	if _helped_boss_previous_level():
		DialogueManager.show_dialogue_balloon_scene(dialogue_balloon_scene, dialogue_resource, helped_boss_dialogue)
	else:
		super._play_opening_dialogue()
