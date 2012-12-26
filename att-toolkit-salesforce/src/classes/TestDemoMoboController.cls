@isTest
public class TestDemoMoboController {	
	public static testmethod void testController() {		
		ApexPages.currentPage().getParameters().put('code','testcodeexample'); //end user authorization
		DemoMoboController controller = new DemoMoboController();
		
		try {
			controller.targetAddresses = '48275948172 48275948172 48275948172 48275948172 48275948172 48275948172 48275948172 48275948172 48275948172 48275948172 48275948172';
			controller.invokeService();
		} catch (AttException ex) {
			System.assertEquals('Address list is invalid', ex.getMessage());
		}

		try {		
			controller.targetAddresses = 'wrong number';
			controller.invokeService();
		} catch (AttException ex) {
			System.assertEquals('Invalid e-mail address or phone number format', ex.getMessage());
		}
		
		Test.setMock(HttpCalloutMock.class, new TestHttpMockFactory.SingleRequestMock(200,'OK',Blob.ValueOf('{ \"Id\": \"TestMsgId\" }'),new Map<String, String> {'Content-Type' => 'application/json'})); //for send message
		controller.targetAddresses = 'dvoloshyn@exadel.com  48275948172; 47582';
		controller.subject = 'message subject';
		controller.messageBody = '';
		controller.isGroup = true;
		controller.invokeService();
		
		controller.attachment1 = Blob.valueOf('Test string');
		controller.fileName1 = 'filename.txt';
		controller.attachment2 = Blob.valueOf('Test string');
		controller.fileName2 = 'filename.jpg';
		controller.attachment3 = Blob.valueOf('Test string');
		controller.fileName3 = 'filename.gif';
		controller.attachment4 = Blob.valueOf('Test string');
		controller.fileName4 = 'filename.3gp';
		controller.invokeService();
		System.assertEquals(true,getLastMessage().contains(DemoMoboController.SUCCESS_MESSAGE));
		
		controller.fileName1 = 'filename.mp4';
		controller.fileName2 = 'filename.amr';
		controller.fileName3 = 'filename.mid';
		controller.fileName4 = 'filename.mp3';
		controller.invokeService();
		System.assertEquals(true,getLastMessage().contains(DemoMoboController.SUCCESS_MESSAGE));
		
		controller.fileName1 = 'filename.aac';
		controller.fileName2 = 'filename.wav';
		controller.fileName3 = 'filename.pdf';
		controller.fileName4 = 'filename.abc';
		controller.invokeService();
		
		controller.targetAddresses = 'dvoloshyn@exadel.com  48275948172; 47582 74638264958172';
		controller.invokeService();		
	}
	
	private static String getLastMessage() {
		return ApexPages.getMessages().get(ApexPages.getMessages().size() - 1).getSummary();
	}
}