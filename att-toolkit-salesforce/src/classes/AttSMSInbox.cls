/*
 * @description AttSMSInbox provides methods to invoke and retrieve results from AT&T get SMS inbox REST service for the given shortcode
 */
public virtual class AttSMSInbox {
	
	/**
     * @description Authorization object.
     */
	public AttClientCredentialsAuthorization auth { get; set; }
	
	/**
     * @description Short code that is obtained when you register your app with AT&T. Read only.
     */
    public String shortCode { get; private set; }
    
    /*
    * @description Constructs SMS Inbox service with authorization instance.
    * @param shortCode The shortcode of the inbox
	* @param auth instance for client authentication.
    */
    public AttSMSInbox(String shortCode, AttClientCredentialsAuthorization auth) {
    	this.shortCode = shortCode;
    	this.auth = auth;
    }
	
	/*
	 * @description Invokes AT&T get SMS inbox messages REST service and handle result 
     * @return the inbox messages returned from the AT&T server.
	 */
	public virtual AttSMSInboxStatus checkMessages() {
		
		if (shortCode == null || shortCode == '') {
			throw new AttException('Short code is absent or broken.');
		}
		
		HttpClient client = UtilityFactory.getHttpClient();
		HttpRequest req = client.createRequest(ServiceConstants.ServiceType.GET_SMS_INBOX, '?RegistrationID=' + shortCode);
        Http http = new Http();
        req.setMethod('GET'); 
        String regId = 'RegistrationID=' + shortCode;
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + auth.getAccessToken());
        
        HttpResponse resp = client.sendRequest(req);
        
        UtilityFactory.getRestErrorHandler().checkResponseCode(resp);     
        return AttSMSInboxStatus.parse(resp.getBody());
	}
	
	public static testmethod void testService() {
		AttClientCredentialsAuthorization auth = TestHttpMockFactory.getCCAuthMock();
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(
        '{"InboundSmsMessageList": '+
        '{"InboundSmsMessage": '+
        '[{ "MessageId" : "msg0", "Message" : "Hello", "SenderAddress" : "tel:4257850159" '+
        '}], '+
        '"NumberOfMessagesInThisBatch" : "1", '+
        '"ResourceUrl" : "http://api.att.com:8080/rest/sms/2/messaging/inbox", "TotalNumberOfPendingMessages" : "0" '+
        '}}'));		
		
		AttSMSInbox smsInbox = new AttSMSInbox('', auth);       	
       	// check short code presence
       	try{
        	smsInbox.checkMessages();
        	System.assert(false);
        } catch(AttException ex) {
        	System.assertEquals(ex.getMessage(), 'Short code is absent or broken.');
        }
        
        smsInbox = new AttSMSInbox('testId', auth);
       	
        AttSMSInboxStatus result = smsInbox.checkMessages();
        System.assert(true);
        System.assert(result.InboundSmsMessageList.InboundSmsMessage.size() == 1);
        System.assert(result.InboundSmsMessageList.NumberOfMessagesInThisBatch == 1);
        System.assert(result.InboundSmsMessageList.ResourceUrl == 'http://api.att.com:8080/rest/sms/2/messaging/inbox');
        System.assert(result.InboundSmsMessageList.TotalNumberOfPendingMessages == 0);
        
        AttSMSInboxStatus.InboundSmsMessage message = result.InboundSmsMessageList.InboundSmsMessage.get(0);
        System.assert(message.MessageId == 'msg0');
        System.assert(message.Message == 'Hello');
        System.assert(message.SenderAddress == 'tel:4257850159');
	}
	
}