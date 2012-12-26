/*
 *  @description AttTransactionRefundStatus holds information about single payment transaction's refund.
 */
public virtual class AttTransactionRefundStatus {
    
    /*
    * @description A flag indicating the status of the request
    */
	public Boolean IsSuccess {get;set;}
	
    /*
    * @description Version of service
    */
    public String Version {get;set;}
    
	/*
    * @description The transaction ID for the refund
    */
    public String TransactionId {get;set;}
    
	/*
    * @description Current status of the transaction
    */
    public String TransactionStatus {get;set;}
    
	/*
    * @description Amount of the original purchase
    */
    public Decimal OriginalPurchaseAmount {get;set;}
    
	/*
    * @description Commit confirmation Id
    */
    public String CommitConfirmationId {get;set;}

    /*
     * @description Parses input json string to AttTransactionRefundStatus object.
     * @param A JSON string as responce of refund service.
     * @return parsed refund status object.
     */
	public static AttTransactionRefundStatus parse(String json) {
		return (AttTransactionRefundStatus)System.JSON.deserialize(json, AttTransactionRefundStatus.class);
	}
	
	public static testMethod void testParse() {
		String json = '{'+
		' "IsSuccess":true,'+
		' "Version":"1",'+
		' "TransactionId":"7617794175102158",'+
		' "TransactionStatus":"SUCCESSFUL",'+
		' "OriginalPurchaseAmount":"1.11",'+
		' "CommitConfirmationId":""'+
		'}';
		AttTransactionRefundStatus status = parse(json);
		System.assert(status != null);
        System.assert(status.IsSuccess);
        System.assertEquals('1', status.Version);
        System.assertEquals('7617794175102158', status.TransactionId);
        System.assertEquals('SUCCESSFUL', status.TransactionStatus);
        System.assertEquals(1.11, status.OriginalPurchaseAmount);
        System.assertEquals('', status.CommitConfirmationId);

		json = '{"TestAMissingObject": { "TestAMissingArray": [ { "TestAMissingProperty": "Some Value" } ] } }';
		status = parse(json);
		System.assert(status != null);
		System.assert(status.IsSuccess == null);
		System.assert(status.Version == null);
		System.assert(status.TransactionId == null);
		System.assert(status.TransactionStatus == null);
		System.assert(status.OriginalPurchaseAmount == null);
		System.assert(status.CommitConfirmationId == null);
	}
}