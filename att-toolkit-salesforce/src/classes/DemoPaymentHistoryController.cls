public class DemoPaymentHistoryController {
    public AttTransactionStatus answerPaymentStatus  { get; set; }  
    
    public String getStatTransactionType  { get; set; }
    public String getStatTransactionStatus  { get; set; }
    public String getStatIsSuccess  { get; set; }
    public String getStatContentCategory  { get; set; }
    public String getStatAmount  { get; set; }
    
    public String chosenTransactionId{ get; set; }
    public String chosenMerchantTransactionId{ get; set; }
    
    public String refundReason { get; set; }  
    public AttTransactionRefundStatus refundTransactionStatus { get; set; }
    public String refundIsSuccess  { get; set; }
    public String refundOriginalPurchaseAmount  { get; set; }
    
    public Boolean isGetStatusErrorsVisible { get; set; }
    public Boolean isGetRefundErrorsVisible { get; set; }
    
    public AttClientCredentialsAuthorization auth { get; set; }
    
    public DemoPaymentHistoryController(){
    	auth = new AttClientCredentialsAuthorization(ServiceConstants.ScopeType.PAYMENT);
    }
    
    public Pagereference redirectToStore(){
        return Page.att_single_payment_demo_page;
    }
    
    public List<DemoSinglepayHistory__c> getHistoryList(){
        List<DemoSinglepayHistory__c> historyList = new List<DemoSinglepayHistory__c>();
        historyList = [SELECT Refunded__c, TransactionID__c, MerchantTransactionID__c, TransactionDate__c, Price__c, Product__c FROM DemoSinglepayHistory__c WHERE AuthCode__c!=null ORDER BY TransactionDate__c];    
        return historyList; 
    }
    
     public void getPaymentStatus() {     
        answerPaymentStatus = null;
        getStatTransactionType = '';
        getStatTransactionStatus = ''; 
        getStatContentCategory = ''; 
        getStatAmount = '';
        getStatIsSuccess = '';
        
        AttPayload payload = new AttPayload();
        payload.MerchantTransactionId = chosenMerchantTransactionId;
        AttSinglePaymentTransaction singlePayment = new AttSinglePaymentTransaction(payload, auth);
        try {
            answerPaymentStatus = singlePayment.getStatusByMerchantTransactionId();                
        } catch (AttException ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
            isGetStatusErrorsVisible = true;
            isGetRefundErrorsVisible = false;
            return; 
        }        
        
        getStatIsSuccess = '' + answerPaymentStatus.IsSuccess;
        getStatTransactionType = answerPaymentStatus.TransactionType.name();
        getStatTransactionStatus = answerPaymentStatus.TransactionStatus.name();
        getStatContentCategory = '' + answerPaymentStatus.ContentCategory;
        getStatAmount = '' + answerPaymentStatus.Amount;
        if (!Test.isRunningTest()) {
            addTransactionId(answerPaymentStatus.TransactionId);
        }
        
        displayPopup = true;
    }
    
    private void addTransactionId(String transactionId){
        DemoSinglepayHistory__c paymentRecord = [SELECT TransactionId__c FROM DemoSinglepayHistory__c WHERE MerchantTransactionId__c = :chosenMerchantTransactionId LIMIT 1];
        if (paymentRecord != null) {
                paymentRecord.TransactionId__c = transactionId;
            update paymentRecord;
        }        
    }
    
    public boolean displayPopup {get; set;}  
    public boolean displayRefundPopup {get; set;}     
    
    public void closePopup() {        
        displayPopup = false;    
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
        if (String.isBlank(chosenTransactionId)) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please, check Payment Status to get the Transaction ID before you can Get Details.');
            ApexPages.addMessage(msg);
            isGetStatusErrorsVisible = false;
            isGetRefundErrorsVisible = true;
            return;
        }
        refundIsSuccess = '';
        refundOriginalPurchaseAmount = '';
        refundTransactionStatus = null;
        
        AttSinglePaymentTransaction singlePayment = new AttSinglePaymentTransaction (new AttPayload(), auth);
        
        try {
            refundTransactionStatus = singlePayment.refund(chosenTransactionId, refundReason);
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
            checkTransactionAsRefunded(chosenTransactionId);
        }
    }
    
    private void checkTransactionAsRefunded (String transactionId) {
        DemoSinglepayHistory__c paymentRecord = [SELECT Refunded__c FROM DemoSinglepayHistory__c WHERE TransactionId__c = :transactionId LIMIT 1];
        if (paymentRecord != null) {
            paymentRecord.Refunded__c = true;
            update paymentRecord;
        }   
    }
    
    public static testmethod void testController() {
    	Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"Channel\":\"MOBILE_WEB\","Description\":\"T20120104223242088\","Currency\":\"USD\","TransactionType\":\"SINGLEPAY\","TransactionStatus\":\"SUCCESSFUL\","ConsumerId\":\"7569ad74-e2e1-4c1e-9f49-455cdccfa315\",'+
                    '\"MerchantTransactionId\":\"T20120104223242088\","MerchantApplicationId\":\"79b33cf0ddf375044d6b6dada43f7d10\","TransactionId\":\"3013735686002133\","ContentCategory\":\"1\","MerchantProductId\":\"P20120104223242088\",'+
                    '\"MerchantId\":\"6729bc8a-4a4c-4975-b75c-769b7d6c6cd3\","Amount\":\"1.42\","Version\":\"1\","IsSuccess\":\"true\"}'));
		
		DemoPaymentHistoryController controller = new DemoPaymentHistoryController();
        TestHttpMockFactory.getCCAuthMock();
        
        //test getting transaction status
        controller.chosenMerchantTransactionId = 'test';
        controller.getPaymentStatus();
        System.assertEquals(controller.answerPaymentStatus.Amount, 1.42);
        System.assertEquals(controller.answerPaymentStatus.Channel, 'MOBILE_WEB');
        System.assertEquals(controller.answerPaymentStatus.ContentCategory, 1);
        System.assertEquals(controller.answerPaymentStatus.Description, 'T20120104223242088');
        System.assertEquals(controller.answerPaymentStatus.IsSuccess, true);
        System.assertEquals(controller.answerPaymentStatus.MerchantApplicationId, '79b33cf0ddf375044d6b6dada43f7d10');
        System.assertEquals(controller.answerPaymentStatus.MerchantId, '6729bc8a-4a4c-4975-b75c-769b7d6c6cd3');
        System.assertEquals(controller.answerPaymentStatus.MerchantProductId, 'P20120104223242088');
        System.assertEquals(controller.answerPaymentStatus.MerchantTransactionId, 'T20120104223242088');
        System.assertEquals(controller.answerPaymentStatus.TransactionCurrency, 'USD');
        System.assertEquals(controller.answerPaymentStatus.TransactionId, '3013735686002133');
        System.assertEquals(controller.answerPaymentStatus.TransactionStatus, AttTransactionStatus.TransactionStatus.SUCCESSFUL);
        System.assertEquals(controller.answerPaymentStatus.TransactionType,  AttTransactionStatus.TransactionType.SINGLEPAY);
        System.assertEquals(controller.answerPaymentStatus.Version, '1');
        
        controller.chosenMerchantTransactionId = ''; 
        controller.getPaymentStatus();
        System.assertEquals(ApexPages.getMessages().size(), 1);
        System.assertNotEquals(ApexPages.getMessages().get(0), null);
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Merchant Transaction Id must be obtained.');
        
        //test refunding transaction
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{'+
        ' "IsSuccess":true,'+
        ' "Version":"1",'+
        ' "TransactionId":"7617794175102158",'+
        ' "TransactionStatus":"SUCCESSFUL",'+
        ' "OriginalPurchaseAmount":"1.11",'+
        ' "CommitConfirmationId":""'+
        '}'));
        controller.chosenTransactionId = 'trId001';
        controller.refundReason = 'Test refund reason';
        controller.refundTransaction();
        System.assert(controller.refundTransactionStatus != null);
        System.assert(controller.refundTransactionStatus.IsSuccess);
        System.assertEquals('1', controller.refundTransactionStatus.Version);
        System.assertEquals('7617794175102158', controller.refundTransactionStatus.TransactionId);
        System.assertEquals('SUCCESSFUL', controller.refundTransactionStatus.TransactionStatus);
        System.assertEquals(1.11, controller.refundTransactionStatus.OriginalPurchaseAmount);
        System.assertEquals('', controller.refundTransactionStatus.CommitConfirmationId);
        
        controller.chosenTransactionId = '';
        controller.refundTransaction();
        System.assertEquals(ApexPages.getMessages().size(), 2);
        System.assertNotEquals(ApexPages.getMessages().get(1), null);
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Please, check Payment Status to get the Transaction ID before you can Get Details.');
        
        controller.chosenTransactionId = 'test';
        controller.refundReason = ''; 
        controller.refundTransaction();
        System.assertEquals(ApexPages.getMessages().size(), 3);
        System.assertNotEquals(ApexPages.getMessages().get(2), null);
        System.assertEquals(ApexPages.getMessages().get(2).getSummary(), 'Refund Reason must be specified.');
                
        controller.closePopup();
        System.assertEquals(controller.displayPopup, false);
        
        controller.redirectToStore();
        controller.showRefundPopup();
        System.assertEquals(controller.displayRefundPopup, true);
        
        controller.closeRefundPopup();
        System.assertEquals(controller.displayRefundPopup, false);
        
        DemoSinglepayHistory__c paymentRecord = new DemoSinglepayHistory__c();
        paymentRecord.MerchantTransactionID__c = '001122';
        paymentRecord.TransactionDate__c = Datetime.now();
        paymentRecord.Price__c = 1.99;
        paymentRecord.Product__c = 'Art of Computer';
        paymentRecord.AuthCode__c = 'aCode001';
        insert paymentRecord; 
        
        List<DemoSinglepayHistory__c> historyList = controller.getHistoryList();        
        System.assertEquals(historyList.size(), 1);
        
        controller.chosenMerchantTransactionId = '001122'; 
        controller.addTransactionId('TestTransactionId');
        
        controller.checkTransactionAsRefunded('TestTransactionId');
    }
}