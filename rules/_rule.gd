class_name Rule extends Node

#rules with no instruction will not be listed in the rulebook
@export var instruction: String

var level_state: LevelState

func should_redact(document_data: DocumentData) -> bool:
	return false

func should_message(document_data: DocumentData) -> bool:
	return false

func on_redacted(document_data: DocumentData) -> void:
	pass
	
func on_archived(document_data: DocumentData) -> void:
	pass
	
func on_messaged(document_data: DocumentData) -> void:
	pass
