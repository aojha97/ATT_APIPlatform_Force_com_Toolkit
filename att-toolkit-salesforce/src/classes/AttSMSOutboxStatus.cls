/*
 * @description AttSMSInboxStatus holds information about outbox SMS, returned by AT&T server after sending, and provide methods for getting SMS delivery status.
 * Don't create this class directly, use AttMMSOutbox.sendMessage instead.
 */
public virtual class AttSMSOutboxStatus extends BaseOutboxStatus {
	
	/**
     * @description Authorization object.
     */
	public AttClientCredentialsAuthorization auth{ get; set; }
	
	/*
    * @description Constructs AttSMSOutboxStatus object with authorization instance.
    * @param json A JSON string as responce of outbox SMS message.
	* @param auth instance for client authentication.
    */
   	public AttSMSOutboxStatus(String json, AttClientCredentialsAuthorization auth) {
   		super(json);
   		this.auth = auth;
   	}
   	
   	/*
     * @description Invokes AT&T get SMS delivery status REST service and handle result 
     * @return the SMS delivery information returned from the AT&T server.
     */
   	public virtual AttMessageDeliveryStatus getDeliveryStatus() {
        HttpClient client = UtilityFactory.getHttpClient();
        HttpRequest req = client.createRequest(this.resourceUrl);
        req.setMethod('GET'); 
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + auth.getAccessToken());
        
        AttMessageDeliveryStatus smsStatusAnswer;
        
		HttpResponse resp = client.sendRequest(req);
	    UtilityFactory.getRestErrorHandler().checkResponseCode(resp);
	    smsStatusAnswer = new AttMessageDeliveryStatus(resp.getBody());
        
        return smsStatusAnswer;
    }
	
	
	static testMethod void testParse() {
		AttClientCredentialsAuthorization auth = TestHttpMockFactory.getCCAuthMock();
		String json = '{'+
		'"Id": "SMSc04091ed284f5684",'+
		'"ResourceReference": {'+
		'"ResourceURL": "https://api.att.com /rest/sms/2/messaging/outbox/SMSc04091ed284f5684"'+
		'                     }'+
		'}';
		BaseOutboxStatus baseResult = new BaseOutboxStatus('SMSc04091ed284f5684', 'https://api.att.com/rest/sms');
		System.assertEquals(baseResult.Id, 'SMSc04091ed284f5684');
		System.assertEquals(baseResult.ResourceURL, 'https://api.att.com/rest/sms');
		
		AttSMSOutboxStatus result = new AttSMSOutboxStatus(json, auth);
		System.assert(result.Id == 'SMSc04091ed284f5684');
		System.assert(result.ResourceURL == 'https://api.att.com /rest/sms/2/messaging/outbox/SMSc04091ed284f5684');

		json = 'Incorrect response string';
		try {
			result = new AttSMSOutboxStatus(json, auth);
		} catch (Exception e) {}
		
        
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(
        '{ "DeliveryInfoList":'+
        '{"DeliveryInfo":'+
        '[{ "Id" : "msg0",'+
        '"Address" : "3500000992",'+
        '"DeliveryStatus" : "DeliveredToTerminal" }] ,'+
        '"ResourceUrl": "https://api.att.com/rest/sms/2/messaging/outbox/SMSa9b192780378404c"}}'));     
        
        AttMessageDeliveryStatus status = result.getDeliveryStatus();
        System.assertNotEquals(status, null);
        System.assert(status.deliveryInfoList[0].Id == 'msg0');
        System.assert(status.deliveryInfoList[0].Address == '3500000992');
        System.assert(status.deliveryInfoList[0].DeliveryStatus == 'DeliveredToTerminal');
	}
}