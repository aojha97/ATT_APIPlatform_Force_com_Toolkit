@isTest
public class TestDemoMIMController {

	private static TestHttpMockFactory.MultiRequestMock mimMultiMock;
	private static HttpCalloutMock headersMock = TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"MessageHeadersList":{"IndexCursor":"0","Headers":[{"Favorite":true,"MessageId":"S6","Subject":"","Type":"MMS","To":["test@exadel.com"],"Received":"2012-10-12T11:27:06","Read":true,"MmsContent":[{"PartNumber":"0","ContentName":"template.smil","ContentType":"APPLICATION/SMIL"},{"PartNumber":"1","ContentName":"file0","ContentType":"IMAGE/JPEG"},{"PartNumber":"2","ContentName":"file1","ContentType":"AUDIO/X-WAVE"},{"PartNumber":"3","ContentName":"TEXTPART","ContentType":"TEXT/PLAIN"}],"From":"+16508631130","Direction":"OUT"},{"Favorite":false,"Text":"TimeTrack:1:aB9WjZghvWjRU/6MBQ==","MessageId":"r33","Type":"SMSTEXT","To":["+16508631130"],"Received":"2012-10-12T10:33:29","Read":false,"Direction":"IN","From":"28873569"}],"HeaderCount":"2"}}');
	
	static {
		mimMultiMock = new TestHttpMockFactory.MultiRequestMock(new Map<String, HttpCalloutMock> {
			ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.GET_ACCESS_TOKEN) => TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"access_token":"40da93dc50663e4f2cd9ea5c2c36b54b","expires_in":"-1000","refresh_token":"941744be3d2ddec96bc2de1f2b20bd6c7ca8feae"}')
		});
		Test.setMock(HttpCalloutMock.class, mimMultiMock);
	}	
	
	public static testmethod void testInitialization() {
		DemoMIMController controller = new DemoMIMController();
		
		// check initialization parameters
		System.assertEquals(50, controller.headerCount);
		System.assertEquals('', controller.indexCursor);
		System.assertEquals('I3', controller.messageId);
		System.assertEquals(1, controller.partNumber);
		System.assertEquals(true, controller.showHeadersMessages);
		System.assertEquals(false, controller.showContentMessages);		
		System.assertEquals(false, controller.isTextContent);
		System.assertEquals(false, controller.isApplicationContent);
		System.assertEquals(false, controller.isImageContent);
		
		// check for wrong headers parameters
		controller = new DemoMIMController();		
		controller.auth = TestHttpMockFactory.getCodeAuthMock();
		controller.mimService.auth = TestHttpMockFactory.getCodeAuthMock();
		controller.authorized = true;
		controller.action = DemoMIMController.Action.GET_HEADERS;
		controller.HeaderCount = null;
		controller.IndexCursor = null;
		try {
			controller.getMessageHeaders();
		} catch (AttException ex) {
			System.assertEquals('Headers count must be specified', ex.getMessage());
		}
		
		controller.HeaderCount = 0;
		controller.IndexCursor = null;
		System.debug('authorized: ' + controller.authorized);
		try {
			controller.getMessageHeaders();
		} catch (AttException ex) {
			System.assertEquals(ex.getMessage(), 'Headers count must be in range 1..500');
		}
		
		// check for wrong content parameters 
		controller.action = DemoMIMController.Action.GET_HEADERS;
		controller.MessageId = null;
		controller.PartNumber = null;
		try {
			controller.getMessageContent();
		} catch (AttException ex) {
			System.assertEquals('Message id must be specified.', ex.getMessage());
		}		
		controller.MessageId = 'I3';		
		try {
			controller.getMessageContent();
		} catch (AttException ex) {
			System.assertEquals('Part number must be specified', ex.getMessage());
		}
		controller.PartNumber = -1;
		try {
			controller.getMessageContent();
		} catch (AttException ex) {
			System.assertEquals('Part number value can\'t be negative', ex.getMessage());
		}
		
		// invoke action service witout action 
		ApexPages.currentPage().getParameters().put('code', TestHttpMockFactory.AUTH_CODE);
		controller = new DemoMIMController();
		
		System.assertEquals('Wrong action specified: \'null\'', ApexPages.getMessages().get(ApexPages.getMessages().size() - 1).getSummary());
		
		// check for get headers parameters loading after return from end-user authorizaiton
		Integer headersCount = 2;
		String url = ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.MIM) + '?HeaderCount=' + String.valueOf(headersCount);
		mimMultiMock.addRequestMock(url, headersMock);			
		
		ApexPages.currentPage().getParameters().put('code', TestHttpMockFactory.AUTH_CODE);
		ApexPages.currentPage().getParameters().put('action', 'GET_HEADERS');
		ApexPages.currentPage().getParameters().put('HeaderCount', String.valueOf(headersCount));
		controller = new DemoMIMController();
		System.assertEquals(DemoMIMController.Action.GET_HEADERS, controller.action);
		System.assertEquals(headersCount, controller.HeaderCount);
		System.assertEquals('0', controller.IndexCursor);
		
		// check for get content parameters loading after return from end-user authorizaiton
		ApexPages.currentPage().getParameters().put('code', TestHttpMockFactory.AUTH_CODE);
		ApexPages.currentPage().getParameters().put('action', 'GET_CONTENT');
		ApexPages.currentPage().getParameters().put('MessageId', 'I3');
		ApexPages.currentPage().getParameters().put('PartNumber', '1');
		url = ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.MIM) + '/I3/1';
		mimMultiMock.addRequestMock(url, new TestHttpMockFactory.SingleRequestMock(200, 'Created', Blob.valueOf('Message text'), new Map<String, String> {
    		'Content-Type' => 'TEXT/PLAIN; name=text.txt'
    	}));
		controller = new DemoMIMController();
		System.assertEquals(DemoMIMController.Action.GET_CONTENT, controller.action);
		System.assertEquals('I3', controller.messageId);
		System.assertEquals(1, controller.partNumber);
	}
	
	public static testmethod void testAttMIMGetHeaders() {	
		// create controller with authorization
		DemoMIMController controller = new DemoMIMController();
		controller.mimService.auth = TestHttpMockFactory.getCodeAuthMock();
		controller.authorized = true;
		
		// execute get headers action
		controller.headerCount = 10;
		controller.indexCursor = ' ';
		
		mimMultiMock.addRequestMock(ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.MIM) + '?HeaderCount=10', headersMock);
		controller.getMessageHeaders();
		System.assertEquals(2, controller.headerCount);
		System.assertEquals('0', controller.indexCursor);
		System.assertEquals(2, controller.headers.size());
		System.assertEquals(true, controller.showHeadersMessages);
		System.assertEquals(false, controller.showContentMessages);		
		System.assertEquals('Listed Headers Count: 2 from the first element. Reached the end of the headers list.', controller.headersDescription);
		
		// execute get headers action with '0' index cursor
		controller.headerCount = 10;
		controller.indexCursor = '0';
		
		controller.getMessageHeaders();
		System.assertEquals(2, controller.headerCount);
		System.assertEquals('0', controller.indexCursor);
		System.assertEquals(2, controller.headers.size());
		System.assertEquals(true, controller.showHeadersMessages);
		System.assertEquals(false, controller.showContentMessages);		
		System.assertEquals('Listed Headers Count: 2 from the first element. Reached the end of the headers list.', controller.headersDescription);		
		
		// execute get headers action with not empty index cursor
		controller.headerCount = 10;
		controller.indexCursor = ' r:174:,S:100:,t:64:,I:11:, ';
		
		String url = ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.MIM) + '?HeaderCount=10&IndexCursor=r:174:,S:100:,t:64:,I:11:,';
		mimMultiMock.addRequestMock(url, headersMock);
		controller.getMessageHeaders();
		System.assertEquals(2, controller.headerCount);
		System.assertEquals('0', controller.indexCursor);
		System.assertEquals(2, controller.headers.size());
		System.assertEquals(true, controller.showHeadersMessages);
		System.assertEquals(false, controller.showContentMessages);		
		System.assertEquals('Listed Headers Count: 2 from the "r:174:,S:100:,t:64:,I:11:," index cursor. Reached the end of the headers list.', controller.headersDescription);		
		
		controller.headerCount = 10;
		controller.indexCursor = ' ';
	}
	
	public static testmethod void testAttMIMGetMessageContent() {
		// create controller with authorization
		DemoMIMController controller = new DemoMIMController();
		controller.mimService.auth = TestHttpMockFactory.getCodeAuthMock();
		controller.authorized = true;
		
		// execute get message content action for TEXT/PLAIN mime type
		controller.messageId = 'I3';
		controller.partNumber = 2;

		String url = ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.MIM) + '/I3/2';
		mimMultiMock.addRequestMock(url, new TestHttpMockFactory.SingleRequestMock(200, 'Created', Blob.valueOf('Message text'), new Map<String, String> {
    		'Content-Type' => 'TEXT/PLAIN; name=text.txt'
    	}));		
		controller.getMessageContent();
		System.assertEquals('I3', controller.messageId);
		System.assertEquals(2, controller.partNumber);
		System.assertEquals('text.txt', controller.contentFileName);
		System.assertEquals('Message text', controller.content);		
		System.assertEquals(false, controller.showHeadersMessages);
		System.assertEquals(true, controller.showContentMessages);
		
		// execute get message content action for APPLICATION/SMIL mime type
		controller.messageId = 'I3';
		controller.partNumber = 0;
		
		url = ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.MIM) + '/I3/0';
		mimMultiMock.addRequestMock(url, new TestHttpMockFactory.SingleRequestMock(200, 'Created', Blob.valueOf('<smil><head><layout><root-layout/><region id="Text" top="70%" left="0%" height="30%" width="100%" fit="scroll"/><region id="Image" top="0%" left="0%" height="70%" width="100%" fit="meet"/></layout></head><body><par dur="10s"><text src="text_0001.txt" region="Text"/></par></body></smil>'), new Map<String, String> {
    		'Content-Type' => 'APPLICATION/SMIL; name=template.smil'
    	}));
		controller.getMessageContent();		
		System.assertEquals('I3', controller.messageId);
		System.assertEquals(0, controller.partNumber);
		System.assertEquals('template.smil', controller.contentFileName);
		System.assertEquals('<smil><head><layout><root-layout/><region id="Text" top="70%" left="0%" height="30%" width="100%" fit="scroll"/><region id="Image" top="0%" left="0%" height="70%" width="100%" fit="meet"/></layout></head><body><par dur="10s"><text src="text_0001.txt" region="Text"/></par></body></smil>', controller.content);		
		System.assertEquals(false, controller.showHeadersMessages);
		System.assertEquals(true, controller.showContentMessages);
		
		// execute get message content action for IMAGE/JPEG mime type
		controller.messageId = 'I3';
		controller.partNumber = 1;
		
		url = ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.MIM) + '/I3/1';
		mimMultiMock.addRequestMock(url, new TestHttpMockFactory.SingleRequestMock(200, 'Created', Encodingutil.base64Decode('/9j/4AAQSkZJRgABAQAAAQABAA'), new Map<String, String> {
    		'Content-Type' => 'IMAGE/JPEG; name=image.jpg'
    	}));		
		controller.getMessageContent();		
		System.assertEquals('I3', controller.messageId);
		System.assertEquals(1, controller.partNumber);
		System.assertEquals('image.jpg', controller.contentFileName);
		System.assertEquals('data:IMAGE/JPEG;base64,/9j/4AAQSkZJRgABAQAAAQABAA==', controller.content);		
		System.assertEquals(false, controller.showHeadersMessages);
		System.assertEquals(true, controller.showContentMessages);
		
		// execute get message content action for AUDIO/AMR mime type
		controller.messageId = 'I4';
		controller.partNumber = 2;
		
		url = ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.MIM) + '/I4/2';
		mimMultiMock.addRequestMock(url, new TestHttpMockFactory.SingleRequestMock(200, 'Created', Encodingutil.base64Decode('/9j/4AAQSkZJRgABAQAAAQABAA'), new Map<String, String> {
    		'Content-Type' => 'AUDIO/AMR; name=sample.amr'
    	}));		
		controller.getMessageContent();		
		System.assertEquals('I4', controller.messageId);
		System.assertEquals(2, controller.partNumber);
		System.assertEquals('sample.amr', controller.contentFileName);
		System.assertEquals('/9j/4AAQSkZJRgABAQAAAQABAA==', controller.content);		
		System.assertEquals(false, controller.showHeadersMessages);
		System.assertEquals(true, controller.showContentMessages);		
	}
}