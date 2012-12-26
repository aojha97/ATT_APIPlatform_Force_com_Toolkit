/**
 * @description Base class for Messages Inbox Management service, provides methods to invoke and retrieve results AT&T MIM service.
 */
public virtual class AttMIM {
	
	/**
	 * @description Authorization object.
	 */
	public AttCodeAuthorization auth { get; set; }	
	
	/**
	 * @description Constructs MIM service with authorization object.
	 * @param auth authorization object.
	 */
	public AttMIM(AttCodeAuthorization auth) {
		this.auth = auth;
	}	
	
 	/**
 	 * @description Resurns messages headers.
 	 * One transaction to Message Management service is made. Transaction limits: https://devconnect-api.att.com/docs/att-apis/overview.
 	 * @param headerCount specifies the number of headers being returned.
 	 * @param indexCursor specifies the index value for which the HeaderCount parameter begins the count.
 	 * @return messages headers.
 	 */
	public virtual AttMIMMessageHeaders getHeaders(Integer headerCount, String indexCursor) {		
        HttpRequest request = UtilityFactory.getHttpClient().createRequest(ServiceConstants.ServiceType.MIM, '?HeaderCount=' + headerCount + (!String.isBlank(indexCursor) ? '&IndexCursor=' + indexCursor : ''));
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + auth.getAccessToken());
        request.setHeader('Accept', 'application/json');
        HTTPResponse response = UtilityFactory.getHttpClient().sendRequest(request);
        UtilityFactory.getRestErrorHandler().checkResponseCode(response);        
        return AttMIMMessageHeaders.parse(response.getBody());
	}
	
	/**
	 * @description Returns message content.
	 * One transaction to Message Management service is made. Transaction limits: https://devconnect-api.att.com/docs/att-apis/overview.
	 * @param messageId specifies the message identifier.
	 * @param partNumber specifies the content identifier.
	 * @return message content.
	 */
	public virtual AttAttachment getContent(String messageId, Integer partNumber) {		
		HttpRequest request = UtilityFactory.getHttpClient().createRequest(ServiceConstants.ServiceType.MIM, '/' + messageId + '/' + partNumber);                
        request.setMethod('GET'); 
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + auth.getAccessToken());
        
        HTTPResponse response = UtilityFactory.getHttpClient().sendRequest(request);
	    List<String> contentType = response.getHeader('Content-Type').split(';', 2);
	    String fileName = '';
	    if (contentType.size() > 1) {
	    	 List<String> nameData = contentType.get(1).split('=');
	    	 if (nameData.size() > 1) {
	    	 	fileName = nameData.get(1).trim();
	    	 }
	    }
	    UtilityFactory.getRestErrorHandler().checkResponseCode(response);	    
	    return new AttAttachment(response.getBodyAsBlob(), fileName, contentType.get(0));
	}
}