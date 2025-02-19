@tool
class_name Rulebook extends DocumentBase

@export var rule_entry_scene: PackedScene

func _ready() -> void:
	super._ready()
	
func setup_rules(rules: Array[Rule]) -> void:
	if is_inside_tree():
		#clear out any old rules
		for child in %RuleStack.get_children():
			%RuleStack.remove_child(child)
			
		for rule in rules:
			if rule.instruction.is_empty():
				continue #do not list hidden (instructionless) rules
			var rule_entry := rule_entry_scene.instantiate() as RuleEntry
			rule_entry.rule = rule
			%RuleStack.add_child(rule_entry)
