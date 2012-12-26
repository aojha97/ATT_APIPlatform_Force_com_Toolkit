public class DemoSMSToEmailCallbackProcessor extends AttSMSCallbackProcessor {
	
	public DemoSMSToEmailCallbackProcessor(String requestBody) {
		super(requestBody);
	}
	
	public override void processMessage() {
    	Matcher emailAddrMatcher = DemoUtils.EMAIL_REGEXP_PATTERN.matcher(smsRecord.Message);
    	if (emailAddrMatcher.find()) {
    		Integer prefixEndIndex = smsRecord.SenderAddress.indexOf(':');
    		String senderAddress = prefixEndIndex == -1 ? smsRecord.SenderAddress : smsRecord.SenderAddress.substring(prefixEndIndex + 1);
    		
    		Integer addrStart = emailAddrMatcher.start();
    		Integer addrEnd = emailAddrMatcher.end();
    		String emailAddr = smsRecord.Message.substring(addrStart,addrEnd);
    		String text = (smsRecord.Message.substring(0,addrStart) +
    			smsRecord.Message.substring(addrEnd)).trim() +
    			'\n\nMessage was received from: ' + senderAddress +
    			'\nDate: ' + smsRecord.MsgDateTime;
    			
    		
    		
    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[]{emailAddr});
			mail.setSenderDisplayName(senderAddress);
			mail.setSubject('Message forwarding');
			mail.setPlainTextBody(text);
			Messaging.sendEmail(new Messaging.Email[]{mail});
    	}
	}
}