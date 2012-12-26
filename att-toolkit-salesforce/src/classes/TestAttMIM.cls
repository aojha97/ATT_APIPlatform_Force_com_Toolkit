@isTest
public class TestAttMIM {
	
	public static testmethod void testService() {
		AttMIM mimService = new AttMIM(TestHttpMockFactory.getCodeAuthMock());
		
		// invoke get message headers service
		Integer headersCount = 2;
		String indexCursor = '';
		
		// add MIM service http call out mock
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"MessageHeadersList":{"IndexCursor":"0","Headers":[{"Favorite":true,"MessageId":"S6","Subject":"","Type":"MMS","To":["test@exadel.com"],"Received":"2012-10-12T11:27:06","Read":true,"MmsContent":[{"PartNumber":"0","ContentName":"template.smil","ContentType":"APPLICATION/SMIL"},{"PartNumber":"1","ContentName":"file0","ContentType":"IMAGE/JPEG"},{"PartNumber":"2","ContentName":"file1","ContentType":"AUDIO/X-WAVE"},{"PartNumber":"3","ContentName":"TEXTPART","ContentType":"TEXT/PLAIN"}],"From":"+16508631130","Direction":"OUT"},{"Favorite":false,"Text":"TimeTrack:1:aB9WjZghvWjRU/6MBQ==","MessageId":"r33","Type":"SMSTEXT","To":["+16508631130"],"Received":"2012-10-12T10:33:29","Read":false,"Direction":"IN","From":"28873569"}],"HeaderCount":"2"}}'));
    	AttMIMMessageHeaders mimHeaders = mimService.getHeaders(headersCount, indexCursor);
    	System.assert(mimHeaders != null);
    	System.assert(mimHeaders.messageHeadersList != null);
    	System.assertEquals(mimHeaders.messageHeadersList.headers.size(), 2);
    	
    	// invoke get message content service
    	Test.setMock(HttpCalloutMock.class, new TestHttpMockFactory.SingleRequestMock(200, 'Created', Blob.valueOf('Message text'), new Map<String, String> {
    		'Content-Type' => 'TEXT/PLAIN; name=text.txt'
    	}));
		AttAttachment mssAttachemnt = mimService.getContent('I4', 2);
		System.assertNotEquals(mimHeaders, null);
		System.assertEquals(mssAttachemnt.mimeType, 'TEXT/PLAIN');
		System.assertEquals(mssAttachemnt.fileName, 'text.txt');		
		System.assertEquals(mssAttachemnt.content.toString(), Blob.valueOf('Message text').toString());
	}
}