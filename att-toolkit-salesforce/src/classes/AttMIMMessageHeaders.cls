/**
 * @description MIM Headers.
 */
public virtual class AttMIMMessageHeaders {

	/**
 	 * @description Messages headers.
 	 */
	public MessageHeadersList messageHeadersList {get; set;}
	
	/**
	 * @description Object that contains the Headers, IndexCursor, and HeaderCount parameter values.
	 */
	public class MessageHeadersList {
		
		/**
		 * @description Headers list.
		 */
		public List<Headers> headers {get; set;}
		
		/**
		 * @description Specifies the number of headers.
		 */
		public Integer headerCount {get; set;}
		
		/**
		 * @description Specifies the start of the next block of messages.
		 */
		public String indexCursor {get; set;} 
	}
	
	/**
	 * @description Object that contains header data.
	 */
	public class Headers {
		
		/**
		 * @description Specifies the unique identifier for the message.
		 */		
		public String messageId {get; set;}
		
		/**
		 * @description Specifies the sender for the message.
		 */				
		public String fromAddress {get; set;}
		
		/**
		 * @description Specifies the recipients for the message.
		 */		
		public List<String> to {get; set;}
		
		/**
		 * @description Specifies the subject for the message.
		 */		
		public String subject {get; set;}
		
		/**
		 * @description Specifies the date and time that the message is received.
		 */		
		public Datetime received {get; set;}
		
		/**
		 * @description Specifies the text portion of the message.
		 */		
		public String text {get; set;}
		
		/**
		 * @description Indicates that the message is a favorite.
		 */		
		public Boolean favorite {get; set;}
		
		/**
		 * @description Indicates that the message has been read.
		 */		
		public Boolean read {get; set;}
		
		/**
		 * @description Specifies the type for the message.
		 */		
		public String messageType {get; set;}
		
		/**
		 * @description Specifies the direction for the message.
		 */		
		public String direction {get; set;}
		
		/**
		 * @description MMS content list.
		 */				
		public List<MmsContent> mmsContent {get; set; }
	}
	
	/**
	 * @description Specifies the MMS message content.
	 */
	public class MmsContent {
		
		/**
		 * @description Specifies the content type identifier for the message.
		 */		
		public String contentType {get; set;}
		
		/**
		 * @description Specifies the content name for the message.
		 */		
		public String contentName {get; set;}
		
		/**
		 * @description Specifies the part number content identifier for the message.
		 */		
		public String partNumber {get; set;}
	}

	/**
	 * @description Parses JSON string into class fields.
	 * @param json string with AT&T MIM Headers service JSON response data.
	 * @return instance of AttMIMMessageHeaders class with data from JSON string.
	 */
	public static AttMIMMessageHeaders parse(String json) {
		json = json.replace('"From"', '"FromAddress"').replace('"Type"', '"MessageType"');
		return (AttMIMMessageHeaders) System.JSON.deserialize(json, AttMIMMessageHeaders.class);
	}
}