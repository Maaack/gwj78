extends Rule

func should_redact(document_data: DocumentData) -> bool:
	return document_data.is_dangerous
