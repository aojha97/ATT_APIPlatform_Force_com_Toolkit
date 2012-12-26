public class DemoSpeechToEmailController {
	// Supported file extensions
	private static final String UPLOADED_FILE_TYPE_WAV = '.wav';
    private static final String UPLOADED_FILE_TYPE_AMR = '.amr';
    
    // Validation patterns for phone number and email
    private final Pattern emailPattern = Pattern.compile('^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$');
    private final Pattern phoneNumberPattern = Pattern.compile('^\\+{0,1}[0-9]+$');
    
    // Report messages
    public static final String FILE_NOT_SPECIFIED = 'Please select file before send request...';
    public static final String UNSUPPORTED_FILE_FORMAT = 'Speech service support only \'wav\' and \'amr\' audio files...';
    public static final String TOO_BIG_FILE = 'File size must be not greater than 3,000,000 bytes...';
    public static final String INVALID_EMAIL_AND_PHONE_NUMBER = 'E-mail or phone number and input file are required...';
    public static final String INVALID_EMAIL_OR_PHONE_NUMBER_FORMAT = 'Email or phone format is invalid. Please check it and reopen file...';
    
    public transient String filePath {get; set;}
    public transient Blob fileBlob {get; set;}
    
    public String targetAddr {get; set;}
    
    public AttClientCredentialsAuthorization auth { get; set; }
    
    private final System.Type TEST_CLASS = TestDemoSpeechToEmailController.class;
    
    public DemoSpeechToEmailController() {
    	targetAddr = '';
    	auth = new AttClientCredentialsAuthorization(new ServiceConstants.ScopeType[] {ServiceConstants.ScopeType.SPEECH, ServiceConstants.ScopeType.SMS});
    }

    public void testAttServiceSpeech() {
		if (targetAddr == null || targetAddr.length() == 0) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,INVALID_EMAIL_AND_PHONE_NUMBER);
    		ApexPages.addMessage(msg);
    		return;
		}

    	boolean sendOnEmail = emailPattern.matcher(targetAddr).matches();
    	boolean sendToPhone = phoneNumberPattern.matcher(targetAddr).matches();

		if (!sendOnEmail && !sendToPhone) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,INVALID_EMAIL_OR_PHONE_NUMBER_FORMAT);
    		ApexPages.addMessage(msg);
    		return;
		}
    	
    	if (filePath == null){
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,FILE_NOT_SPECIFIED);
    		ApexPages.addMessage(msg);
    		return;
    	}

		AttSpeech.FileType fileType;
    	String fileNameReal = filePath.toLowerCase();
		if (fileNameReal.endsWith(UPLOADED_FILE_TYPE_WAV)) {
			fileType = AttSpeech.FileType.WAV;
		} else if (fileNameReal.endsWith(UPLOADED_FILE_TYPE_AMR)) {
			fileType = AttSpeech.FileType.AMR;
		} else {
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,UNSUPPORTED_FILE_FORMAT);
    		ApexPages.addMessage(msg);
    		return;
		}
		
		if (fileBlob.size() > 3000000) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,TOO_BIG_FILE));
    		return;
		}
    	
    	AttSpeech speech = new AttSpeech(auth);
    	speech.fileType = fileType;
    	speech.fileBlob = fileBlob;

    	String recognitionResult;
    	try {
    		recognitionResult = speech.convert().Recognition.NBest[0].ResultText;
    	}catch(Exception ex) {
    		System.debug(Logginglevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());    		    		
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));    		
    		return;
    	}
    	
    	String message = '';
    	if (sendOnEmail && sendOnEmail(recognitionResult)) {
			message = ' has been successfully sent on ' + targetAddr + ' by e-mail';
    	} else if (sendToPhone && sendToPhone(recognitionResult)) {
	        message = ' has been successfully sent to ' + targetAddr + ' by SMS';
    	} 
    	
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Recognized text "' + recognitionResult + '"' + message);
        ApexPages.addMessage(msg);
	}
	
	private boolean sendOnEmail(String recognitionResult) {
		boolean sendSuccess = false;
		try {
    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[]{targetAddr});
			mail.setSenderDisplayName('AT&T Speech To Email Demo');
			mail.setSubject('Sound to speech recognition result');
			mail.setPlainTextBody(recognitionResult);
			
			Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(new Messaging.Email[]{mail});
			sendSuccess = true;
			for(Messaging.SendEmailResult sendResult : sendResults) {
				if (!sendResult.isSuccess()) {
					sendSuccess = false;
					for(Messaging.SendEmailError sendError : sendResult.getErrors()) {
	    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, sendError.getMessage()));
					}
				}
			}
		} catch (Exception ex) {
			sendSuccess = false;
		}
		
		return sendSuccess;
	}

	private boolean sendToPhone(String recognitionResult) {
		boolean sendSuccess = false;
        try {
	        AttSMS sms  = new AttSMS();
	        sms.phoneNumber = targetAddr;
	        sms.messageText = recognitionResult;
	        
    		AttSMSOutbox smsOutbox = new AttSMSOutbox(auth);
	        AttSMSOutboxStatus answerSMSSend;
       		answerSMSSend = smsOutbox.sendMessage(sms);
       		sendSuccess = true;
        } catch (AttException ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);            
			sendSuccess = false;
		}
		
		return sendSuccess;
	}
}