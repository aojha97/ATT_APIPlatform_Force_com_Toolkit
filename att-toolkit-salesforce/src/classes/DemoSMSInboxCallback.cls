@RestResource(urlMapping='/SMSInboxCallback')
global class DemoSMSInboxCallback {

	@HttpPost
    global static void doPost() {
    	DemoSMSToEmailCallbackProcessor callbackProcessor = new DemoSMSToEmailCallbackProcessor(RestContext.request.requestBody.toString());
    	callbackProcessor.processMessage();
    }
}