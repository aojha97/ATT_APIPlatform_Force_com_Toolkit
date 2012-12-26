/**
* @description Base class for SMS and MMS sending status. Holds info about message after sending.
*/
public virtual class BaseOutboxStatus {
	
	/**
     * @description A unique identifier for the message.
     */
	public String Id {get;set;}
	
	/**
     * @description The URI used to obtain network delivery status of the sent message.
     */
	public String resourceUrl {get; set;}
	
	/*
     * @description Default constructor for BaseOutboxStatus.
     * @param id unique identifier for the message.
     * @param resourceUrl URI used to obtain network delivery status of the sent message.
     */
	public BaseOutboxStatus(String id, String resourceUrl) {
   		this.Id = id;
   		this.resourceUrl = resourceUrl;
	}
	
	protected BaseOutboxStatus(String json) {
		//Parse response using data objects 
		OutboxStatus rez;
		try {
			rez = (OutboxStatus) System.JSON.deserialize(json, OutboxStatus.class);
		} catch (Exception e) {
			throw new AttException('Cant parse response: ' + json, e);
		}
		//Check that all required informatino is received
		if (rez.id == null) throw new AttException('Responce doesnt contain message id: ' + json);
		if (rez.resourceReference == null) throw new AttException('Responce doesnt contain reference: ' + json);
		
		//Fill fields of current class
		this.id = rez.id;
		this.resourceUrl = rez.resourceReference.resourceUrl;		
	}
	
	/**
	 * DTO objects that reflect AT&T responce structure
	 */
	private class ResourceReference {
		private String resourceUrl {get;set;}	
	}
	
	/**
	 * DTO objects that reflect AT&T responce structure
	 */
	private class OutboxStatus {
		private String id {get; private set;}
		private ResourceReference resourceReference {get; private set;}
	}
}