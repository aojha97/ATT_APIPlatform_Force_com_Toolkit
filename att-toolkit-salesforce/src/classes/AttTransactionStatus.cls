/*
 * @description AttTransactionStatus holds information about single payment transaction.
 */
public virtual class AttTransactionStatus {
	
	/*
    * @description Transaction type enumeration used in TransactionType property
    */
	public enum TransactionType {
		SUBSCRIPTION , SINGLEPAY
	}
	
	/*
    * @description Transaction status enumeration used in TransactionStatus property
    */
	public enum TransactionStatus {
		STATUS_NEW , DECLINED, SUCCESSFUL, FAILED, UNRESOLVED, CANCELLED
	}
	
	private static String TRANSACTION_STATUS_NEW = 'NEW';
	/*
    * @description Merchant channel
    */
	public String Channel {get;set;}
	
	/*
    * @description Short description of the product that was sent in the original charge request
    */
	public String Description {get;set;}
	
	/*
    * @description The transaction currency
    */
	public String TransactionCurrency {get;set;}
	
	/*
    * @description Indicates whether the type of the transaction is a SUBSCRIPTION or a one time transaction SINGLEPAY
    */
	public AttTransactionStatus.TransactionType TransactionType {get;set;}
	
	/*
    * @description Current status of the transaction
    */
	public AttTransactionStatus.TransactionStatus TransactionStatus {get;set;}
	
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
	public String TransactionId {get;set;}
	
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
    * @description Amount of transaction
    */
	public Decimal Amount {get;set;}
	
	/*
    * @description Version of service
    */
    public String Version {get;set;}
	
	/*
    * @description A flag indicating the status of the request
    */
	public Boolean IsSuccess {get;set;}
	
	/*
    * @description Original transaction identifier
    */
	public String OriginalTransactionId {get;set;}
	
	/*
    * @description Is auto committed
    */
	public String IsAutoCommitted {get;set;}
	
    /*
     * @description Parses input json string to AttTransactionStatus object.
     * @param A JSON string as responce of get transaction status service.
     * @return parsed transaction status object.
     */
	public static AttTransactionStatus parse(String json) {
		Map<String, Object> fieldMap = (Map<String, Object>)System.JSON.deserializeUntyped(json);
		
        AttTransactionStatus status = new AttTransactionStatus();
		status.Channel = (String)fieldMap.get('Channel');
		status.Description = (String)fieldMap.get('Description');
		status.TransactionCurrency = (String)fieldMap.get('Currency');
		status.TransactionType = getTransactionTypeByString((String)fieldMap.get('TransactionType'));
		status.TransactionStatus = getTransactionStatusByString((String)fieldMap.get('TransactionStatus'));
		status.ConsumerId = (String)fieldMap.get('ConsumerId');
		status.MerchantTransactionId = (String)fieldMap.get('MerchantTransactionId');
		status.MerchantApplicationId = (String)fieldMap.get('MerchantApplicationId');
		status.TransactionId = (String)fieldMap.get('TransactionId');
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
        status.OriginalTransactionId = (String)fieldMap.get('OriginalTransactionId');
        status.IsAutoCommitted = (String)fieldMap.get('IsAutoCommitted');
		return status;
	}
	
    /*
     * @description Converts string value to AttTransactionStatus.TransactionType enum value.
     */
	private static AttTransactionStatus.TransactionType getTransactionTypeByString(String value) {
		for (AttTransactionStatus.TransactionType type : AttTransactionStatus.TransactionType.values()) {
			if (type.name().equals(value)) {
                return type;
			}
		}
		return null;
	}
	
    /*
     * @description Converts string value to AttTransactionStatus.TransactionStatus enum value.
     */
	private static AttTransactionStatus.TransactionStatus getTransactionStatusByString(String value) {
		for (AttTransactionStatus.TransactionStatus type : AttTransactionStatus.TransactionStatus.values()) {
			if (type.name().equals(value)) {
                return type;
			} else if (TRANSACTION_STATUS_NEW.equals(value)) {
				return AttTransactionStatus.TransactionStatus.STATUS_NEW;
			}
		}
		return null;
	}
	
	
	public static testMethod void testParse() {
		String json = '{'+
		'"Channel":"MOBILE_WEB",'+
		'"Description":"T20120104223242088",'+
		'"Currency":"USD",'+
		'"TransactionType":"SINGLEPAY",'+
		'"TransactionStatus":"SUCCESSFUL",'+
		'"ConsumerId":"7569ad74-e2e1-4c1e-9f49-455cdccfa315",'+
		'"MerchantTransactionId":"T20120104223242088",'+
		'"MerchantApplicationId":"79b33cf0ddf375044d6b6dada43f7d10",'+
		'"TransactionId":"3013735686002133",'+
		'"ContentCategory":"1",'+
		'"MerchantProductId":"P20120104223242088",'+
		'"MerchantId":"6729bc8a-4a4c-4975-b75c-769b7d6c6cd3",'+
		'"Amount":"1.42",'+
		'"Version":"1",'+
		'"IsSuccess":"true",'+
		'"OriginalTransactionId":"oTrId00001",'+
        '"IsAutoCommitted":"true"'+
		'}';
		AttTransactionStatus status = parse(json);
		System.assert(status != null);
        System.assertEquals('MOBILE_WEB', status.Channel);
        System.assertEquals('T20120104223242088', status.Description);
        System.assertEquals(AttTransactionStatus.TransactionType.SINGLEPAY, status.TransactionType);
        System.assertEquals(AttTransactionStatus.TransactionStatus.SUCCESSFUL, status.TransactionStatus);
        System.assertEquals('7569ad74-e2e1-4c1e-9f49-455cdccfa315', status.ConsumerId);
        System.assertEquals('T20120104223242088', status.MerchantTransactionId);
        System.assertEquals('79b33cf0ddf375044d6b6dada43f7d10', status.MerchantApplicationId);
        System.assertEquals('3013735686002133', status.TransactionId);
        System.assertEquals(1, status.ContentCategory);
        System.assertEquals('P20120104223242088', status.MerchantProductId);
        System.assertEquals('6729bc8a-4a4c-4975-b75c-769b7d6c6cd3', status.MerchantId);
        System.assertEquals(1.42, status.Amount);
        System.assertEquals('1', status.Version);
        System.assertEquals(true, status.IsSuccess);
        System.assertEquals('oTrId00001', status.OriginalTransactionId);
        System.assertEquals('true', status.IsAutoCommitted);

		json = '{"TestAMissingObject": { "TestAMissingArray": [ { "TestAMissingProperty": "Some Value" } ] } }';
		AttTransactionStatus objRoot = parse(json);
		System.assert(objRoot != null);
		System.assert(objRoot.Channel == null);
		System.assert(objRoot.Description == null);
		System.assert(objRoot.TransactionCurrency == null);
		System.assert(objRoot.TransactionType == null);
		System.assert(objRoot.TransactionStatus == null);
		System.assert(objRoot.ConsumerId == null);
		System.assert(objRoot.MerchantTransactionId == null);
		System.assert(objRoot.MerchantApplicationId == null);
		System.assert(objRoot.TransactionId == null);
		System.assert(objRoot.ContentCategory == null);
		System.assert(objRoot.MerchantProductId == null);
		System.assert(objRoot.MerchantId == null);
		System.assert(objRoot.Amount == null);
		System.assert(objRoot.Version == null);
		System.assert(objRoot.IsSuccess == null);
		System.assert(objRoot.OriginalTransactionId == null);
        System.assert(objRoot.IsAutoCommitted == null);
    }

    public static testmethod void testGetTransactionStatusAndType() {
        AttTransactionStatus.TransactionType type = AttTransactionStatus.getTransactionTypeByString('wrong_value');
        System.assertEquals(null, type);

        type = AttTransactionStatus.getTransactionTypeByString('SINGLEPAY');
        System.assertEquals(AttTransactionStatus.TransactionType.SINGLEPAY, type);

        AttTransactionStatus.TransactionStatus status = AttTransactionStatus.getTransactionStatusByString('NEW');
        System.assertEquals(AttTransactionStatus.TransactionStatus.STATUS_NEW, status);

        status = AttTransactionStatus.getTransactionStatusByString('CANCELLED');
        System.assertEquals(AttTransactionStatus.TransactionStatus.CANCELLED, status);

        status = AttTransactionStatus.getTransactionStatusByString('wrong_value');
        System.assertEquals(null, status);
    }
}