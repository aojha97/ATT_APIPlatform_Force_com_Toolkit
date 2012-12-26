/**
 * @description Base class for WAP Push service, provides methods to send messages and retrieve results from AT&T WAP Push service.
 */
public virtual class AttWAPPush {
	
	/**
	 * @description Authorization object.
	 */
	public AttClientCredentialsAuthorization auth { get; set; }
	
	/**
	 * @description Recipient numbers list.
	 */
	public Set<String> phoneNumbers { get; set; }
	
	/**
	 * @description WAP Push message URL.
	 */
	public String url { get; set; }
	
	/**
	 * @description WAP Push message body.
	 */
	public String message { get; set; }
	
	/**
 	 * Request body part boundary.
	 */
	protected final String boundary = 'foo';
	
	/**
	 * @description Constructs WAP Push service with authorization object.
	 */
	public AttWAPPush(AttClientCredentialsAuthorization auth) {
		this.auth = auth;
	}
	
	/**
 	 * @description Sends WAP Push message and return result.
 	 * One transaction to Send Wap PUSH service is made. Transaction limits: https://devconnect-api.att.com/docs/att-apis/overview.
 	 * @return send WAP Push message result.
 	 */
	public virtual AttWAPPushResult sendWAPPush() {
		Httprequest request = createRequest(phoneNumbers, url, message);
       	HttpResponse response = UtilityFactory.getUtils().execute(request);
		AttWAPPushResult result = (AttWAPPushResult) System.JSON.deserialize(response.getBody(), AttWAPPushResult.class);        
        return result;
	}
	
	/**
	 * Creates HTTP request for AT&T WAP Push service 
	 */
	protected virtual Httprequest createRequest(Set<String> phoneNumbers, String url, String message) {
		HttpRequest request = UtilityFactory.getHttpClient().createRequest(ServiceConstants.ServiceType.WAP_PUSH);        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'multipart/form-data; type=\"application/x-www-form-urlencoded\"; boundary=\"' + boundary +'\"');
        request.setHeader('Authorization', 'Bearer ' + auth.getAccessToken());
        request.setHeader('Accept', 'application/json');       
        
        String addressBodyPart = getAddressRequestBodyPart(phoneNumbers);
        String messageBodyPart = getMessageRequestBodyPart(url, message);
        String endBodyParts = '\n--' + boundary + '--\n';
        request.setBody(addressBodyPart + messageBodyPart + endBodyParts);
        return request;
	}
	
	/**
	 * Returns address request body part
	 */
	protected virtual String getAddressRequestBodyPart(Set<String> phoneNumbers) {
		// body part headers 
		String addressBodyPart = '\n--' + boundary  + '\n' +  
        'Content-Transfer-Encoding: 8bit\n' +        
        'Content-Disposition: form-data; name=\"root-fields\"\n' +
        'Content-ID: <startpart>\n' +
        'Content-Type: application/json\n\n';
        							        
        // body part content
        JSONGenerator jsonObj = JSON.createGenerator(true);
        jsonObj.writeStartObject();
        if (phoneNumbers.size() == 1) {
        	for (String num : phoneNumbers)	{
        		jsonObj.writeStringField('address', num);
        	}
        } else {
        	jsonObj.writeObjectField('address', phoneNumbers);
        }
        jsonObj.writeEndObject();                
        addressBodyPart += jsonObj.getAsString() + '\n';
        return addressBodyPart;
	}
	
	/**
	 * Returns message request body part
	 */
	protected virtual String getMessageRequestBodyPart(String url, String message) {
		// body part headers
		String messageBodyPart = '\n--' + boundary  + '\n' +        
        'Content-Transfer-Encoding: binary\n' +
        'Content-Disposition: attachment; name=\"\"; filename=\"\"\n' + 
        'Content-ID: <attachment>\n' + 
        'Content-Type: text/plain\n';
        							
        // body part content        							    
		messageBodyPart += '\nContent-Disposition: form-data; name=\"PushContent\"\n' + 
		'Content-Type: text/vnd.wap.si\n' +		
		'X-Wap-Application-Id: x-wap-application:wml.ua\n\n' + 
		'<?xml version=\"1.0\"?>\n' + 
		'<!DOCTYPE si PUBLIC \"-//WAPFORUM//DTD SI 1.0//EN\" \"http://www.wapforum.org/DTD/si.dtd\">\n' + 
		'<si>\n' +
			'<indication href=\"' + url + '\" action=\"signal-medium\" si-id=\"6532\" >\n' + 
				message + '\n' + 
			'</indication>\n' + 
		'</si>';
        return messageBodyPart;
	}
}