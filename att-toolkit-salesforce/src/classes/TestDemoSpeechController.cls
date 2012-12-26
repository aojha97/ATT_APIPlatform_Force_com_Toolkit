@isTest
public class TestDemoSpeechController {
	
	static {
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"Recognition":{"ResponseId":"3e78bd2eb204ad7f574e95a7c6a52625","NBest":[{"WordScores":[1,1],"Confidence":1,"Grade":"accept","ResultText":"Boston celtics.","Words":["Boston","celtics."],"LanguageId":"en-us","Hypothesis":"Boston celtics."}]}}'));
	}
	
	public static testmethod void testController() {
		DemoSpeechController controller = new DemoSpeechController();
		controller.auth = TestHttpMockFactory.getCCAuthMock();

		System.assertEquals(controller.fileName, '');
		System.assertEquals(controller.fileNameReal, '');
		System.assertEquals(controller.fileBlob, null);
		
		controller.testAttServiceSpeech();
    	System.assertEquals(ApexPages.getMessages().size(), 1);
    	System.assertNotEquals(ApexPages.getMessages().get(0), null);
    	System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Please select file before send request...');
		System.assertEquals(controller.debugBody, '');
    	System.assertEquals(controller.resGrade, '');
    	System.assertEquals(controller.resConfidence, '');
    	System.assertEquals(controller.resLanguageId, '');
    	System.assertEquals(controller.resHypothesis, '');
    	System.assertEquals(controller.resResultText, '');
    	System.assertEquals(controller.resWordScores, '');
    	
    	controller.fileNameReal = 'c:/audio.ogg';
    	controller.fileBlob = Blob.valueOf('1234567890');
		controller.testAttServiceSpeech();
    	System.assertEquals(ApexPages.getMessages().size(), 2);
    	System.assertNotEquals(ApexPages.getMessages().get(1), null);
    	System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Speech service support only \'wav\' and \'amr\' audio files.');
		System.assertEquals(controller.debugBody, '');
    	System.assertEquals(controller.resGrade, '');
    	System.assertEquals(controller.resConfidence, '');
    	System.assertEquals(controller.resLanguageId, '');
    	System.assertEquals(controller.resHypothesis, '');
    	System.assertEquals(controller.resResultText, '');
    	System.assertEquals(controller.resWordScores, '');
    	
    	controller.fileNameReal = 'c:/audio.mp3';
    	controller.fileBlob = Blob.valueOf('1234567890');
		controller.testAttServiceSpeech();
    	System.assertEquals(ApexPages.getMessages().size(), 2);
    	System.assertNotEquals(ApexPages.getMessages().get(1), null);
    	System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Speech service support only \'wav\' and \'amr\' audio files.');
		System.assertEquals(controller.debugBody, '');
    	System.assertEquals(controller.resGrade, '');
    	System.assertEquals(controller.resConfidence, '');
    	System.assertEquals(controller.resLanguageId, '');
    	System.assertEquals(controller.resHypothesis, '');
    	System.assertEquals(controller.resResultText, '');
    	System.assertEquals(controller.resWordScores, '');
    	
    	controller.fileNameReal = 'c:/audio.cd';
    	controller.fileBlob = Blob.valueOf('1234567890');
		controller.testAttServiceSpeech();
    	System.assertEquals(ApexPages.getMessages().size(), 2);
    	System.assertNotEquals(ApexPages.getMessages().get(1), null);
    	System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Speech service support only \'wav\' and \'amr\' audio files.');
		System.assertEquals(controller.debugBody, '');
    	System.assertEquals(controller.resGrade, '');
    	System.assertEquals(controller.resConfidence, '');
    	System.assertEquals(controller.resLanguageId, '');
    	System.assertEquals(controller.resHypothesis, '');
    	System.assertEquals(controller.resResultText, '');
    	System.assertEquals(controller.resWordScores, '');
    	
    	controller.fileNameReal = 'c:/audio.wav';
    	controller.fileBlob = Blob.valueOf('1234567890');
		controller.testAttServiceSpeech();
    	System.assertEquals(ApexPages.getMessages().size(), 2);
    	System.assertEquals(controller.resGrade, 'accept');
    	System.assertEquals(controller.resConfidence, '1.0');
    	System.assertEquals(controller.resLanguageId, 'en-us');
    	System.assertEquals(controller.resHypothesis, 'Boston celtics.');
    	System.assertEquals(controller.resResultText, 'Boston celtics.');
    	System.assertEquals(controller.resWordScores, '1.0, 1.0, ');
	}
}