extends Rule

signal evidence_collected

var collected: bool = false

func should_redact(document_data: DocumentData) -> bool:
	return false
	
#func on_archived(document_data: DocumentData) -> void:
	#if not collected and document_data.is_special:
		#collected = true
		#evidence_collected.emit()
