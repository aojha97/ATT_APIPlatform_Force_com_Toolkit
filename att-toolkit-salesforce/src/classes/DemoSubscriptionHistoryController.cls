public class DemoSubscriptionHistoryController {

    public Boolean isGetRefundErrorsVisible { get; set; }
    public Boolean isGetStatusErrorsVisible { get; set; }
    
    public AttSubscriptionStatus answerPaymentStatus { get; set; }
    public AttSubscriptionDetailsStatus subscriptionDetails { get; set; }
    public Boolean displayPopUp { get; set; }
    public Boolean displayDetailsPopUp { get; set; }
    
    public String getStatSubscriptionType  { get; set; }
    public String getStatSubscriptionStatus  { get; set; }
    public String getStatIsSuccess  { get; set; }
    public String getStatContentCategory  { get; set; }
    public String getStatAmount  { get; set; }
    
    public String detailsCreationDate { get; set; }
    public String detailsGrossAmount { get; set; }
    public String detailsSubscriptionRecurrences { get; set; }
    public String detailsIsActiveSubscription { get; set; }
    public String detailsCurrentStartDate { get; set; }
    public String detailsCurrentEndDate { get; set; }
    public String detailsSubscriptionRemaining { get; set; }
    public String detailsIsSuccess { get; set; }
    
    public String chosenTransactionId{ get; set; }
    public String chosenConsumerId { get; set; }
    public String chosenMerchantSubscriptionIdList { get; set; }
    public String chosenSubscriptionId { get; set; }
    
    public boolean testExceptionMode { get; set; } 
    
    public String refundReason { get; set; }  
    public AttTransactionRefundStatus refundTransactionStatus { get; set; }
    public String refundIsSuccess  { get; set; }
    public String refundOriginalPurchaseAmount  { get; set; }
    
    public boolean displayRefundPopup {get; set;}
    public AttClientCredentialsAuthorization auth { get; set; }
    
    public DemoSubscriptionHistoryController() {
    	auth = new AttClientCredentialsAuthorization(ServiceConstants.ScopeType.PAYMENT);
    }
    
    public List<DemoSubscriptionHistory__c> getHistoryList(){
        List<DemoSubscriptionHistory__c> historyList = new List<DemoSubscriptionHistory__c>();
        historyList = [SELECT Refunded__c, SubscriptionId__c, MerchantSubscriptionIdList__c, ConsumerID__c, MerchantTransactionID__c, SubscriptionDate__c, Price__c, Product__c FROM DemoSubscriptionHistory__c WHERE AuthCode__c!=null ORDER BY SubscriptionDate__c];    
        return historyList;
    }
    
    public void getSubscriptiontStatus() {
        AttSubscriptionPayload payload = new AttSubscriptionPayload();
        payload.MerchantTransactionId = chosenTransactionId;
        AttSubscriptionPaymentTransaction subscription = new AttSubscriptionPaymentTransaction(payload, auth);
        try {
            answerPaymentStatus = subscription.getStatusByMerchantTransactionId();                
        } catch (AttException ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
            isGetStatusErrorsVisible = true;
            isGetRefundErrorsVisible = false;
            return; 
        }      
        getStatIsSuccess = '' + answerPaymentStatus.IsSuccess;
        getStatSubscriptionType = answerPaymentStatus.SubscriptionType != null ? answerPaymentStatus.SubscriptionType.name() : '';
        getStatSubscriptionStatus = answerPaymentStatus.SubscriptionStatus != null ? answerPaymentStatus.SubscriptionStatus.name() : '';
        getStatContentCategory = '' + answerPaymentStatus.ContentCategory;
        getStatAmount = '' + answerPaymentStatus.Amount;
        if (!Test.isRunningTest()){
            addConsumerIdAndSubscriptionId(answerPaymentStatus.ConsumerId, answerPaymentStatus.SubscriptionId);
        }
        
        displayPopUp = true;
    }
    
    private void addConsumerIdAndSubscriptionId(String consumerId, String subscriptionId){
        DemoSubscriptionHistory__c paymentRecord = [SELECT ConsumerID__c, SubscriptionId__c FROM DemoSubscriptionHistory__c WHERE MerchantTransactionID__c = :chosenTransactionId LIMIT 1];
        if (paymentRecord != null) {
                paymentRecord.ConsumerID__c = consumerId;
                paymentRecord.SubscriptionId__c = subscriptionId;
            update paymentRecord;
        }        
    }
    
    public void getSubscriptiontDetails() {
        if (String.isBlank(chosenConsumerId)) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please, check Subscription Status to get the Consumer ID before you can Get Details.');
            ApexPages.addMessage(msg);
            isGetStatusErrorsVisible = true;
            isGetRefundErrorsVisible = false;
            return;
        }
        AttSubscriptionPayload payload = new AttSubscriptionPayload();
        payload.MerchantSubscriptionIdList = chosenMerchantSubscriptionIdList;
        AttSubscriptionPaymentTransaction subscription = new AttSubscriptionPaymentTransaction(payload, auth);
        try {
            subscriptionDetails = subscription.getDetails(chosenConsumerId);
        } catch (AttException ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
            isGetStatusErrorsVisible = true;
            isGetRefundErrorsVisible = false;
            return; 
        }
        
        detailsCreationDate = '' + subscriptionDetails.CreationDate;
        detailsGrossAmount = '' + subscriptionDetails.GrossAmount;
        detailsSubscriptionRecurrences = '' + subscriptionDetails.SubscriptionRecurrences;
        detailsIsActiveSubscription = '' + subscriptionDetails.IsActiveSubscription;
        detailsCurrentStartDate = '' + subscriptionDetails.CurrentStartDate;
        detailsCurrentEndDate = '' + subscriptionDetails.CurrentEndDate;
        detailsSubscriptionRemaining = '' + subscriptionDetails.SubscriptionRemaining;
        detailsIsSuccess = '' + subscriptionDetails.IsSuccess;
        displayDetailsPopUp = true;
    }
    
    public Pagereference redirectToStore(){
        return Page.att_subscription_demo_page;
    }
    
    public void closePopup() {
        displayPopup = false;
    }
    
    public void closeDetailsPopup() {
        displayDetailsPopUp = false;
    }
    
    public void showRefundPopup() {
        refundIsSuccess = '';
        refundOriginalPurchaseAmount = '';
        refundTransactionStatus = null;        
        displayRefundPopup = true;    
    }
    
    
    public void closeRefundPopup() {        
        displayRefundPopup = false;    
    }
    
    public void refundTransaction() {
        if (String.isBlank(chosenSubscriptionId)) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please, check Payment Status to get the Subscription ID before you can Refund Subscription.');
            ApexPages.addMessage(msg);
            isGetStatusErrorsVisible = false;
            isGetRefundErrorsVisible = true;
            return;
        }
        refundIsSuccess = '';
        refundOriginalPurchaseAmount = '';
        refundTransactionStatus = null;
        
        AttSubscriptionPaymentTransaction subscription = new AttSubscriptionPaymentTransaction (new AttSubscriptionPayload(), auth);
        
        try {
            refundTransactionStatus = subscription.refund(chosenSubscriptionId, refundReason);
        } catch (AttException ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
            isGetStatusErrorsVisible = false;
            isGetRefundErrorsVisible = true;
            return; 
        }
        refundIsSuccess = '' + refundTransactionStatus.IsSuccess;
        refundOriginalPurchaseAmount   = '' + refundTransactionStatus.OriginalPurchaseAmount;
        if (refundTransactionStatus.IsSuccess && !Test.isRunningTest()) {
            checkTransactionAsRefunded(chosenSubscriptionId);
        }
    }
    
    private void checkTransactionAsRefunded (String transactionId) {
        DemoSubscriptionHistory__c paymentRecord = [SELECT Refunded__c FROM DemoSubscriptionHistory__c WHERE SubscriptionId__c = :transactionId LIMIT 1];
        if (paymentRecord != null) {
            paymentRecord.Refunded__c = true;
            update paymentRecord;
        }   
    }
    
    public static testmethod void testController() {
    	String json = '{ "Version": "1","IsSuccess": "true","Amount": "1.35","Channel": "MOBILE_WEB","Description": "RECUR","Currency": "USD",'+
                    '"SubscriptionType": "SUBSCRIPTION","SubscriptionStatus": "SUCCESSFUL","ConsumerId": "08660eb2-c9c4-48a6-93ea-1c440fa826e4","MerchantTransactionId": "T20120619152559466",'+
                    '"MerchantApplicationId": "029c091549fd96788537c5c5cbbb94a3","SubscriptionId": "6108486931402157","OriginalTransactionId": "oidrId12345","ContentCategory": "1",'+
                    '"MerchantProductId": "P20120619152559466","MerchantId": "5f13fd54-b4ef-4574-9043-b2a0180b4a90","MerchantSubscriptionId": "619152559466","SubscriptionPeriodAmount": "1",'+
                    '"SubscriptionRecurrences": "99999","SubscriptionPeriod": "MONTHLY","IsAutoCommitted": "false"}';
    	Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(json));		
		AttClientCredentialsAuthorization auth = TestHttpMockFactory.getCCAuthMock();
    	
        DemoSubscriptionHistoryController controller = new DemoSubscriptionHistoryController();
        TestHttpMockFactory.getCCAuthMock();
        
        controller.chosenTransactionId = 'testTrId';
        controller.chosenMerchantSubscriptionIdList = '001122';
        controller.getSubscriptiontStatus();
        System.assert(controller.answerPaymentStatus != null);
        System.assertEquals('1', controller.answerPaymentStatus.Version);
        System.assertEquals(true, controller.answerPaymentStatus.IsSuccess);
        System.assertEquals(1.35, controller.answerPaymentStatus.Amount);
        System.assertEquals('MOBILE_WEB', controller.answerPaymentStatus.Channel);
        System.assertEquals('RECUR', controller.answerPaymentStatus.Description);
        System.assertEquals('USD', controller.answerPaymentStatus.SubscriptionCurrency);
        System.assertEquals(AttSubscriptionStatus.SubscriptionType.SUBSCRIPTION, controller.answerPaymentStatus.SubscriptionType);
        System.assertEquals(AttSubscriptionStatus.SubscriptionStatus.SUCCESSFUL, controller.answerPaymentStatus.SubscriptionStatus);
        System.assertEquals('08660eb2-c9c4-48a6-93ea-1c440fa826e4', controller.answerPaymentStatus.ConsumerId);
        System.assertEquals('T20120619152559466', controller.answerPaymentStatus.MerchantTransactionId);
        System.assertEquals('029c091549fd96788537c5c5cbbb94a3', controller.answerPaymentStatus.MerchantApplicationId);
        System.assertEquals('6108486931402157', controller.answerPaymentStatus.SubscriptionId);
        System.assertEquals('oidrId12345', controller.answerPaymentStatus.OriginalTransactionId);
        System.assertEquals(1, controller.answerPaymentStatus.ContentCategory);
        System.assertEquals('P20120619152559466', controller.answerPaymentStatus.MerchantProductId);
        System.assertEquals('5f13fd54-b4ef-4574-9043-b2a0180b4a90', controller.answerPaymentStatus.MerchantId);
        System.assertEquals('619152559466', controller.answerPaymentStatus.MerchantSubscriptionId);
        System.assertEquals('1', controller.answerPaymentStatus.SubscriptionPeriodAmount);
        System.assertEquals('99999', controller.answerPaymentStatus.SubscriptionRecurrences);
        System.assertEquals('MONTHLY', controller.answerPaymentStatus.SubscriptionPeriod);
        System.assertEquals('false', controller.answerPaymentStatus.IsAutoCommitted);
        
        controller.chosenTransactionId = '';
        controller.getSubscriptiontStatus();
        System.assertEquals(ApexPages.getMessages().size(), 1);
        System.assertNotEquals(ApexPages.getMessages().get(0), null);
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Merchant Transaction Id must be obtained.');
        
        //test getting subscription details
        json = '{"Currency":"USD","Status":"ACTIVE","CreationDate":"2012-11-12 15:27:09","GrossAmount":"0.99","SubscriptionRecurrences":"99999",'+
                    '"IsActiveSubscription":"true","CurrentStartDate":"2012-11-12 15:27:09","CurrentEndDate":"2012-12-12 15:27:09","SubscriptionRemaining":"2147483647","Version":"1","IsSuccess":"true"}'; 
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(json));    
        controller.getSubscriptiontDetails();
        System.assertEquals(ApexPages.getMessages().size(), 2);
        System.assertNotEquals(ApexPages.getMessages().get(1), null);
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Please, check Subscription Status to get the Consumer ID before you can Get Details.');
        
        controller.chosenConsumerId = 'chConsId001';
        controller.getSubscriptiontDetails();
        System.assert(controller.subscriptionDetails != null);
        System.assertEquals('USD', controller.subscriptionDetails.SubscriptionCurrency);
        System.assertEquals('ACTIVE', controller.subscriptionDetails.Status);
        System.assertEquals(Datetime.valueOf('2012-11-12 15:27:09'), controller.subscriptionDetails.CreationDate);
        System.assertEquals(0.99, controller.subscriptionDetails.GrossAmount);
        System.assertEquals(99999, controller.subscriptionDetails.SubscriptionRecurrences);
        System.assertEquals(true, controller.subscriptionDetails.IsActiveSubscription);
        System.assertEquals(Datetime.valueOf('2012-11-12 15:27:09'), controller.subscriptionDetails.CurrentStartDate);
        System.assertEquals(Datetime.valueOf('2012-12-12 15:27:09'), controller.subscriptionDetails.CurrentEndDate);
        System.assertEquals(2147483647, controller.subscriptionDetails.SubscriptionRemaining); 
        System.assertEquals('1', controller.subscriptionDetails.Version);
        System.assertEquals(true, controller.subscriptionDetails.IsSuccess);
        
        controller.chosenMerchantSubscriptionIdList = '';
        controller.getSubscriptiontDetails();
        System.assertEquals(ApexPages.getMessages().size(), 3);
        System.assertNotEquals(ApexPages.getMessages().get(2), null);
        System.assertEquals(ApexPages.getMessages().get(2).getSummary(), 'Merchant Subscription Id List must be obtained.');
        
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{'+
        ' "IsSuccess":true,'+
        ' "Version":"1",'+
        ' "TransactionId":"7617794175102158",'+
        ' "TransactionStatus":"SUCCESSFUL",'+
        ' "OriginalPurchaseAmount":"1.11",'+
        ' "CommitConfirmationId":""'+
        '}'));
        
        controller.chosenSubscriptionId = null;
        controller.refundTransaction();
        System.assertEquals(ApexPages.getMessages().size(), 4);
        System.assertNotEquals(ApexPages.getMessages().get(3), null);
        System.assertEquals(ApexPages.getMessages().get(3).getSummary(), 'Please, check Payment Status to get the Subscription ID before you can Refund Subscription.');
        
        controller.chosenSubscriptionId = 'trId001';        
        
        controller.refundTransaction();
        System.assertEquals(ApexPages.getMessages().size(), 5);
        System.assertNotEquals(ApexPages.getMessages().get(4), null);
        System.assertEquals(ApexPages.getMessages().get(4).getSummary(), 'Refund Reason must be specified.');
        
        controller.refundReason = 'Test reason';
        controller.refundTransaction();
        System.assert(controller.refundTransactionStatus != null);
        System.assert(controller.refundTransactionStatus.IsSuccess);
        System.assertEquals('1', controller.refundTransactionStatus.Version);
        System.assertEquals('7617794175102158', controller.refundTransactionStatus.TransactionId);
        System.assertEquals('SUCCESSFUL', controller.refundTransactionStatus.TransactionStatus);
        System.assertEquals(1.11, controller.refundTransactionStatus.OriginalPurchaseAmount);
        System.assertEquals('', controller.refundTransactionStatus.CommitConfirmationId);
        
        controller.redirectToStore();
        
        controller.closeDetailsPopup();
        System.assertEquals(controller.displayDetailsPopUp, false);
        
        controller.closePopup();
        System.assertEquals(controller.displayPopup, false);
        
        controller.showRefundPopup();
        System.assertEquals(controller.displayRefundPopup, true);
        
        controller.closeRefundPopup();
        System.assertEquals(controller.displayRefundPopup, false);   
        
        DemoSubscriptionHistory__c paymentRecord = new DemoSubscriptionHistory__c();
        paymentRecord.Refunded__c = true;
        paymentRecord.SubscriptionId__c = 'subscripId001';
        paymentRecord.MerchantSubscriptionIdList__c = 'sid123456';
        paymentRecord.ConsumerID__c = 'cid147';
        paymentRecord.MerchantTransactionID__c = '001122';
        paymentRecord.SubscriptionDate__c = Datetime.now();
        paymentRecord.Price__c = 1.99;
        paymentRecord.Product__c = 'Art of Computer';
        paymentRecord.AuthCode__c = 'aCode001';
        insert paymentRecord;   
        
        List<DemoSubscriptionHistory__c> historyList = controller.getHistoryList();        
        System.assertEquals(historyList.size(), 1);  
        
        controller.chosenTransactionId = '001122';
        controller.addConsumerIdAndSubscriptionId('consumerId', 'subscriptionId23321');
        
        controller.checkTransactionAsRefunded('subscriptionId23321');
    }
        
}