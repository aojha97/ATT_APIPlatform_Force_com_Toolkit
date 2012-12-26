@RestResource(urlMapping='/MMSInboxCallback')
global class DemoMMSInboxCallback {

	/**
	 * Inhirite AttMMSCallbackProcessor and provide implementation of processMessage(AttMMS mms)
	 * that forward received MMS as email 
	 */
	public class MMSCallbackProcessor extends AttMMSCallbackProcessor {
		public override void processMessage(AttMMS mms) {
			String forwardAddress = null;
			for (AttAttachment att : mms.attachments) {
				if (att.mimeType == 'text/plain') {
					Matcher emailAddrMatcher = DemoUtils.EMAIL_REGEXP_PATTERN.matcher(att.content.toString());	
					if (emailAddrMatcher.find()) {
						forwardAddress = emailAddrMatcher.group(0).trim();
					}	
				}
			}
			
			if (forwardAddress != null) {
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setToAddresses(new String[]{forwardAddress});
				mail.setSenderDisplayName('MMS-to-email forwarding');
				mail.setSubject('MMS from: ' + mms.phoneNumber);
				
				String body = 'Attachments:\n';
				Messaging.EmailFileAttachment[] attachmentsList = new Messaging.EmailFileAttachment[]{};
				for (AttAttachment att : mms.attachments) {
					Messaging.EmailFileAttachment eatt = new Messaging.EmailFileAttachment();
					eatt.setFileName(att.fileName);
					eatt.setBody(att.content);
					eatt.setContentType(att.mimeType);
					attachmentsList.add(eatt);
					body += att.fileName + ' ('+ att.mimeType +')\n';
				}
				mail.setFileAttachments(attachmentsList);
				
				mail.setPlainTextBody(body);
				Messaging.sendEmail(new Messaging.Email[]{mail});
			} else {
				throw new AttException('Email address to forward doesnt present in MMS');
			}
		}
	}

	@HttpPost
    global static void doPost() {
    	try {
    		//Call 
    		new MMSCallbackProcessor();
    	} catch (Exception e) {
    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    		mail.setToAddresses(new String[]{'imykhailov@exadel.com'});
			mail.setSenderDisplayName('MMMMMMMMMMMMMSSSSSSSSSS');
			mail.setSubject('MMS error');
			
			RestRequest req = RestContext.request;
			String httpBody = req.requestBody.toString();
			
			mail.setPlainTextBody('ERROR: ' + e  + '\n\n\nOriginal body:\n' + httpBody + '\n\n==========Header:\n' + req.headers);
			Messaging.sendEmail(new Messaging.Email[]{mail});
    	}
    }
    
}