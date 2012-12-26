public class DemoPaymentNotificationController {
        
    public AttNotificationAcknowledgeResponse acknowledgeResponse {get; set;}
        
    public AttPaymentNotificationDetails notificationDetails {get; set;}

    public String chosenId {get; set;}
    
    public String debug {get; set;}

    public Boolean displayPopUp { get; set; }
    
    public AttClientCredentialsAuthorization auth { get; set; }  
    
    public String RefundPriceAmount  {get; set;}
    public String OriginalPriceAmount  {get; set;}
    public String RefundReasonId  {get; set;}        
    public String SubscriptionPeriodAmount  {get; set;}
    public String SubscriptionPeriod  {get; set;}        
    public String SubscriptionRemaining  {get; set;}
    public String isGettingSuccess {get; set;}
    public String version {get; set;}
    
    public boolean isGetNotificationRequest { get; set; }

    public void showPopup() {
        displayPopUp = true;
    }
    
    public void closePopup() {
        displayPopUp = false;
    }
    
    public DemoPaymentNotificationController () {
        auth = new AttClientCredentialsAuthorization(ServiceConstants.ScopeType.PAYMENT);
        displayPopUp = false;
        isGetNotificationRequest  = true;
    }

    public List<AttNotificationIdRecord__c> getIdList(){
        List<AttNotificationIdRecord__c> idList = new List<AttNotificationIdRecord__c>();
        idList = [SELECT NotificationId__c, CreatedDate FROM AttNotificationIdRecord__c ORDER BY CreatedDate];        
        return idList;
    }
    
    public void getNotification() {
        AttPaymentNotification notification = new AttPaymentNotification(chosenId, auth);
        try {
            notificationDetails = notification.getNotification();
        } catch (AttException ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
            return; 
        }
        if (notificationDetails.getNotificationResponse != null) {
            RefundPriceAmount = '' + notificationDetails.getNotificationResponse.RefundPriceAmount;
            OriginalPriceAmount = '' + notificationDetails.getNotificationResponse.OriginalPriceAmount;
            RefundReasonId  = '' + notificationDetails.getNotificationResponse.RefundReasonId;   
            SubscriptionPeriodAmount  = '' + notificationDetails.getNotificationResponse.SubscriptionPeriodAmount;
            SubscriptionPeriod  = '' + notificationDetails.getNotificationResponse.SubscriptionPeriod; 
            SubscriptionRemaining  = '' + notificationDetails.getNotificationResponse.SubscriptionRemaining; 
        }
        isGettingSuccess  = '' + notificationDetails.IsSuccess;
        version =  notificationDetails.Version;
        isGetNotificationRequest  = true;
        displayPopUp = true;   
        debug = '' + notificationDetails;    
        
    }
    
    public void acknowledgeNotification() {
        AttPaymentNotification notification = new AttPaymentNotification(chosenId, auth);
        try {   
            acknowledgeResponse = notification.acknowledge();
        } catch (AttException ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
            return; 
        }  
        isGettingSuccess  = '' + acknowledgeResponse.IsSuccess;
        version =  acknowledgeResponse.Version;
        isGetNotificationRequest  = false; 
        displayPopUp = true; 
        debug = '' + acknowledgeResponse;    
    }
    
    public static testmethod void testController() {
    	String json = '{'+
        '    "GetNotificationResponse": {'+
        '        "NotificationType": "SuccesfulRefund",'+
        '        "TransactionDate": "2012-10-16T00:03:54Z",'+
        '        "OriginalTransactionId": "qICS6NsAH61ID8IpUorPhG4jXCeMYLG5KAZ5",'+
        '        "ConsumerId": "30eadde4-f26b-4f9b-92eb-6fb9172e86d3",'+
        '        "RefundPriceAmount": "1.15",'+
        '        "RefundCurrency": "USD",'+
        '        "RefundReasonId": "1",'+
        '        "RefundFreeText": "Customer was not happy",'+
        '        "RefundTransactionId": "qICS6NsARsQzYpmqb0XkEJWRkd85TFsj5XwW",'+
        '        "MerchantSubscriptionId": "015170205160",'+
        '        "OriginalPriceAmount": "1.15",'+
        '        "CurrentPeriodStartDate": "2012-10-16T00:02:45Z",'+
        '        "CurrentPeriodEndDate": "2012-11-16T00:02:44Z",        '+
        '        "SubscriptionPeriodAmount": "1",'+
        '        "SubscriptionPeriod": "2",'+
        '        "SubscriptionRecurrences": "3",'+
        '        "SubscriptionRemaining": "4"'+
        '    },'+
        '    "Version": "1",'+
        '    "IsSuccess": true'+
        '}';
        
    	Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(json));
    	TestHttpMockFactory.getCCAuthMock();
    	
        DemoPaymentNotificationController controller = new DemoPaymentNotificationController();
        
        controller.getNotification();
        
        System.assertEquals(ApexPages.getMessages().size(), 1);
        System.assertNotEquals(ApexPages.getMessages().get(0), null);
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Notification Id must be specified.');
        ApexPages.getMessages().clear();
        
        controller.chosenId = 'testId001';
        controller.getNotification();
        System.assert(controller.notificationDetails != null);
        System.assertEquals(controller.notificationDetails.Version, '1');
        System.assertEquals(controller.notificationDetails.IsSuccess, true);
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.NotificationType, 'SuccesfulRefund');
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.TransactionDate, Datetime.valueOf('2012-10-16 00:03:54'));
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.OriginalTransactionId, 'qICS6NsAH61ID8IpUorPhG4jXCeMYLG5KAZ5');
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.ConsumerId, '30eadde4-f26b-4f9b-92eb-6fb9172e86d3');
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.RefundPriceAmount, 1.15);
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.RefundCurrency, 'USD');
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.RefundReasonId, 1);
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.RefundFreeText, 'Customer was not happy');
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.RefundTransactionId, 'qICS6NsARsQzYpmqb0XkEJWRkd85TFsj5XwW');
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.MerchantSubscriptionId, '015170205160');
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.OriginalPriceAmount, 1.15);
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.CurrentPeriodStartDate, Datetime.valueOf('2012-10-16 00:02:45'));
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.CurrentPeriodEndDate, Datetime.valueOf('2012-11-16 00:02:44'));
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.SubscriptionPeriodAmount, 1);
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.SubscriptionPeriod, 2);
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.SubscriptionRecurrences, '3');
        System.assertEquals(controller.notificationDetails.GetNotificationResponse.SubscriptionRemaining, 4);
        
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{ "Version":"1","IsSuccess":true}'));
        controller.chosenId = '';
        controller.acknowledgeNotification();
        System.assertEquals(ApexPages.getMessages().size(), 1);
        System.assertNotEquals(ApexPages.getMessages().get(0), null);
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Notification Id must be specified.');
        
        controller.chosenId = 'testId0001';
        controller.acknowledgeNotification();
        
        System.assert(controller.acknowledgeResponse != null);
        System.assertEquals(controller.acknowledgeResponse.Version, '1');
        System.assertEquals(controller.acknowledgeResponse.IsSuccess, true);
        
        controller.showPopup();
        controller.closePopup();
        
        AttNotificationIdRecord__c notif = new AttNotificationIdRecord__c();
        notif.NotificationId__c = '32bd06c1-b6bd-4928-9afe-7ad5cbaf1b95';
        insert notif;
        
        List<AttNotificationIdRecord__c> idList = controller.getIdList();
        System.assert(idList!= null);
        System.assertEquals(idList.get(0).NotificationId__c, '32bd06c1-b6bd-4928-9afe-7ad5cbaf1b95');
    }
}