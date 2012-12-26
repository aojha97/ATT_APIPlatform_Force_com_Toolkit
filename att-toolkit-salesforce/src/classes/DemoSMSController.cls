public class DemoSMSController {
        
    public String sendSmsDebugBody {get; set;}
    
    public String phoneNumber { get; set; } 
    
    public String messageText { get; set; }   
    
    public String smsId { get; set; }  
    
    public String inboxDebugBody { get; set; } 
    
    public AttSMSOutboxStatus smsResp { get; set; }
    
    public AttSMSOutboxStatus answerSMSSend { get; set; }
    
    public String deliveryDebugBody { get; set; }
    
    public String numberOfMessages { get; set; }
    
    public String numberOfPendingMessages { get; set; }
    
    public List <AttSMSInboxStatus.InboundSmsMessage> inboundMessageList { get; set; }
    
    public List<AttMessageDeliveryStatus.DeliveryInfo> deliveryInfoList { get; set; }
    
    public boolean isStatusTableVisible { get; set; }  
    
    public boolean isInboxTableVisible { get; set; }
    
    public boolean isSendErrorsVisible { get; set; }
    
    public boolean isGetStatusErrorsVisible { get; set; }
    
    public boolean isInboxErrorsVisible { get; set; }
    
    // Test mode
    public boolean testExceptionMode { get; set; } 
    
    public AttClientCredentialsAuthorization auth { get; set; }
    
    public AttSMSInboxStatus inboxMessagesAnswer { get; set; }
    
    public DemoSMSController () {
        init();
    }
    
    private void init() {
        phoneNumber = '4258028620';
        isStatusTableVisible = false;
        isInboxTableVisible = false;
        auth = new AttClientCredentialsAuthorization(ServiceConstants.ScopeType.SMS);
    }
    
    public String getShortCode() {
        return UtilityFactory.getSecurityTokenProvider().getShortcodeByName('Default');
    }
    
    public void testAttServiceSMSSend() {
    	answerSMSSend = null;
    	sendSmsDebugBody = '';
    	
        AttSMSOutbox smsOutbox = new AttSMSOutbox(auth);
        AttSMS sms  = new AttSMS();
        sms.phoneNumber = phoneNumber;
        sms.messageText = messageText;
        
        try {
        	answerSMSSend = smsOutbox.sendMessage(sms);
        } catch (AttException ex) {
            isSendErrorsVisible = true;
            isGetStatusErrorsVisible = false;
            isInboxErrorsVisible = false;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);            
            return;
        }        
              
        smsId = answerSMSSend.Id;
        isStatusTableVisible = false;
        deliveryDebugBody = '';
        sendSmsDebugBody = 'phoneNumber=' + phoneNumber + 
                '\r\nmessageText=' + messageText + '\r\n\r\n' + answerSMSSend;
        
    }
    
    public void testAttServiceSMSCheckStatus () {
    	deliveryInfoList = null;
        deliveryDebugBody = '';
    	
        AttMessageDeliveryStatus answerSMSStatus;
        try {
        	answerSMSStatus = answerSMSSend.getDeliveryStatus();
        } catch (AttException ex) {
            isSendErrorsVisible = false;
            isGetStatusErrorsVisible = true;
            isInboxErrorsVisible = false;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
            return; 
        }
        deliveryInfoList = answerSMSStatus.deliveryInfoList;
        deliveryDebugBody = 'smsId='+ smsId + '\r\n\r\n' + answerSMSStatus.toString();   
        isStatusTableVisible = true;
    }
    
    public void testAttServiceSMSInbox () {
    	inboundMessageList = null;
        inboxDebugBody = '';
        numberOfMessages = '';
        numberOfPendingMessages = ''; 
    	
    	String shortCode = UtilityFactory.getSecurityTokenProvider().getShortcodeByName('Default');
        
    	AttSMSInbox smsInbox = new AttSMSInbox(shortCode, auth);
        
        try { 
        	inboxMessagesAnswer = smsInbox.checkMessages();
        } catch (AttException ex) {
            isSendErrorsVisible = false;
            isGetStatusErrorsVisible = false;
            isInboxErrorsVisible = true; 
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
            return; 
        }

        inboundMessageList = inboxMessagesAnswer.InboundSmsMessageList.InboundSmsMessage;
        numberOfPendingMessages = String.valueOf(inboxMessagesAnswer.InboundSmsMessageList.TotalNumberOfPendingMessages);
        numberOfMessages = String.valueOf(inboxMessagesAnswer.InboundSmsMessageList.NumberOfMessagesInThisBatch);
        inboxDebugBody = inboxMessagesAnswer.toString();
        isInboxTableVisible = true; 
    }

    public static testmethod void testController() {
        AttClientCredentialsAuthorization auth = TestHttpMockFactory.getCCAuthMock();
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(
        '{"Id": "SMSc04091ed284f5684","ResourceReference": {"ResourceURL": "https://api.att.com /rest/sms/2/messaging/outbox/SMSc04091ed284f5684"}}'
        ));
        
        DemoSMSController controller = new DemoSMSController();
        controller.phoneNumber = '4258028620';
        controller.messageText = '';
        
        System.assertEquals(controller.phoneNumber, '4258028620');
        System.assertEquals(controller.messageText, '');
        System.assertEquals(controller.smsId, null);
        
        controller.messageText = '';
        controller.testAttServiceSMSSend();
        System.assertEquals(ApexPages.getMessages().size(), 1);
        System.assertNotEquals(ApexPages.getMessages().get(0), null);
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Message text must be specified.');
        
        controller.messageText = 'Hello, test!';
        controller.testAttServiceSMSSend();
        System.assertEquals(controller.smsId, 'SMSc04091ed284f5684');
        System.assertEquals(controller.answerSMSSend.ResourceURL, 'https://api.att.com /rest/sms/2/messaging/outbox/SMSc04091ed284f5684');
        System.assertNotEquals(controller.sendSmsDebugBody, null);
        
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(
        '{ "DeliveryInfoList":'+
        '{"DeliveryInfo":'+
        '[{ "Id" : "msg0",'+
        '"Address" : "3500000992",'+
        '"DeliveryStatus" : "DeliveredToTerminal" }] ,'+
        '"ResourceUrl": "https://api.att.com/rest/sms/2/messaging/outbox/SMSa9b192780378404c"}}'));
        controller.testAttServiceSMSCheckStatus();
        System.assertEquals(controller.isStatusTableVisible, true);
        System.assertEquals(controller.deliveryInfoList.get(0).Id, 'msg0');
        System.assertEquals(controller.deliveryInfoList.get(0).Address, '3500000992');
        System.assertEquals(controller.deliveryInfoList.get(0).DeliveryStatus, 'DeliveredToTerminal');
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMockFactory.SingleRequestMock(400,'NOT OK', 'Bad Request'));
        controller.testAttServiceSMSCheckStatus();
        System.assertEquals(ApexPages.getMessages().size(), 2);
        System.assertNotEquals(ApexPages.getMessages().get(1), null);
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Unknown status code error. Response Body: Bad Request');
        
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(
        '{"InboundSmsMessageList": '+
        '{"InboundSmsMessage": '+
        '[{ "MessageId" : "msg0", "Message" : "Hello", "SenderAddress" : "tel:4257850159" '+
        '}], '+
        '"NumberOfMessagesInThisBatch" : "1", '+
        '"ResourceUrl" : "http://api.att.com:8080/rest/sms/2/messaging/inbox", "TotalNumberOfPendingMessages" : "0" '+
        '}}'));     
        controller.testAttServiceSMSInbox();
        
        System.assertNotEquals(controller.inboxMessagesAnswer, null);
        System.assertEquals(controller.inboxMessagesAnswer.inboundSmsMessageList.inboundSmsMessage.get(0).MessageId, 'msg0');
        System.assertEquals(controller.inboxMessagesAnswer.inboundSmsMessageList.inboundSmsMessage.get(0).Message, 'Hello');
        System.assertEquals(controller.inboxMessagesAnswer.inboundSmsMessageList.inboundSmsMessage.get(0).SenderAddress, 'tel:4257850159'); 
        System.assertEquals(controller.inboxMessagesAnswer.inboundSmsMessageList.NumberOfMessagesInThisBatch, 1);
        System.assertEquals(controller.inboxMessagesAnswer.inboundSmsMessageList.ResourceUrl, 'http://api.att.com:8080/rest/sms/2/messaging/inbox');
        System.assertEquals(controller.inboxMessagesAnswer.inboundSmsMessageList.TotalNumberOfPendingMessages, 0);
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMockFactory.SingleRequestMock(400,'NOT OK', 'Bad Inbox Request'));
        controller.testAttServiceSMSInbox();
        System.assertEquals(ApexPages.getMessages().size(), 3);
        System.assertNotEquals(ApexPages.getMessages().get(2), null);
        System.assertEquals(ApexPages.getMessages().get(2).getSummary(), 'Unknown status code error. Response Body: Bad Inbox Request');
        
        controller.getShortCode();
    }
}