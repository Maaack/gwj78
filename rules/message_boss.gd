extends Rule

func should_message(document_data: DocumentData) -> bool:
	return document_data.is_important_to_message
	
func is_messaging_legal(document_data: DocumentData) -> bool:
	return true
	
func on_messaged(document_data: DocumentData) -> void:
	if document_data.special_flags.has("boss_evidence"):
		level_state.special_flags.append("boss_evidence_messaged")
		level_state.special_flag_summaries["boss_evidence_messaged"] = "Evidence of wrongdoing messaged."
