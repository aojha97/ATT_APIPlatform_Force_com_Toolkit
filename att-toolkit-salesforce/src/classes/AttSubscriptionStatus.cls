/*
 * @description AttSubscriptionStatus holds information about subscription payment status.
 */
public virtual class AttSubscriptionStatus {
	
	/*
    * @description Subscription type enumeration used in SubscriptionType property
    */
	public enum SubscriptionType {
		SUBSCRIPTION , SINGLEPAY, CONSUMPTION
	}
	
	/*
    * @description Subscription status enumeration used in SubscriptionStatus property
    */    
	public enum SubscriptionStatus {
		STATUS_NEW , DECLINED, SUCCESSFUL, FAILED, UNRESOLVED, CANCELLED
	}
	
	private static String SUBSCRIPTION_STATUS_NEW = 'NEW';

    /*
    * @description Version of service
    */
	public String Version {get;set;}
	
	/*
    * @description A flag indicating the status of the request
    */
    public Boolean IsSuccess {get;set;}
	
    /*
    * @description Amount of subscription transaction
    */
    public Decimal Amount {get;set;}
	
    /*
    * @description Merchant channel
    */
    public String Channel {get;set;}
	
    /*
    * @description Short description of the product that was sent in the original charge request
    */
    public String Description {get;set;}
	
    /*
    * @description Subscription currency
    */
    public String SubscriptionCurrency {get;set;}
	
    /*
    * @description The type of the subscription transaction
    */
    public AttSubscriptionStatus.SubscriptionType SubscriptionType {get;set;}
	
    /*
    * @description Current status of the subscription transaction
    */
    public AttSubscriptionStatus.SubscriptionStatus SubscriptionStatus {get;set;}
	
    /*
    * @description The unique user id generated in the payment system representing a unique subscriber
    */
    public String ConsumerId {get;set;}
	
    /*
    * @description Original Transaction Id that was generated and sent by the merchant application in the original charge request
    */
    public String MerchantTransactionId {get;set;}
	
    /*
    * @description Merchant application identifier, from the AT&T Payment system, that initiated the payment transaction
    */
    public String MerchantApplicationId {get;set;}
	
    /*
    * @description Unique Id that was generated for the original charge request
    */
    public String SubscriptionId {get;set;}
	
    /*
    * @description The original transaction id
    */
    public String OriginalTransactionId {get;set;}
	
    /*
    * @description Content Category that was sent in the original charge request
    */
    public Integer ContentCategory {get;set;}
	
    /*
    * @description Product Id, from the merchant, which was sent in the orginal charge request
    */
    public String MerchantProductId {get;set;}
	
    /*
    * @description Merchant identifier, from the AT&T Payment system, that initiated the payment transaction
    */
    public String MerchantId {get;set;}
	
    /*
    * @description Original subscription ID that this subscription is associated with
    */
    public String MerchantSubscriptionId {get;set;}
	
    /*
    * @description The number of periods that pass between renewals
    */
    public String SubscriptionPeriodAmount {get;set;}
	
    /*
    * @description The number of times the subscription is renewed
    */
    public String SubscriptionRecurrences {get;set;}
	
    /*
    * @description Subscription Period that was sent in the original charge request
    */
    public String SubscriptionPeriod {get;set;}
	
    /*
    * @description Is auto committed
    */
    public String IsAutoCommitted {get;set;}
	
	/*
    * @description Default constructor
    */
	public AttSubscriptionStatus() {
	}
	
	/*
     * @description Parses input json string to AttSubscriptionStatus object.
     * @param json A JSON string as responce of get subscription transaction status service.
     * @return parsed subscription transaction status object.
     */
	public static AttSubscriptionStatus parse(String json) {
		Map<String, Object> fieldMap = (Map<String, Object>)System.JSON.deserializeUntyped(json);
		
        AttSubscriptionStatus status = new AttSubscriptionStatus();
		status.Channel = (String)fieldMap.get('Channel');
		status.Description = (String)fieldMap.get('Description');
		status.SubscriptionCurrency = (String)fieldMap.get('Currency');
		status.SubscriptionType = getSubscriptionTypeByString((String)fieldMap.get('SubscriptionType'));
		status.SubscriptionStatus = getSubscriptionStatusByString((String)fieldMap.get('SubscriptionStatus'));
		status.ConsumerId = (String)fieldMap.get('ConsumerId');
		status.MerchantTransactionId = (String)fieldMap.get('MerchantTransactionId');
		status.MerchantApplicationId = (String)fieldMap.get('MerchantApplicationId');
		status.SubscriptionId = (String)fieldMap.get('SubscriptionId');
		status.ContentCategory = Integer.valueOf(fieldMap.get('ContentCategory'));
		status.MerchantProductId = (String)fieldMap.get('MerchantProductId');
		status.MerchantId = (String)fieldMap.get('MerchantId');
		if (fieldMap.get('Amount') != null) {
			status.Amount = Decimal.valueOf((String)fieldMap.get('Amount'));
		}
		status.Version = (String)fieldMap.get('Version');
		if (fieldMap.get('IsSuccess') != null) {
			status.IsSuccess = Boolean.valueOf(fieldMap.get('IsSuccess'));
		}		
		status.IsAutoCommitted = (String)fieldMap.get('IsAutoCommitted');
		status.SubscriptionPeriod = (String)fieldMap.get('SubscriptionPeriod');
		status.SubscriptionRecurrences = (String)fieldMap.get('SubscriptionRecurrences');
		status.SubscriptionPeriodAmount = (String)fieldMap.get('SubscriptionPeriodAmount');
		status.MerchantSubscriptionId = (String)fieldMap.get('MerchantSubscriptionId');
		status.OriginalTransactionId = (String)fieldMap.get('OriginalTransactionId');
		return status;
	}
	
	private static AttSubscriptionStatus.SubscriptionType getSubscriptionTypeByString(String value) {
		for (AttSubscriptionStatus.SubscriptionType type : AttSubscriptionStatus.SubscriptionType.values()) {
			if (type.name().equals(value)) {
                return type;
			}
		}
		return null;
	}
	
	private static AttSubscriptionStatus.SubscriptionStatus getSubscriptionStatusByString(String value) {
		for (AttSubscriptionStatus.SubscriptionStatus type : AttSubscriptionStatus.SubscriptionStatus.values()) {
			if (type.name().equals(value)) {
                return type;
			} else if (SUBSCRIPTION_STATUS_NEW.equals(value)) {
				return AttSubscriptionStatus.SubscriptionStatus.STATUS_NEW;
			}
		}
		return null;
	}
	
	static testMethod void testParse() {
		String json = '{ '+
		    '"Version": "1",'+
		    '"IsSuccess": "true",'+
		    '"Amount": "1.35",'+
		    '"Channel": "MOBILE_WEB",'+
		    '"Description": "RECUR",'+
		    '"Currency": "USD",'+
		    '"SubscriptionType": "SUBSCRIPTION",'+
		    '"SubscriptionStatus": "SUCCESSFUL",'+
		    '"ConsumerId": "08660eb2-c9c4-48a6-93ea-1c440fa826e4",'+
		    '"MerchantTransactionId": "T20120619152559466",'+
		    '"MerchantApplicationId": "029c091549fd96788537c5c5cbbb94a3",'+
		    '"SubscriptionId": "6108486931402157",'+
		    '"OriginalTransactionId": "oidrId12345",'+
		    '"ContentCategory": "1",'+
		    '"MerchantProductId": "P20120619152559466",'+
		    '"MerchantId": "5f13fd54-b4ef-4574-9043-b2a0180b4a90",'+
		    '"MerchantSubscriptionId": "619152559466",'+
		    '"SubscriptionPeriodAmount": "1",'+
		    '"SubscriptionRecurrences": "99999",'+
		    '"SubscriptionPeriod": "MONTHLY",'+
		    '"IsAutoCommitted": "false"'+
			'}';
		AttSubscriptionStatus status = parse(json);
		System.assert(status != null);
		System.assertEquals('1', status.Version);
		System.assertEquals(true, status.IsSuccess);
		System.assertEquals(1.35, status.Amount);
		System.assertEquals('MOBILE_WEB', status.Channel);
		System.assertEquals('RECUR', status.Description);
		System.assertEquals('USD', status.SubscriptionCurrency);
		System.assertEquals(AttSubscriptionStatus.SubscriptionType.SUBSCRIPTION, status.SubscriptionType);
		System.assertEquals(AttSubscriptionStatus.SubscriptionStatus.SUCCESSFUL, status.SubscriptionStatus);
		System.assertEquals('08660eb2-c9c4-48a6-93ea-1c440fa826e4', status.ConsumerId);
		System.assertEquals('T20120619152559466', status.MerchantTransactionId);
		System.assertEquals('029c091549fd96788537c5c5cbbb94a3', status.MerchantApplicationId);
		System.assertEquals('6108486931402157', status.SubscriptionId);
		System.assertEquals('oidrId12345', status.OriginalTransactionId);
		System.assertEquals(1, status.ContentCategory);
		System.assertEquals('P20120619152559466', status.MerchantProductId);
		System.assertEquals('5f13fd54-b4ef-4574-9043-b2a0180b4a90', status.MerchantId);
		System.assertEquals('619152559466', status.MerchantSubscriptionId);
		System.assertEquals('1', status.SubscriptionPeriodAmount);
		System.assertEquals('99999', status.SubscriptionRecurrences);
		System.assertEquals('MONTHLY', status.SubscriptionPeriod);
		System.assertEquals('false', status.IsAutoCommitted);
	
		
		json = '{"TestAMissingObject": { "TestAMissingArray": [ { "TestAMissingProperty": "Some Value" } ] } }';
		AttSubscriptionStatus objRoot = parse(json);
		System.assert(objRoot != null);
		System.assert(objRoot.Version == null);
		System.assert(objRoot.IsSuccess == null);
		System.assert(objRoot.Amount == null);
		System.assert(objRoot.Channel == null);
		System.assert(objRoot.Description == null);
		System.assert(objRoot.SubscriptionCurrency == null);
		System.assert(objRoot.SubscriptionType == null);
		System.assert(objRoot.SubscriptionStatus == null);
		System.assert(objRoot.ConsumerId == null);
		System.assert(objRoot.MerchantTransactionId == null);
		System.assert(objRoot.MerchantApplicationId == null);
		System.assert(objRoot.SubscriptionId == null);
		System.assert(objRoot.OriginalTransactionId == null);		
		System.assert(objRoot.ContentCategory == null);
		System.assert(objRoot.MerchantProductId == null);
		System.assert(objRoot.MerchantId == null);
		System.assert(objRoot.MerchantSubscriptionId == null);
		System.assert(objRoot.SubscriptionPeriodAmount == null);
		System.assert(objRoot.SubscriptionRecurrences == null);
		System.assert(objRoot.SubscriptionPeriod == null);
		System.assert(objRoot.IsAutoCommitted == null);
	}
	
	public static testmethod void testGetSubscriptionStatusAndType() {
        AttSubscriptionStatus.SubscriptionType type = AttSubscriptionStatus.getSubscriptionTypeByString('wrong_value');
        System.assertEquals(null, type);

        type = AttSubscriptionStatus.getSubscriptionTypeByString('CONSUMPTION');
        System.assertEquals(AttSubscriptionStatus.SubscriptionType.CONSUMPTION, type);

        AttSubscriptionStatus.SubscriptionStatus status = AttSubscriptionStatus.getSubscriptionStatusByString('NEW');
        System.assertEquals(AttSubscriptionStatus.SubscriptionStatus.STATUS_NEW, status);

        status = AttSubscriptionStatus.getSubscriptionStatusByString('CANCELLED');
        System.assertEquals(AttSubscriptionStatus.SubscriptionStatus.CANCELLED, status);

        status = AttSubscriptionStatus.getSubscriptionStatusByString('wrong_value');
        System.assertEquals(null, status);
    }
}