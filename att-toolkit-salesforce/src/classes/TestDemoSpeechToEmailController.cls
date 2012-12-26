@isTest
public class TestDemoSpeechToEmailController {
	
	public static testmethod void testController() {
		DemoSpeechToEmailController controller = new DemoSpeechToEmailController();
		controller.auth = TestHttpMockFactory.getCCAuthMock();
		 
		System.assertEquals(controller.filePath, null);
		System.assertEquals(0, ApexPages.getMessages().size());
		
		controller.testAttServiceSpeech();
		System.assertEquals(DemoSpeechToEmailController.INVALID_EMAIL_AND_PHONE_NUMBER, ApexPages.getMessages().get(0).getSummary());
		
		controller.targetAddr = 'asd';
		controller.testAttServiceSpeech();
		System.assertEquals(DemoSpeechToEmailController.INVALID_EMAIL_OR_PHONE_NUMBER_FORMAT, ApexPages.getMessages().get(1).getSummary());

		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"Id": "SMSc04091ed284f5684","ResourceReference": {"ResourceURL": "https://api.att.com/rest/sms/2/messaging/outbox/SMSc04091ed284f5684"}}'));		
		controller.targetAddr = '4258028620';
    	controller.fileBlob = Blob.valueOf('1234567890');
    	controller.testAttServiceSpeech();
		System.assertEquals(DemoSpeechToEmailController.FILE_NOT_SPECIFIED,ApexPages.getMessages().get(2).getSummary());

		controller.filePath = 'c:/audio.ogg';
    	controller.testAttServiceSpeech();
		System.assertEquals(DemoSpeechToEmailController.UNSUPPORTED_FILE_FORMAT,ApexPages.getMessages().get(3).getSummary());
		
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"Recognition":{"ResponseId":"3e78bd2eb204ad7f574e95a7c6a52625","NBest":[{"WordScores":[1,1],"Confidence":1,"Grade":"accept","ResultText":"Boston celtics.","Words":["Boston","celtics."],"LanguageId":"en-us","Hypothesis":"Boston celtics."}]}}'));		
		controller.filePath = 'c:/audio.amr';
    	controller.testAttServiceSpeech();
		
		controller.filePath = 'c:/audio.wav';
		controller.targetAddr = 'name.surname@domen.com';
    	controller.testAttServiceSpeech();
	}
}