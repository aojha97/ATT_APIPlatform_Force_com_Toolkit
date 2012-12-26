/**
 * @description Provides method for message sending.
 */
public virtual class AttMoboClient {
	
	private final AttCodeAuthorization auth;
	
	/**
	 * @description Creates instance of AttMoboClient is used to send messages on behalf of AT&T subscriber which is specified by AttAuthorization instance.
	 * @param auth Authorization instance is used to obtain access token.
	 */
	public AttMoboClient(AttCodeAuthorization auth) {
		this.auth = auth;
	}
	
	/**
	 * @description Sends message on behalf of AT&T subscriber according authorization instance is used during creation of AttMoboClient.
	 * One transaction to Message On Behalf Of Send service is made. Transaction limits: https://devconnect-api.att.com/docs/att-apis/overview
	 * @param message Message to send.
	 * @return Status information about sent message.
	 */
	public virtual AttMoboSendStatus sendMessage(AttMoboMsg message) {
        HttpClient httpClient = UtilityFactory.getHttpClient();
        HttpRequest request;
        
        if (message.attachments.size() != 0) {
        	MultipartHttpRequest multipartRequest = httpClient.createMultipartRequest(ServiceConstants.ServiceType.MOBO);
	    	AttAttachment jsonPart = new AttAttachment(Blob.valueOf(formatFields(message)),'root-fields',
				'application/json; charset=UTF-8',AttAttachment.ENCODING_8BIT);
			multipartRequest.addAttachment(jsonPart);
			multipartRequest.addAttachmentList(message.attachments);
			
			request = multipartRequest.getRequest();
        } else {
        	request = httpClient.createRequest(ServiceConstants.ServiceType.MOBO);
        	request.setBody(formatFields(message));
        	request.setHeader('Content-Type', 'application/json');
        }

        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + auth.getAccessToken());
        request.setHeader('Accept', 'application/json');
    	
        HttpResponse response = httpClient.sendRequest(request);
    	UtilityFactory.getRestErrorHandler().checkResponseCode(response);
    	return AttMoboSendStatus.parse(response.getBody());
	}
	
	/*
	 * Check presence of message fields and format json request
	 */
	protected virtual String formatFields(AttMoboMsg message) {
		JSONGenerator jsonObj = JSON.createGenerator(true);
        jsonObj.writeStartObject();
        jsonObj.writeObjectField('Addresses',message.dstAddresses);
        if (String.isNotEmpty(message.messageText)) jsonObj.writeStringField('Text',message.messageText);
		if (String.isNotEmpty(message.subject)) jsonObj.writeStringField('Subject',message.subject);
        if (message.isGroup != null && message.isGroup) jsonObj.writeBooleanField('Group',message.isGroup);
        jsonObj.writeEndObject();
        return jsonObj.getAsString();
	}
}