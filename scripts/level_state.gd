class_name LevelState
extends Resource

@export var points_total : int
@export var money_total: int

@export var documents_archived_correctly : int
@export var documents_archived_incorrectly : int
@export var documents_redacted_correctly : int
@export var documents_redacted_incorrectly : int
@export var documents_messaged : int

@export var documents_intended_archived : int
@export var documents_intended_redacted : int

@export var special_flags: Array[String] = []
@export var special_flag_summaries: Dictionary[String, String] = {}
