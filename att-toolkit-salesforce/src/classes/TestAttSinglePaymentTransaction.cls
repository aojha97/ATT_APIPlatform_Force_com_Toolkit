@isTest
public class TestAttSinglePaymentTransaction {
	public static MultiStaticResourceCalloutMock mock;
	public static AttClientCredentialsAuthorization auth = TestHttpMockFactory.getCCAuthMock();
		
    public static testmethod void testStart() {
        AttSinglePaymentTransaction trans = new AttSinglePaymentTransaction(createPayload(), auth);
        TestHttpMockFactory.SingleRequestMock redirect = new TestHttpMockFactory.SingleRequestMock(302, 'OK', Blob.valueOf('test'), new Map<String, String>{
            'Location' => 'http://att.com'
        }); 
        SecurityTokenProvider tokenProvider = UtilityFactory.getSecurityTokenProvider();
        Att_Application_Security_Key__c applicationKey = tokenProvider.getApplicationKey();
        String params =  '?SignedPaymentDetail=' + 'JTdCJTIyU2lnbmVkczMzQ5NjIlN0QlN0Q' + 
                '&Signature=' + 'kczMzQ5NjIlN' + '&clientid=' + applicationKey.API_Key__c;
        
        HttpCalloutMock multimock = new TestHttpMockFactory.MultiRequestMock(new Map<String,HttpCalloutMock>{
            ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.NOTARY) =>   TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"SignedDocument": "JTdCJTIyU2lnbmVkczMzQ5NjIlN0QlN0Q","Signature": "kczMzQ5NjIlN"}'),
            ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.NEW_TRANSACTION) + params =>   redirect  
        });
        
        Test.setMock(HttpCalloutMock.class, multimock);
        PageReference reference = trans.start();
        System.assertEquals('http://att.com', reference.getUrl());
    }
    
    private static testmethod void testHandleRedirectUrl() {
        ApexPages.currentPage().getParameters().put('success', 'true');
        ApexPages.currentPage().getParameters().put('TransactionAuthCode', 'testTransactionAuthCode');
        String transactionAuthCode = AttSinglePaymentTransaction.handleRedirectUrlForAuthorizationCode();
        System.assertEquals('testTransactionAuthCode', transactionAuthCode);
        
        ApexPages.currentPage().getParameters().put('success', 'false');
        ApexPages.currentPage().getParameters().put('faultCode', 'testFaultCode');
        ApexPages.currentPage().getParameters().put('faultDescription', 'testFaultDescription');
        ApexPages.currentPage().getParameters().put('faultMessage', 'testFaultMessage');
        
        try {
            AttSinglePaymentTransaction.handleRedirectUrlForAuthorizationCode();
        } catch (AttException ex) {
            System.assertEquals('Fault code: testFaultCode Fault Description: testFaultDescription Fault Message: testFaultMessage', ex.getMessage());
        }        
    }


    public static testmethod void testGetStatusByAuthorizationCode() { 
    	Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(createJsonResponse()));
    	
        AttSinglePaymentTransaction trans = new AttSinglePaymentTransaction(createPayload(), auth);        

        AttTransactionStatus status = trans.getStatusByAuthorizationCode('1111');
        checkStatus(status);        
        
        try {
            status = trans.getStatusByAuthorizationCode('');
        } catch (AttException ex) {
            System.assertEquals('Authorization Code must be specified.', ex.getMessage());
        }  
    }

    public static testmethod void testGetStatusByMerchantTransactionId() {
    	Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(createJsonResponse()));
    	
        AttSinglePaymentTransaction trans = new AttSinglePaymentTransaction(createPayload(), auth);
       
        AttTransactionStatus status = trans.getStatusByMerchantTransactionId();
        checkStatus(status);
        
        AttPayload payload = createPayload();
        payload.MerchantTransactionId = null;
        trans = new AttSinglePaymentTransaction(payload, auth);
        try {
            status = trans.getStatusByMerchantTransactionId();
        } catch (AttException ex) {
            System.assertEquals('Merchant Transaction Id must be obtained.', ex.getMessage());
        }  
    }

    public static testmethod void testGetStatusByTransactionId() {
    	Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(createJsonResponse()));
    	
        AttSinglePaymentTransaction trans = new AttSinglePaymentTransaction(createPayload(), auth);
        
        try {
            AttTransactionStatus status = trans.getStatusByTransactionId();
            System.assert(false);
        } catch (AttException ex) {
            System.assertEquals('Transaction ID must be specified.', ex.getMessage());
        }

        trans.getStatusByMerchantTransactionId();                    
        AttTransactionStatus status = trans.getStatusByTransactionId();
        checkStatus(status);
    }

    public static testmethod void testRefund() {
    	Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(createJsonResponse()));
        AttSinglePaymentTransaction trans = new AttSinglePaymentTransaction(createPayload(), auth);
        trans.getStatusByMerchantTransactionId();
        
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{'+
        ' "IsSuccess":true,'+
        ' "Version":"1",'+
        ' "TransactionId":"7617794175102158",'+
        ' "TransactionStatus":"SUCCESSFUL",'+
        ' "OriginalPurchaseAmount":"1.11",'+
        ' "CommitConfirmationId":""'+
        '}'));

        AttTransactionRefundStatus status = trans.refund('Some reason');
		System.assert(status != null);
        System.assert(status.IsSuccess);
        System.assertEquals('1', status.Version);
        System.assertEquals('7617794175102158', status.TransactionId);
        System.assertEquals('SUCCESSFUL', status.TransactionStatus);
        System.assertEquals(1.11, status.OriginalPurchaseAmount);
        System.assertEquals('', status.CommitConfirmationId);
    }

    private static AttPayload createPayload() {
        AttPayload payload = new AttPayload();
        payload.Amount = 3.1;
        payload.Category = 1;
        payload.Description = 'Some product';
        payload.MerchantTransactionId = '11111';
        payload.MerchantProductId = '22222';
        payload.MerchantPaymentRedirectUrl = 'http://localhost';
        return payload;
    }

    private static String createJsonResponse() {
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
        return json;
    }

    private static void checkStatus(AttTransactionStatus status) {
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
    }
    
   
}