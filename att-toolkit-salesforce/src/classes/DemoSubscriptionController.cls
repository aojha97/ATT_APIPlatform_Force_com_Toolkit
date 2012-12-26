public class DemoSubscriptionController { 

    public String chosenTransactionId{ get; set; }
    
    public boolean testExceptionMode { get; set; }
    
    private static final String merchantIdParamName = 'merchantTrId'; 
    
    public DemoSubscriptionController(){
    }
    
    public void addSubsAuthCode(){
        String subscriptionAuthCode;
        try {
            subscriptionAuthCode = AttSubscriptionPaymentTransaction.handleRedirectUrlForSubscriptionAuthorizationCode();            
        } catch (AttException ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
            return;
        } 
        String merchantId = ApexPages.currentPage().getParameters().get(merchantIdParamName);
        try {
            DemoSubscriptionHistory__c paymentRecord = [SELECT MerchantTransactionID__c, SubscriptionDate__c, Price__c, Product__c, AuthCode__c FROM DemoSubscriptionHistory__c  WHERE MerchantTransactionId__c = :merchantId LIMIT 1];
            if (String.isNotEmpty(subscriptionAuthCode) && String.isEmpty(paymentRecord.AuthCode__c)) {
                paymentRecord.AuthCode__c = subscriptionAuthCode;
                update paymentRecord; 
            } 
            
        } catch (Exception ex) {
        }
    } 
    
    public class Magazine {
        public String name { get; set; }
        public Decimal price { get; set; }
        public String imageFileName { get; set; }
        public String productId { get; set; }
        public String description { get; set; }
        
        public Magazine(String name, Decimal price, String imageFileName, String productId, String description){
            this.name = name;
            this.price = price;
            this.imageFileName = imageFileName;
            this.productId = productId;
            this.description = description;
        }
        
        public PageReference subscribe() {
            PageReference pageRef;
            AttSubscriptionPaymentTransaction subscription;
            AttSignedPayload sPayload;
        
            String mTransactionId = 'MerchTransId' + Math.roundToLong(Math.random() * 1000000000) + 'subscr' + Math.roundToLong(Math.random() * 1000000000);
            AttSubscriptionPayload payload = new AttSubscriptionPayload();
            payload.Amount = this.price;
            payload.Category = 1;
            payload.Description = this.description;
            payload.MerchantProductId = this.productId;
            payload.MerchantTransactionId = mTransactionId;
            Map<String, String> params = new Map<String, String> {merchantIdParamName => mTransactionId};
            if (!Test.isRunningTest()) {
                payload.MerchantPaymentRedirectUrl = UtilityFactory.getUtils().addParametersToUrl(Url.getCurrentRequestUrl().toExternalForm(), params, false);
            }
            
            payload.MerchantSubscriptionIdList = String.valueOf(Datetime.now().getTime()).right(12); 
            payload.IsPurchaseOnNoActiveSubscription = false;
            payload.SubscriptionRecurrences = 99999;
            payload.SubscriptionPeriodAmount = 1;
        
            try {
                subscription = new AttSubscriptionPaymentTransaction(payload, new AttClientCredentialsAuthorization(ServiceConstants.ScopeType.PAYMENT));
                pageRef =  subscription.start();
            } catch (AttException ex) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
                ApexPages.addMessage(msg);
                return null; 
            }
            saveToOrderHistory(mTransactionId, payload.MerchantSubscriptionIdList);
            return pageRef;
        }
    
        private void saveToOrderHistory(String mTransactionId, String merchantSubscriptionIdList){
            DemoSubscriptionHistory__c paymentRecord = new DemoSubscriptionHistory__c();
            paymentRecord.MerchantTransactionID__c = mTransactionId;
            paymentRecord.SubscriptionDate__c = Datetime.now();
            paymentRecord.Price__c = this.price;
            paymentRecord.Product__c = this.name;
            paymentRecord.MerchantSubscriptionIdList__c = merchantSubscriptionIdList;
            insert paymentRecord;        
        }  
    }
    
    public List<Magazine> getMagazinesList(){
        List<Magazine> books = new List<Magazine>();
        books.add(new Magazine('PC World', 1.00, 'PCWorld.jpeg', 'MagID001', 'Subscription for PC World'));
        books.add(new Magazine('Popular Science', 1.29, 'PopularScience.jpg', 'MagID002', 'Subscription for Popular Science'));
        books.add(new Magazine('National Geographic', 1.99, 'NationalGeographic.jpg', 'MagID003', 'Subscription for NationalGeographic'));
        books.add(new Magazine('Linux Format ', 1.20, 'LinuxFormat.jpg', 'MagID004', 'Subscription for LinuxFormat'));
        books.add(new Magazine('Car and Driver', 3.49, 'CarAndDriver.jpeg', 'MagID005', 'Subscription for Car and Driver'));
        return books;
    }  
    
    public Pagereference redirectToOrderHistory(){
        return Page.att_subscription_history_demo_page;
    }
        
    public static testmethod void testController() {
        DemoSubscriptionController controller = new DemoSubscriptionController();
        controller.redirectToOrderHistory();
        List<Magazine> mList = controller.getMagazinesList();
        Magazine magazine = mList.get(0);
        System.assertEquals('Subscription for PC World', magazine.description);
        System.assertEquals('PCWorld.jpeg', magazine.imageFileName);
        System.assertEquals('PC World', magazine.name);
        System.assertEquals(1.00, magazine.price);
        System.assertEquals('MagID001', magazine.productId);
        
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
        AttSubscriptionPaymentTransaction trans = new AttSubscriptionPaymentTransaction(payload, TestHttpMockFactory.getCCAuthMock());
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
        PageReference reference = magazine.subscribe();
        System.assertEquals('http://att.com', reference.getUrl());
        
        ApexPages.currentPage().getParameters().put('success', 'true');
        ApexPages.currentPage().getParameters().put('SubscriptionAuthCode', 'TestSubscriptionAuthCode001');
        ApexPages.currentPage().getParameters().put(merchantIdParamName, '001122');
        
        DemoSubscriptionHistory__c paymentRecord = new DemoSubscriptionHistory__c();
        paymentRecord.Refunded__c = true;
        paymentRecord.SubscriptionId__c = 'subscripId001';
        paymentRecord.MerchantSubscriptionIdList__c = 'sid123456';
        paymentRecord.ConsumerID__c = 'cid147';
        paymentRecord.MerchantTransactionID__c = '001122';
        paymentRecord.SubscriptionDate__c = Datetime.now();
        paymentRecord.Price__c = 1.99;
        paymentRecord.Product__c = 'Art of Computer';
        insert paymentRecord; 
        
        controller.addSubsAuthCode();
        
        ApexPages.currentPage().getParameters().clear();
        ApexPages.currentPage().getParameters().put('success', 'false');
        ApexPages.currentPage().getParameters().put('faultCode', 'Test01');
        ApexPages.currentPage().getParameters().put('faultDescription', 'Test fault description');
        ApexPages.currentPage().getParameters().put('faultMessage', 'Test fault message');
        
        controller.addSubsAuthCode();
        System.assertEquals(ApexPages.getMessages().size(), 1);
        System.assertNotEquals(ApexPages.getMessages().get(0), null);
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Fault code: Test01 Fault Description: Test fault description Fault Message: Test fault message');
                      
    }
}