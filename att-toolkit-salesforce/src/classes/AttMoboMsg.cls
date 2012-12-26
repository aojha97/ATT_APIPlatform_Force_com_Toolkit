/**
 *@description Contains information about message for AttMoboClient.sendMessage() method
 */
public class AttMoboMsg {

	/**
	 * @description Contains list of destination addresses (phone number, short code, email address) with corresponding prefix.
	 * At least one address must be specified.
	 */
	public List<String> dstAddresses { get; set; }
	
	/**
	 * @description Specifies that all recipients can see each other in copies.
	 * Optional parameter, may be not null only if two or more different addresses are specified.
	 */
	public Boolean isGroup { get; set; }
	
	/**
	 * @description Specifies subject for message. Optional parameter, if not null - message will be sent only as MMS or EMAIL
	 */
	public String subject { get; set; }
	
	/**
	 * @description Contains message text. At least one (messageText or attachments) must be specified.
	 */
	public String messageText { get; set; }
	
	/**
	 * @description Contains list of attachments. At least one (messageText or attachments) must be specified.
	 */
	public List<AttAttachment> attachments { get; set; }
	
	
	/**
	 * @description Creates new instance of AttMoboMsg with empty attachment list and all other properties are set to null.
	 */
	public AttMoboMsg() {
    	this.attachments = new List<AttAttachment>();
    }
}