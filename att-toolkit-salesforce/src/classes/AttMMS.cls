/**
 * @description Represent MMS message, include phoneNumber, subject, priority and 
 *   list of attachments (see AttAttachment). 'phoneNumber' field can be
 *   sender or receiver phoneNumber depends on context. For outgoing MMS it considered 
 *   to be recipient phone number. Incoming MMS contain sender phone number in this field.
 */
public class AttMMS {
	
	/**
	 * @description Specifies destination address of the message.
	 */
	public String phoneNumber { get; set; }
       
    /**
     * @description Specifies the subject of message being sent.
     */ 
    public String subject { get; set; }
    
    /**
     * @description Specifies the priority of the message. The acceptable values for this parameter are: Default, Low, Normal, or High.
     */
    public String priority { get; set; }
    
    /**
     * @description list of attached files, see AttAttachment for details
     */ 
    public List<AttAttachment> attachments { get; set; }
    
    /**
     * @description create new MMS
     */
    public AttMMS() {
    	this.attachments = new List<AttAttachment>();
    }
}