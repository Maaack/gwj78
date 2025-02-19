@tool
class_name RuleEntry extends Control

@export var rule : Rule :
	set(value):
		rule = value
		if is_inside_tree() and rule:
			%RuleBody.text = rule.instruction

func _ready():
	rule = rule
