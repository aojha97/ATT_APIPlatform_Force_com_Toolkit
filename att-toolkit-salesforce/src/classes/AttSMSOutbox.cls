/*
 * @description AttSMSOutbox provides methods to invoke and retrieve results from AT&T SMS send REST service
 */
public virtual class AttSMSOutbox {
	
	/**
     * @description Authorization object.
     */
	public AttClientCredentialsAuthorization auth { get; set; }
	
	/**
	 * @description Constructs SMS Outbox service with authorization instance.
	 * @param auth instance for client authentication.
	 */		
	public AttSMSOutbox(AttClientCredentialsAuthorization auth) {
		this.auth = auth;
	}
	
	/*
	 * @description Invokes AT&T send SMS REST service and handle result 
	 * @param message An SMS message to send
     * @return the SMS status returned from the AT&T server.
	 */
    public virtual AttSMSOutboxStatus sendMessage(AttSMS message){
        String phoneNumber = message.phoneNumber;
        String messageText = message.messageText;
        if (phoneNumber == null || phoneNumber == '') {
            throw new AttException('Phone number must be specified.'); 
        }
        
        if (messageText == null || messageText == '') {
            throw new AttException('Message text must be specified.'); 
        }   
        
        HttpClient client = UtilityFactory.getHttpClient();
        
        HttpRequest req = client.createRequest(ServiceConstants.ServiceType.SEND_SMS);
        req.setMethod('POST'); 
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + auth.getAccessToken());
        req.setHeader('Content-Type', 'application/json');
        
        JSONGenerator jsonObj = JSON.createGenerator(true);
        jsonObj.writeStartObject();
        jsonObj.writeStringField('Message', messageText);
        jsonObj.writeStringField('Address', 'tel:' + phoneNumber);
        jsonObj.writeEndObject();
        req.setBody(jsonObj.getAsString());
        
		HttpResponse resp = client.sendRequest(req);	            
	    // check response code
	    UtilityFactory.getRestErrorHandler().checkResponseCode(resp);	        
        return new AttSMSOutboxStatus(resp.getBody(), auth);
    }
    
    public static testmethod void testService() {		
		AttClientCredentialsAuthorization auth = TestHttpMockFactory.getCCAuthMock();		
    	
    	AttSMSOutbox smsOutbox = new AttSMSOutbox(auth);
        AttSMS sms = new AttSMS();
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(
        '{"Id": "SMSc04091ed284f5684","ResourceReference": {"ResourceURL": "https://api.att.com /rest/sms/2/messaging/outbox/SMSc04091ed284f5684"}}'
        ));
        // check message text and phone number presence
        try {
            smsOutbox.sendMessage(sms);
            System.assert(false);
        } catch(AttException ex){
            System.assertEquals(ex.getMessage(), 'Phone number must be specified.');
        }
        
        sms.phoneNumber = '4258028620';
        try {
            smsOutbox.sendMessage(sms);
            System.assert(false);
        } catch(AttException ex){
            System.assertEquals(ex.getMessage(), 'Message text must be specified.');
        }
        sms.messageText = 'test text';
        
        AttSMSOutboxStatus status = smsOutbox.sendMessage(sms);
        System.assertNotEquals(status, null);
        System.assertEquals(status.Id, 'SMSc04091ed284f5684');
        System.assertEquals(status.resourceUrl, 'https://api.att.com /rest/sms/2/messaging/outbox/SMSc04091ed284f5684');
    }
}