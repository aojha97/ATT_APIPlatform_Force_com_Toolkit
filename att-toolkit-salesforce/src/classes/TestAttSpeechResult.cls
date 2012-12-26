@isTest
public class TestAttSpeechResult {

	static testMethod void testParse() {
		String json = '{\"Recognition\":{\"ResponseId\":\"fd155e53215d911aa41c8ee3f2dc2671\",\"NBest\":[{\"WordScores\":[0.07],\"Confidence\":0.98,\"Grade\":\"accept\",\"ResultText\":\"Bananas\",\"Words\":[\"Bananas\"],\"LanguageId\":\"en-us\",\"Hypothesis\":\"Bananas\"}]}}';
		AttSpeechResult obj = AttSpeechResult.parse(json);
		System.assert(obj != null);
		
		AttSpeechResult.Recognition recogn = obj.Recognition;
		
		System.assertEquals(recogn.ResponseId, 'fd155e53215d911aa41c8ee3f2dc2671');
		
		System.assertEquals(recogn.NBest.size(), 1);
		
		AttSpeechResult.NBest nbest = recogn.NBest[0];
		
		System.assertEquals(nbest.Grade, 'accept');
		System.assertEquals(nbest.ResultText, 'Bananas');
		System.assertEquals(nbest.LanguageId, 'en-us');
		System.assertEquals(nbest.Hypothesis, 'Bananas');
		
		System.assertEquals(nbest.Confidence, 0.98);
		
		System.assertEquals(nbest.WordScores.size(), 1);
		System.assertEquals(nbest.WordScores[0], 0.07);
		
		System.assertEquals(nbest.Words.size(), 1);
		System.assertEquals(nbest.Words[0], 'Bananas');
	}
}