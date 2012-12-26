public class DemoMoboController extends AttConsentExtWorkflow {
	
	public static final String SUCCESS_MESSAGE = 'Message has been sent successfully. Result ID: ';
	private static final Integer MAX_SUBJECT_SIZE = 512;
	private static final Integer MAX_SUMMARY_SIZE = 600 * 1024;
	
	// Validation patterns for phone number and email
    private static final Pattern emailPattern = Pattern.compile('^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$');
    private static final Pattern phoneNumberPattern = Pattern.compile('^\\+{0,1}[0-9]+$');

	// Regular expression for splitting of address string
	private static final Pattern wordSplitter = Pattern.compile('[,; ]+');
	// Stores an access token which can be used multiple times
	private AttMoboClient moboClient;

	public String targetAddresses { get; set; }
	public String subject { get; set; }
	public String messageBody { get; set; }
	public Boolean isGroup { get; set; }
	private Integer summaryAttachmentSize;
	
	public transient Blob attachment1 { get; set; }
	public transient Blob attachment2 { get; set; }
	public transient Blob attachment3 { get; set; }
	public transient Blob attachment4 { get; set; }
	
	public transient String fileName1 { get; set; }
	public transient String fileName2 { get; set; }
	public transient String fileName3 { get; set; }
	public transient String fileName4 { get; set; }
	
	private final System.Type TEST_CLASS = TestDemoMoboController.class;
	
	protected override void initialize() {
		moboClient = new AttMoboClient(auth);
		
		targetAddresses = '';
		subject = '';
		messageBody = '';
		isGroup = false;		
	}
	
	protected override ServiceConstants.ScopeType[] getConsentScope() {
		return new ServiceConstants.ScopeType[] {ServiceConstants.ScopeType.MOBO};
	}
	
	private AttMoboMsg createMessage() {		
		AttMoboMsg moboMsg = new AttMoboMsg();
		moboMsg.dstAddresses = createAddressList(targetAddresses);
		moboMsg.subject = subject;
		moboMsg.messageText = messageBody;
		moboMsg.isGroup = isGroup;
		
		summaryAttachmentSize = 0;
		addAttachmentIfExist(moboMsg, attachment1, fileName1);
		addAttachmentIfExist(moboMsg, attachment2, fileName2);
		addAttachmentIfExist(moboMsg, attachment3, fileName3);
		addAttachmentIfExist(moboMsg, attachment4, fileName4);
		if (summaryAttachmentSize > MAX_SUMMARY_SIZE) throw new AttException('Summary size of all attachment must be less then 600kb');
		
		return moboMsg;
	}
	
	private void checkMessageFields(AttMoboMsg message) {
		if (message.dstAddresses == null || message.dstAddresses.size() == 0 || message.dstAddresses.size() > 10) {
			throw new AttException('Address list is invalid');
		}
		if (String.isEmpty(message.messageText) && (message.attachments == null || message.attachments.size() == 0)) {
			throw new AttException('Message didn\'t contain text and attachments');
		}
		if (message.subject != null && message.subject.length() > MAX_SUBJECT_SIZE) {
			throw new AttException('Size of subject shouldn\'t be greater than 512 symbols');
		}
	}
	
	private void addAttachmentIfExist(AttMoboMsg msg, Blob content, String fileName) {
    	if (content!=null && fileName!=null && fileName.trim().length()>0) {
    		AttAttachment attachment = new AttAttachment(content, fileName, AttAttachment.getMimeTypeByFileName(fileName));
			msg.attachments.add(attachment);
			summaryAttachmentSize += content.size();
    	}
    }
    
	public override void execute() {
		AttMoboMsg moboMsg = createMessage();
		checkMessageFields(moboMsg);
		AttMoboSendStatus messageStatus = moboClient.sendMessage(moboMsg);
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,SUCCESS_MESSAGE + messageStatus.Id));
	}
	
	public List<String> createAddressList(String dstAddresses) {
		List<String> addressList = wordSplitter.split(dstAddresses);
		for (Integer i = 0;i < addressList.size();++i) {
			if (!emailPattern.matcher(addressList[i]).matches() && !phoneNumberPattern.matcher(addressList[i]).matches()) {
				throw new AttException('Invalid e-mail address or phone number format');
			}
			if (addressList[i].contains('@')) {
			} else {
				if (addressList[i].length() >= 3 && addressList[i].length() <= 8) {
					addressList[i] = 'short:' + addressList[i];
				} else if (addressList[i].length() > 8 && addressList[i].length() <= 12) {
					addressList[i] = 'tel:' + addressList[i];
				} else {
					throw new AttException('Invalid phone number length');
				}
			}
		}
		return addressList;
	}
}