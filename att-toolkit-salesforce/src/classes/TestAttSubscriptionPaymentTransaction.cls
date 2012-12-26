@isTest
public class TestAttSubscriptionPaymentTransaction {    
    
    public static MultiStaticResourceCalloutMock mock;
    public static AttClientCredentialsAuthorization auth =  TestHttpMockFactory.getCCAuthMock();
    
    public static testmethod void testStart() {
        AttSubscriptionPaymentTransaction trans = new AttSubscriptionPaymentTransaction(createPayload(), auth);
        TestHttpMockFactory.SingleRequestMock redirect = new TestHttpMockFactory.SingleRequestMock(302, 'OK', Blob.valueOf('test'), new Map<String, String>{
            'Location' => 'http://att.com'
        });
        SecurityTokenProvider tokenProvider = UtilityFactory.getSecurityTokenProvider();
        Att_Application_Security_Key__c applicationKey = tokenProvider.getApplicationKey();
        String params =  '?SignedPaymentDetail=' + 'JTdCJTIyU2lnbmVkczMzQ5NjIlN0QlN0Q' + 
                '&Signature=' + 'kczMzQ5NjIlN' + '&clientid=' + applicationKey.API_Key__c;
        
        HttpCalloutMock multimock = new TestHttpMockFactory.MultiRequestMock(new Map<String,HttpCalloutMock>{
            ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.NOTARY) =>   TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"SignedDocument": "JTdCJTIyU2lnbmVkczMzQ5NjIlN0QlN0Q","Signature": "kczMzQ5NjIlN"}'),
            ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.NEW_SUBSCRIPTION) + params =>  redirect  
        });
        
        Test.setMock(HttpCalloutMock.class, multimock);
        PageReference reference = trans.start();
        System.assertEquals('http://att.com', reference.getUrl());
    }
    
    private static AttSubscriptionPayload createPayload() {
        AttSubscriptionPayload payload = new AttSubscriptionPayload();
        payload.Amount = 3.1;
        payload.Category = 2;
        payload.Channel = '1';
        payload.Description = 'Some product';
        payload.MerchantTransactionId = '11111';
        payload.MerchantProductId = '22222';
        payload.MerchantPaymentRedirectUrl = 'http://localhost';        
        payload.MerchantSubscriptionIdList = 'M1234512345';
        payload.IsPurchaseOnNoActiveSubscription = true;
        payload.SubscriptionRecurrences = 99999;
        payload.SubscriptionPeriod = 'MONTHLY';
        payload.SubscriptionPeriodAmount = 1;        
        return payload;
    }
    
    private static String createJsonResponse() {
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
        return json;
    }
    
    private static void checkStatus(AttSubscriptionStatus status) {
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
    }
    /*
    public static testmethod void testStart() {
        StaticResourceCalloutMock startMock = new StaticResourceCalloutMock();
        startMock.setStatusCode(200);
        startMock.setHeader('Location', 'http://att.com');
        
        HttpCalloutMock multimock = new TestHttpMockFactory.MultiRequestMock(new Map<String,HttpCalloutMock>{
            ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.NOTARY) => TestHttpMockFactory.getSuccessfulCreatedHttpMock('{'+
                '"SignedDocument": "JTdCJTIyU2lnb","Signature": "K2ElRUYlQ"}'),
            ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.NEW_SUBSCRIPTION) => new TestHttpMockFactory.SingleRequestMock(302,'OK', null, new Map<String,String> {'Location' => 'http://att.com'})});
        Test.setMock(HttpCalloutMock.class, multimock);
        
        AttSubscriptionPaymentTransaction trans = new AttSubscriptionPaymentTransaction(createPayload());
        PageReference reference = trans.start();
        System.assertEquals('http://att.com', reference.getUrl());
    }*/
    
    public static testmethod void testHandlingAuthCode() {
        ApexPages.currentPage().getParameters().put('success', 'false');
        ApexPages.currentPage().getParameters().put('faultCode', 'Test01');
        ApexPages.currentPage().getParameters().put('faultDescription', 'Test fault description');
        ApexPages.currentPage().getParameters().put('faultMessage', 'Test fault message');
        
        try {
            AttSubscriptionPaymentTransaction.handleRedirectUrlForSubscriptionAuthorizationCode();
        } catch (AttException ex) {
            System.assertEquals('Fault code: Test01 Fault Description: Test fault description Fault Message: Test fault message', ex.getMessage());
        }
        
        ApexPages.currentPage().getParameters().put('success', 'true');
        ApexPages.currentPage().getParameters().put('SubscriptionAuthCode', 'TestSubscriptionAuthCode001');      
        String subscriptionAuthCode = AttSubscriptionPaymentTransaction.handleRedirectUrlForSubscriptionAuthorizationCode(); 
        System.assertEquals('TestSubscriptionAuthCode001',  subscriptionAuthCode);
    }
         
    
    public static testmethod void testGetStatusByAuthorizationCode() {      
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(createJsonResponse()));
        
        AttSubscriptionPaymentTransaction trans = new AttSubscriptionPaymentTransaction(createPayload(), auth);  
        
        try {
            AttSubscriptionStatus status = trans.getStatusByAuthorizationCode('');
        } catch (AttException ex) {
            System.assertEquals('Authorization Code must be specified.', ex.getMessage());
        }
        
        AttSubscriptionStatus status = trans.getStatusByAuthorizationCode('1111');
        checkStatus(status);
    }
    
    public static testmethod void testGetStatusByMerchantTransactionId() {
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(createJsonResponse()));
        
        AttSubscriptionPaymentTransaction trans = new AttSubscriptionPaymentTransaction(new AttSubscriptionPayload(), auth);  
        
        try {
            AttSubscriptionStatus status = trans.getStatusByMerchantTransactionId();
        } catch (AttException ex) {
            System.assertEquals('Merchant Transaction Id must be obtained.', ex.getMessage());
        }
        
        trans = new AttSubscriptionPaymentTransaction(createPayload(), auth);
        AttSubscriptionStatus status = trans.getStatusByMerchantTransactionId();
        checkStatus(status);
    }
    
    public static testmethod void testGetStatusBySubscriptionId() {
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(createJsonResponse()));
        
        AttSubscriptionPaymentTransaction trans = new AttSubscriptionPaymentTransaction(createPayload(), auth);  
        
        try {
            AttSubscriptionStatus status = trans.getStatusBySubscriptionId();
        } catch (AttException ex) {
            System.assertEquals('Transaction ID must be specified.', ex.getMessage());
        }
        
        AttSubscriptionStatus status = trans.getStatusBySubscriptionId('testId');
        checkStatus(status);
    }
    
    public static testmethod void testGetDetails() {
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(createJsonResponse()));
            
        
        AttSubscriptionPaymentTransaction trans = new AttSubscriptionPaymentTransaction(createPayload(), auth);
        
        try {
            AttSubscriptionDetailsStatus status = trans.getDetails();
        } catch (AttException ex) {
            System.assertEquals('Consumer ID must be obtained.', ex.getMessage());
        }        
        
        trans.getStatusByMerchantTransactionId(); 
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{'+
        '"Currency":"USD",'+
        '"Status":"ACTIVE",'+
        '"CreationDate":"2012-11-12 15:27:09",'+
        '"GrossAmount":"0.99",'+
        '"SubscriptionRecurrences":"99999",'+
        '"IsActiveSubscription":"true",'+
        '"CurrentStartDate":"2012-11-12 15:27:09",'+
        '"CurrentEndDate":"2012-12-12 15:27:09",'+
        '"SubscriptionRemaining":"2147483647",'+
        '"Version":"1",'+
        '"IsSuccess":"true"'+
        '}')); 
        AttSubscriptionDetailsStatus status = trans.getDetails();
        
        System.assert(status != null);
        System.assertEquals('USD', status.SubscriptionCurrency);
        System.assertEquals('ACTIVE', status.Status);
        System.assertEquals(Datetime.valueOf('2012-11-12 15:27:09'), status.CreationDate);
        System.assertEquals(0.99, status.GrossAmount);
        System.assertEquals(99999, status.SubscriptionRecurrences);
        System.assertEquals(true, status.IsActiveSubscription);
        System.assertEquals(Datetime.valueOf('2012-11-12 15:27:09'), status.CurrentStartDate);
        System.assertEquals(Datetime.valueOf('2012-12-12 15:27:09'), status.CurrentEndDate);
        System.assertEquals(2147483647, status.SubscriptionRemaining);
        System.assertEquals('1', status.Version);
        System.assertEquals(true, status.IsSuccess);        
        
        AttSubscriptionPayload payload = createPayload();
        payload.MerchantSubscriptionIdList = '';
        trans = new AttSubscriptionPaymentTransaction(payload, auth);
        try {
            status = trans.getDetails('testConsumerId');
        } catch (AttException ex) {
            System.assertEquals('Merchant Subscription Id List must be obtained.', ex.getMessage());
        }        
    }
    
    public static testmethod void testrefund() {
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{'+
        ' "IsSuccess":true,'+
        ' "Version":"1",'+
        ' "TransactionId":"7617794175102158",'+
        ' "TransactionStatus":"SUCCESSFUL",'+
        ' "OriginalPurchaseAmount":"1.11",'+
        ' "CommitConfirmationId":""'+
        '}'));
        
        AttSubscriptionPaymentTransaction trans = new AttSubscriptionPaymentTransaction(createPayload(), auth); 
        
        //trans.getStatusBySubscriptionId('testId', auth);        
        AttTransactionRefundStatus status = trans.refund('testSuscrId', 'Test refund reason text');
        System.assert(status != null);
        System.assert(status.IsSuccess);
        System.assertEquals('1', status.Version);
        System.assertEquals('7617794175102158', status.TransactionId);
        System.assertEquals('SUCCESSFUL', status.TransactionStatus);
        System.assertEquals(1.11, status.OriginalPurchaseAmount);
        System.assertEquals('', status.CommitConfirmationId);
        
        try {
            status = trans.refund('Test refund reason text');
        } catch (AttException ex) {
            System.assertEquals('Subscription Id must be specified.', ex.getMessage());
        }  
    }
}