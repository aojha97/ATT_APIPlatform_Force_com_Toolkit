/*
 * @description AttMessageDeliveryStatus holds information about SMS get delivery status.
 */
public virtual class AttMessageDeliveryStatus {
    
    /*
     * @description Object containing list of AttMessageDeliveryStatus.DeliveryInfo class SMS delivery information objects
     */
    public List<DeliveryInfo> deliveryInfoList {public get; private set;}

    /*
    * @description Default constructor for AttMessageDeliveryStatus
    * @param json A JSON string as responce of get SMS delivery status service.
    */
	public AttMessageDeliveryStatus(String json) {
		DeliveryStatus rez;
		try {
			rez = (DeliveryStatus) System.JSON.deserialize(json, DeliveryStatus.class);
		} catch (Exception e) {
			throw new AttException('Cant parse response: ' + json, e);
		}
		this.deliveryInfoList = rez.deliveryInfoList.deliveryInfo;
	}
	
	private class DeliveryInfoList {
		
		private List<DeliveryInfo> deliveryInfo {get;set;}
	}
	
	/**
	 * @description Object, which contains SMS delivery information
	 */
	public class DeliveryInfo {
		
		/**
        * @description The unique identifier for the message destination
        */
		public String id {get;set;}
		
		/**
        * @description Mobile number of the receiver
        */
        public String address {get;set;}
        
		/**
        * @description Status of the SMS that is delivered
        */
        public String deliveryStatus {get;set;}		
	}
	
	private class DeliveryStatus {
		private DeliveryInfoList deliveryInfoList {get;set;}
	}
	
	// This test method should give 100% coverage
	public static testMethod void testParse() {
		String json = '{ "DeliveryInfoList":'+
		'{"DeliveryInfo":'+
		'[{ "Id" : "msg0",'+
		'"Address" : "3500000992",'+
		'"DeliveryStatus" : "DeliveredToTerminal" }] ,'+
		'"ResourceUrl": "https://api.att.com/rest/sms/2/messaging/outbox/SMSa9b192780378404c"}}';
		AttMessageDeliveryStatus result = new AttMessageDeliveryStatus(json);
		System.assert(result.deliveryInfoList[0].Id == 'msg0');
		System.assert(result.deliveryInfoList[0].Address == '3500000992');
		System.assert(result.deliveryInfoList[0].DeliveryStatus == 'DeliveredToTerminal');
		
		json = 'Incorrect json string';
		try {
			result = new AttMessageDeliveryStatus(json);
		} catch (Exception e) {}
	}
}