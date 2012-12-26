@isTest
public class TestAttWAPPush {
	
	static {
		HttpCalloutMock wapPushMock = TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"id" : "WAPPUSHa9b454d0ee03ae28"}');
		Test.setMock(HttpCalloutMock.class, wapPushMock);
	}
	
	static testmethod void testService() {
		
		// create WAP Push service
		AttWAPPush wapPush = new AttWAPPush(TestHttpMockFactory.getCCAuthMock());		
		wapPush.phoneNumbers = new Set<String> { '+14258028620' };
		wapPush.url = 'http://developer.att.com';
		wapPush.message = 'Test WAP Push';
		
		// send wap push		
		AttWAPPushResult result = wapPush.sendWAPPush();
		System.assertEquals('WAPPUSHa9b454d0ee03ae28', result.id);
		
		wapPush.phoneNumbers = new Set<String> { '+14258028620', '+1-650-8631130' };
		result = wapPush.sendWAPPush();
		System.assertEquals('WAPPUSHa9b454d0ee03ae28', result.id);
	}
}