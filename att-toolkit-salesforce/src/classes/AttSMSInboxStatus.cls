/*
 * @description AttSMSInboxStatus holds information about SMS inbox.
 */
public virtual class AttSMSInboxStatus {
		
	/*
    * @description Object, which contains inbox information
    */
	public InboundSmsMessageList inboundSmsMessageList {get;set;}	
	
	/*
    * @description InboundSmsMessageList holds information about SMS inbox list.
    */
	public class InboundSmsMessageList {
		
		/*
        * @description Object which is the list of AttSMSInboxStatus.InboundSmsMessage class oibjects
        */
        public List<InboundSmsMessage> inboundSmsMessage {get;set;}
		
        /*
        * @description The number of messages that is sent in the (batch) response
        */
        public Integer NumberOfMessagesInThisBatch { get; set; }
		
        /*
        * @description The link to https URL of the API with the message Id
        */
        public String ResourceUrl { get; set; }
		
        /*
        * @description The total number of messages pending that are yet to be retrieved from the server for the given short code
        */
        public Integer TotalNumberOfPendingMessages { get; set; }
	}
	
	/*
    * @description InboundSmsMessageList holds information about one inbox SMS
    */
	public class InboundSmsMessage {
		
        /*
        * @description Specifies the message identifier that is unique for every message returned in the list
        */
        public String MessageId { get; set; }
		
        /*
        * @description Specifies the message text
        */
        public String Message { get; set; }
		
        /*
        * @description Specifies the mobile number of the sender
        */
        public String SenderAddress { get; set; }
	}
	
	/*
     * @description Parses JSON string into class fields.
     * @param json A JSON string as responce of device capabilities service.
     * @return parsed device capabilities object.
     */
	public static AttSMSInboxStatus parse(String json) {
		AttSMSInboxStatus inboxStatus;
		try {
			inboxStatus = (AttSMSInboxStatus) System.JSON.deserialize(json, AttSMSInboxStatus.class);
		} catch (Exception e) {
			throw new AttException('Cant parse response: ' + json, e);
		}
		return inboxStatus;
	}
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{"InboundSmsMessageList": '+
		'{"InboundSmsMessage": '+
		'[{ "MessageId" : "msg0", "Message" : "Hello", "SenderAddress" : "tel:4257850159" '+
		'}], '+
		'"NumberOfMessagesInThisBatch" : "1", '+
		'"ResourceUrl" : "http://api.att.com:8080/rest/sms/2/messaging/inbox", "TotalNumberOfPendingMessages" : "0" '+
		'} '+
		'}';
		AttSMSInboxStatus result = parse(json);
		System.assert(result.InboundSmsMessageList.InboundSmsMessage.size() == 1);
		System.assert(result.InboundSmsMessageList.NumberOfMessagesInThisBatch == 1);
		System.assert(result.InboundSmsMessageList.ResourceUrl == 'http://api.att.com:8080/rest/sms/2/messaging/inbox');
		System.assert(result.InboundSmsMessageList.TotalNumberOfPendingMessages == 0);
		
		InboundSmsMessage message = result.InboundSmsMessageList.InboundSmsMessage.get(0);
		System.assert(message.MessageId == 'msg0');
		System.assert(message.Message == 'Hello');
		System.assert(message.SenderAddress == 'tel:4257850159');
		
		json = 'Incorrect json string';
		try {
			result = parse(json);
		} catch(Exception e) {}
	}
}