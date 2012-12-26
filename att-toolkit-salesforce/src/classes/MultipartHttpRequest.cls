/**
 * @description Represents MIME multipart HTTP request
 */
public virtual class MultipartHttpRequest {	
	protected final HttpRequest request;
	protected final String boundary;
	protected Integer partID = 1;
	protected String requestBody = '';
	
	/**
	 * @description Creates instance of MultipartHttpRequest with specified endpoint and timeout.
	 * @param endpoint destination URL address of request.
	 * @param timeout request timeout in miliseconds.
	 */
	public MultipartHttpRequest(String endpoint,Integer timeout) {
		request = new HttpRequest();
		request.setEndpoint(endpoint);
		request.setTimeout(timeout);
		
		boundary = 'MIMEBoundary_' + Math.round((Math.random() * 10000000));
		request.setHeader('MIME-Version', '1.0');
		request.setHeader('Content-Type', 'multipart/related; type="application/json"; start="' +
			String.valueOf(partID) + '"; boundary="' + boundary + '"');
	}
	
	/**
	 * @description Add new attachment to this multipart request.
	 * @param attachment AttAttachment instance to add to request.
	 */
	public virtual void addAttachment(AttAttachment attachment) {
		requestBody += '--' + boundary + '\n' + attachment.toHttpRequestPart(String.valueOf(partID));
		partID++;
	}
	
	/**
	 * @description Add List of attachments to this multipart request.
	 * @param attachments List of AttAttachment instances to add to request.
	 */
	public virtual void addAttachmentList(List<AttAttachment> attachments) {
		for (AttAttachment attachment : attachments) {
			addAttachment(attachment);
		}
	}
	
	/**
	 * @description Creates instance of HttpRequest for later processing.
	 * @return Instance of HttpRequest is filled according to MIME specification.
	 */
	public virtual HttpRequest getRequest() {
		requestBody += '--' + boundary + '--\n';
		request.setHeader('Content-Length', String.valueOf(requestBody.length()));
		request.setBody(requestBody);
		return request;
	}
}