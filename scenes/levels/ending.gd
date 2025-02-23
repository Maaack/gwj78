extends GameScene

#func _ready() -> void:
	#_determine_ending()

func _determine_ending() -> void:
	if GameEventsState.resistance_path_level_4 and GameEventsState.resistance_path_level_3:
		_documents.append(load("res://scenes/documents/endings/resistance_ending.tres"))
	elif GameEventsState.helped_boss_level_2 and GameEventsState.helped_boss_level_4:
		_documents.append(load("res://scenes/documents/endings/admnistration_ending.tres"))
	else:
		_documents.append(load("res://scenes/documents/endings/neutral_ending.tres"))


func _play_opening_dialogue():
	%ArchivePipe.get_node("Area2D/CollisionShape2D").disabled = true
	%ArchivePipe.get_node("Area2D").monitoring = false
	%ArchivePipe.hide()
	
	%MessagePipe.get_node("Area2D/CollisionShape2D").disabled = true
	%MessagePipe.get_node("Area2D").monitoring = false
	%MessagePipe.hide()

	_determine_ending()
	super._play_opening_dialogue()
