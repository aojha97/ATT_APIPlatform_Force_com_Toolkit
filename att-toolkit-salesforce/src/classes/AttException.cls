/**
 * @description Base class for AT&T API exceptions.
 */
public virtual class AttException extends Exception {
	
	/**
	 * @description Status code.
	 */
	public Integer statusCode { get; set; }
	
	/**
	 * @description Message identifier.
	 */	
	public String messageId { get; set; }
	
	/**
	 * @description Message text. 
	 */	
	public String messageText { get; set; }
	
	/**
	 * @description Message text variables. 
	 */	
	public String variables { get; set; }

	/**
	 * @description Constructs AttException from status code, message id and message text.
	 * @param statusCode exception status code.
	 * @param messageId exception message id.
	 * @param messageText exception text.
	 */
	public AttException(Integer statusCode, String messageId, String messageText) {
		this(statusCode, messageId, messageText, null);
	}
	
	/**
	 * @description Constructs AttException from status code, message id, message text and variables.
	 * @param statusCode exception status code.
	 * @param messageId exception message id.
	 * @param messageText exception text.
	 * @param variables exception text variables.
	 */	
	public AttException(Integer statusCode, String messageId, String messageText, String variables) {
		this.statusCode = statusCode;
		this.messageId = messageId;
		this.messageText = messageText;
		this.variables = variables;
		
		String message = messageId;
		if (String.isNotBlank(messageText)) {
			if (variables != null && variables.length() != 0) {
				if (messageText.contains('%1')) {
					messageText = messageText.replace('%1', '<' + variables + '>');
				} else {
					messageText += '. ' + variables;
				}
			}
			message += (message.trim().endsWith(':') ? ' ' : ': ') + messageText;
		}
		setMessage(message);
	}
}