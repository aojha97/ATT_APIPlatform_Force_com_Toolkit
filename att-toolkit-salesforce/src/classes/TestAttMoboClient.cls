@isTest
public class TestAttMoboClient {
	
	private static final String MESSAGE_ID = 'TestStatusID';

    static testMethod void testSendMessage() {
        AttMoboMsg msg = new AttMoboMsg();
        msg.dstAddresses = new List<String> {'tel:1234567890'};
        msg.messageText = 'Some message';
        
        AttMoboClient moboClient = new AttMoboClient(TestHttpMockFactory.getCodeAuthMock());
        Test.setMock(HttpCalloutMock.class, new TestHttpMockFactory.SingleRequestMock(200,'OK',Blob.ValueOf('{ \"Id\": \"' + MESSAGE_ID + '\" }'),new Map<String, String> {'Content-Type' => 'application/json'}));
        AttMoboSendStatus status = moboClient.sendMessage(msg);
        System.assertEquals(MESSAGE_ID,status.id);
        
        String fileName = 'myFile.txt';
        msg.attachments.add(new AttAttachment(Blob.ValueOf('Attachment Body'),fileName,AttAttachment.getMimeTypeByFileName(fileName),AttAttachment.ENCODING_BASE64));
        status = moboClient.sendMessage(msg);
        System.assertEquals(MESSAGE_ID,status.id);
    }
}