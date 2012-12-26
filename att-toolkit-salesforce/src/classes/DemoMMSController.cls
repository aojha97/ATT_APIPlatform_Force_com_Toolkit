public class DemoMMSController {
    
    public String sendMmsDebugBody {get; set;}
    
    public String phoneNumber { get; set; } 
    
    public String messageText { get; set; }   
        
    public String inboxDebugBody { get; set; } 
        
    public AttMMSOutboxStatus answerMMSSend { get; set; }
    
    public String deliveryDebugBody { get; set; }
    
    public String numberOfMessages { get; set; }
    
    public String numberOfPendingMessages { get; set; }
    
    public List <AttSMSInboxStatus.InboundSmsMessage> inboundMessageList { get; set; }
    
    public String mmsForCheckId { get; set; }    
    public AttMMSOutboxStatus deliveryCheckForMms { get; set; }
    public AttMessageDeliveryStatus deliveryStatus { get; set; }
        
    public boolean isStatusTableVisible { get; set; }  
    
    public boolean isInboxTableVisible { get; set; }
    
    public boolean isSendErrorsVisible { get; set; }
    
    public boolean isGetStatusErrorsVisible { get; set; }
    
    public boolean isInboxErrorsVisible { get; set; }
    
    public String fileName1 {get; set;}
    public transient Blob attachment1 { get; set; }    
    public String fileName2 {get; set;}
    public transient Blob attachment2 { get; set; }    
    public String fileName3 {get; set;}
    public transient Blob attachment3 { get; set; }    
    public String fileName4 {get; set;}
    public transient Blob attachment4 { get; set; }
    
    public AttClientCredentialsAuthorization auth { get; set; }
    
    public DemoMMSController () {
        init();
    }
    
    private void init() {
        phoneNumber = '14258028620';
        isStatusTableVisible = false;
        isInboxTableVisible = false;
        
        auth = new AttClientCredentialsAuthorization(ServiceConstants.ScopeType.MMS);
    }
   
    
    public void testAttServiceMMSSend () {
    	try {
	        AttMMSOutbox box = new AttMMSOutbox(auth);
	        AttMMS mms  = new AttMMS();
	        addAttachmentIfExist(mms, attachment1, fileName1);
	        addAttachmentIfExist(mms, attachment2, fileName2);
	        addAttachmentIfExist(mms, attachment3, fileName3);
	        addAttachmentIfExist(mms, attachment4, fileName4);
	        mms.phoneNumber = phoneNumber;
	        mms.subject = messageText;
        
            answerMMSSend = box.sendMessage(mms);
        } catch (AttException ex) {
            isSendErrorsVisible = true;
            isGetStatusErrorsVisible = false;
            isInboxErrorsVisible = false;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);            
            return;
        }        
        
        DemoMMS__c mmsp = new DemoMMS__c();
        mmsp.Name = answerMMSSend.Id;
        mmsp.title__c = messageText;
        insert mmsp;
         
        sendMmsDebugBody = 'phoneNumber=' + phoneNumber + 
                '\r\nmessageText=' + messageText + 
                '\r\n\r\nserverAnswer=' + answerMMSSend;        
    }
    
    private void addAttachmentIfExist(AttMMS mms, Blob content, String fileName) {
    	if (content!=null && fileName!=null && fileName.trim().length()>0) {
    		AttAttachment attachment = new AttAttachment(content, fileName, AttAttachment.getMimeTypeByFileName(fileName));
			mms.attachments.add(attachment);
    	}
    }
    
    public void testDeliveryStatus() {
        try {
        	AttMMSOutbox box = new AttMMSOutbox(auth);
        	deliveryCheckForMms = box.restoreOutboxStatusByMMSId(mmsForCheckId);
            deliveryStatus = deliveryCheckForMms.getDeliveryStatus();
        } catch (AttException ex) {
            isSendErrorsVisible = false;
            isGetStatusErrorsVisible = true;
            isInboxErrorsVisible = false;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);            
            return; 
        } 
        isStatusTableVisible = true;        
    }
    
    public void clearSentMms() {
    	DemoMMS__c[] mmss = [select Name from DemoMMS__c];
    	delete mmss;
    }
    
    public List<DemoMMS__c> sendedMMS {get {
    	return [SELECT Name, title__c from DemoMMS__c];
    }}
   
}