extends Rule

func should_message(document_data: DocumentData) -> bool:
	return document_data.is_important_to_message
