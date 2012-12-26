@isTest
public class TestDemoWAPPushController {
	
	static {
		HttpCalloutMock wapPushMock = TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"id" : "WAPPUSHa9b454d0ee03ae28"}');
		Test.setMock(HttpCalloutMock.class, wapPushMock);
	}	
		
	static testmethod void testinitialization() {
		DemoWAPPushController controller = new DemoWAPPushController();
		System.assertEquals(new List<String> {'tel:6508631130', 'tel:6502965430'}, controller.phoneNumbers);
		System.assertNotEquals(null, controller.wapPush);
		System.assertEquals('', controller.phone);
		System.assertEquals('', controller.id);
		System.assertEquals('', controller.message);
		System.assertEquals('', controller.url);		
	}
	
	static testmethod void testSendWapPush() {
		DemoWAPPushController controller = new DemoWAPPushController();
        controller.wapPush.auth = TestHttpMockFactory.getCCAuthMock();
        
		// empty phone numbers
		controller.phoneNumbers = new List<String>();
		try {
			controller.sendWAPPush();
		} catch (AttException ex) {
			System.assertEquals('At least one phone number must be specified.', ex.getMessage());			
		}
		
		// wrong URL
		controller.phoneNumbers = new List<String> {'tel:6502965430'};
		try {
			controller.sendWAPPush();
		} catch (AttException ex) {
			System.assertEquals('URL must be specified.', ex.getMessage());			
		}
		
		// wrong message
		controller.url = 'http://developer.att.com ';
		try {
			controller.sendWAPPush();
		} catch (AttException ex) {
			System.assertEquals('Message must be specified.', ex.getMessage());			
		}
        
        // Send WAP Push message
		controller.message = ' Test WAP Push ';
		controller.sendWAPPush();
		System.assertEquals('Test WAP Push', controller.message);
		System.assertEquals('http://developer.att.com', controller.url);
		System.assertEquals(new List<String> {'tel:6502965430'}, controller.phoneNumbers);
		System.assertEquals('Message has been sent. Message ID: \'WAPPUSHa9b454d0ee03ae28\'', ApexPages.getMessages().get(3).getSummary());
		
		// add numbers
		controller.message = 'Test WAP Push';
		controller.phoneNumbers = new List<String>();
		
		controller.phone = '156-14258028';
		controller.addNumber();
		System.assertEquals(new List<String> {'tel:5614258028'}, controller.phoneNumbers);
		System.assertEquals('', controller.phone);
		
		controller.phone = '26859456321';
		controller.addNumber();
		System.assertEquals(new List<String> {'tel:5614258028', 'tel:6859456321'}, controller.phoneNumbers);
		System.assertEquals('', controller.phone);
		
		controller.phone = '6859456321';
		controller.addNumber();
		System.assertEquals(new List<String> {'tel:5614258028', 'tel:6859456321'}, controller.phoneNumbers);
		System.assertEquals('', controller.phone);
		
		controller.phone = '+26859456321';
		controller.addNumber();
		System.assertEquals(new List<String> {'tel:5614258028', 'tel:6859456321'}, controller.phoneNumbers);
		System.assertEquals('', controller.phone);
		
		controller.phone = '+1-650-8639610';
		controller.addNumber();
		System.assertEquals(new List<String> {'tel:5614258028', 'tel:6859456321', 'tel:6508639610'}, controller.phoneNumbers);
		System.assertEquals('', controller.phone);
				
		// remove numbers
		controller.phone = '+1-650-8639610';
		controller.removeNumber();
		System.assertEquals(new List<String> {'tel:5614258028', 'tel:6859456321'}, controller.phoneNumbers);
		System.assertEquals('', controller.phone);
		
		// clear numbers
		controller.clearNumbers();
		System.assertEquals(new List<String>(), controller.phoneNumbers);
		System.assertEquals('', controller.phone);
	}
}