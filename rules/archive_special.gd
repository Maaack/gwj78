extends Rule

signal evidence_collected

var collected: bool = false

func should_redact(document_data: DocumentData) -> bool:
	return false
	
func on_archived(document_data: DocumentData) -> void:
	if document_data.special_flags.has("resistance_help"):
		level_state.special_flags.append("resistance_helped")
		level_state.special_flag_summaries["resistance_helped"] = "Evidence of wrongdoing messaged."
