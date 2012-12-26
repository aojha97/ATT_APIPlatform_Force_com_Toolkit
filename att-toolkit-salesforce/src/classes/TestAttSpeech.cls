@isTest
public class TestAttSpeech {
	
	static {
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"Recognition":{"ResponseId":"3e78bd2eb204ad7f574e95a7c6a52625","NBest":[{"WordScores":[1,1],"Confidence":1,"Grade":"accept","ResultText":"Boston celtics.","Words":["Boston","celtics."],"LanguageId":"en-us","Hypothesis":"Boston celtics."}]}}'));		
	}

	static testmethod void testService() {
       	AttSpeech speech = new AttSpeech(TestHttpMockFactory.getCCAuthMock());
       	
       	// check file type presence and void speech context  
       	try {
       		speech.convert();
       		System.assert(false);
       	} catch(AttException ex) {
       		System.assertEquals(ex.getMessage(), 'File type is required parameter.');
       	}
       	// check speech context
       	System.assertEquals(AttSpeech.SpeechContext.GENERIC, speech.speechContext);
       	
       	// check file blob presence and wrong speech context
       	speech.fileType = AttSpeech.FileType.AMR;
       	try {
       		speech.convert();
       		System.assert(false);
       	} catch(AttException ex) {
       		System.assertEquals(ex.getMessage(), 'File BLOB is required parameter.');
       	}
       	// check speech context
       	System.assertEquals(AttSpeech.SpeechContext.GENERIC, speech.speechContext);
       	
       	// check audio file of unsupported type
       	speech.fileBlob = Blob.valueOf('1234567890');
       	try {
       		speech.convert();
       		System.assert(true);
       	} catch(AttException ex) {
       		System.assertEquals(ex.getMessage(), 'Speech service support only \'wav\' and \'amr\' audio files.');
       	}
       	
       	try {
			speech.fileType = AttSpeech.FileType.AMR;
			for (AttSpeech.SpeechContext ctx : AttSpeech.SpeechContext.values()) {
				speech.speechContext = ctx;
	       			
				AttSpeechResult response = speech.convert();		        		
	        		
	    		System.assertNotEquals(null, response);
				AttSpeechResult.Recognition recogn = response.Recognition;
				System.assertNotEquals(null, recogn);
				AttSpeechResult.NBest nbest = recogn.NBest[0];
				System.assertNotEquals(null, nbest);
				System.assertEquals('accept', nbest.Grade);
				System.assertEquals('1.0', '' + nbest.Confidence);
				System.assertEquals('en-us', nbest.LanguageId);
				System.assertEquals('Boston celtics.', nbest.Hypothesis);
				System.assertEquals('Boston celtics.', nbest.ResultText);
	       	}       		
       	} catch(AttException ex) {
       		System.assert(false);
       	}	
    }
}