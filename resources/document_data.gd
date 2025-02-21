class_name DocumentData
extends Resource

@export var is_processable: bool = true
@export var is_messageable: bool = false
@export var is_dangerous : bool = false
@export var special_flags: Array[String] = []
@export var document_scenes: Array[PackedScene] = []
@export_multiline var content: String
