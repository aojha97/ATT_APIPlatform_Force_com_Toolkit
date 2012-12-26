@isTest
public class TestAttMMSSending {
		
	public static AttClientCredentialsAuthorization auth;
	public static MultiStaticResourceCalloutMock mock;
	
	static {
		auth = TestHttpMockFactory.getCCAuthMock();
	}
		
	public static testmethod void testGetDeliveryStatus() {
		//Success
		AttMMSOutboxStatus sendStatus = sendMmsSuccessfully();
		
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(
		'{ "DeliveryInfoList": {' +   
   			'"DeliveryInfo": [{' +
        		'"Id" : "msg0",' +
        		'"Address" : "3500000992",' +
        		'"DeliveryStatus" : "DeliveredToTerminal"' + 
    		'}],' +    
    		'"ResourceURL": "https://api.att.com/rest/mms/2/messaging/outbox/MMSa9b192780378404c" }' + 
		'}'));
		
		AttMessageDeliveryStatus deliveryStatus = sendStatus.getDeliveryStatus();
		System.assertEquals(1, deliveryStatus.deliveryInfoList.size());
		System.assertEquals('msg0', deliveryStatus.deliveryInfoList.get(0).id);
		System.assertEquals('3500000992', deliveryStatus.deliveryInfoList.get(0).address);
		System.assertEquals('DeliveredToTerminal', deliveryStatus.deliveryInfoList.get(0).deliveryStatus);
		
		//Test parse error
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('incorrect JSON'));
		try {
            sendStatus.getDeliveryStatus();
            System.assert(false);
        } catch(AttException ex){
            //do nothing
        }
	}
	
	public static testmethod void testSendMms() {
		AttMMSOutbox box = new AttMMSOutbox(auth);
				
		//Successful sending test		
		AttMMSOutboxStatus sendStatus = sendMmsSuccessfully();
		System.assertEquals('MMSa9b17cdae1f70f8c', sendStatus.id);
		System.assertEquals('https://api.att.com/rest/mms/2/messaging/outbox/MMSa9b17cdae1f70f8c', sendStatus.resourceURL);
		
		//Network error test
		AttMMS message = prepeareMms();
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getErrorHttpMock());
		try {
            box.sendMessage(message);
            System.assert(false);
        } catch(AttException ex){
            System.assertEquals(400, ex.statusCode);
        }
        
        //phoneNumber is missed
        message = prepeareMms();
        message.phoneNumber = null;
		try {
            box.sendMessage(message);
            System.assert(false);
        } catch(AttException ex){
             System.assertEquals('Phone number must be specified.', ex.getMessage());
        }
        
        //subject is missed
        message = prepeareMms();
        message.subject = null;
		try {
            box.sendMessage(message);
            System.assert(false);
        } catch(AttException ex){
             System.assertEquals('Subject must be specified.', ex.getMessage());
        }
        
        //attachments is empty
        message = prepeareMms();
        message.attachments = new List<AttAttachment>();		
		try {
            box.sendMessage(message);
            System.assert(false);
        } catch(AttException ex){
             System.assertEquals('No file has been attached.', ex.getMessage());
        }
	}
	
	static testMethod void testMmsOutboxStatusParse() {
		String json = '{'+
		'"Id": "MMSa9b17cdae1f70f8c",'+
		'"ResourceReference": {'+
				'"ResourceURL": "https://api.att.com/rest/mms/2/messaging/outbox/MMSa9b17cdae1f70f8c"'+
			'}'+
		'}';		
		AttMMSOutboxStatus status = new AttMMSOutboxStatus(json, auth);
		System.assertEquals('MMSa9b17cdae1f70f8c', status.id);
		System.assertEquals('https://api.att.com/rest/mms/2/messaging/outbox/MMSa9b17cdae1f70f8c', status.resourceUrl);
		
		try {
			json = '{'+
			'"ResourceReference": {'+
			'"ResourceURL": "https://api.att.com/rest/mms/2/messaging/outbox/MMSa9b17cdae1f70f8c"'+
			'                     }'+
			'}';
			status = new AttMMSOutboxStatus(json, auth);
			System.assert(false);
		} catch (AttException e) {
			//do nothing
		}
		
		try {
			json = '{'+
				'"Id": "MMSa9b17cdae1f70f8c",'+
			'}';
			status = new AttMMSOutboxStatus(json, auth);
			System.assert(false);
		} catch (AttException e) {
			//do nothing
		}
	}
	
	static testMethod void restoreOutboxStatusByMMSId() {
		AttMMSOutbox box = new AttMMSOutbox(auth);
		AttMMSOutboxStatus status = box.restoreOutboxStatusByMMSId('TestMMSId');
		System.assertEquals('TestMMSId', status.Id);
	}
	
	public static AttMMS prepeareMms() {
		AttAttachment attachment = new AttAttachment(EncodingUtil.base64Decode('dddd'), 'file.txt', 'text/txt');
		AttMMS message = new AttMMS();
		message.phoneNumber = '4258028620';
		message.subject = 'test';		
		message.attachments.add(attachment);
		return message;
	}
	
	public static AttMMSOutboxStatus sendMmsSuccessfully() {
		AttMMSOutbox box = new AttMMSOutbox(auth);
		
		//Successful sending test
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(
		'{"Id": "MMSa9b17cdae1f70f8c",' +
    		'"ResourceReference": {' +
        		'"ResourceUrl": "https://api.att.com/rest/mms/2/messaging/outbox/MMSa9b17cdae1f70f8c"' +
    		'}' +
    	'}'));	
		
		return box.sendMessage(prepeareMms());
	}
	
}