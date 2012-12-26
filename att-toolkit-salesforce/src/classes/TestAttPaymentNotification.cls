@isTest
public class TestAttPaymentNotification {
	public static AttClientCredentialsAuthorization auth;
    public static MultiStaticResourceCalloutMock mock;
    
    static {
        auth = TestHttpMockFactory.getCCAuthMock();
    }	
	
	static testmethod void testGetNotification() {
		AttPaymentNotification notification = new AttPaymentNotification('', auth);
		
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(
        '{'+
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
        '}'));
        
        AttPaymentNotificationDetails details;
        try {
            details = notification.getNotification(); 
        } catch (AttException ex){
            System.assertEquals(ex.getMessage(), 'Notification Id must be specified.');
        }
        
		notification = new AttPaymentNotification('testNotificationId', auth);
		details = notification.getNotification();
		System.assert(details != null);
        System.assertEquals(details.Version, '1');
        System.assertEquals(details.IsSuccess, true);
        System.assertEquals(details.GetNotificationResponse.NotificationType, 'SuccesfulRefund');
        System.assertEquals(details.GetNotificationResponse.TransactionDate, Datetime.valueOf('2012-10-16 00:03:54'));
        System.assertEquals(details.GetNotificationResponse.OriginalTransactionId, 'qICS6NsAH61ID8IpUorPhG4jXCeMYLG5KAZ5');
        System.assertEquals(details.GetNotificationResponse.ConsumerId, '30eadde4-f26b-4f9b-92eb-6fb9172e86d3');
        System.assertEquals(details.GetNotificationResponse.RefundPriceAmount, 1.15);
        System.assertEquals(details.GetNotificationResponse.RefundCurrency, 'USD');
        System.assertEquals(details.GetNotificationResponse.RefundReasonId, 1);
        System.assertEquals(details.GetNotificationResponse.RefundFreeText, 'Customer was not happy');
        System.assertEquals(details.GetNotificationResponse.RefundTransactionId, 'qICS6NsARsQzYpmqb0XkEJWRkd85TFsj5XwW');
        System.assertEquals(details.GetNotificationResponse.MerchantSubscriptionId, '015170205160');
        System.assertEquals(details.GetNotificationResponse.OriginalPriceAmount, 1.15);
        System.assertEquals(details.GetNotificationResponse.CurrentPeriodStartDate, Datetime.valueOf('2012-10-16 00:02:45'));
        System.assertEquals(details.GetNotificationResponse.CurrentPeriodEndDate, Datetime.valueOf('2012-11-16 00:02:44'));
        System.assertEquals(details.GetNotificationResponse.SubscriptionPeriodAmount, 1);
        System.assertEquals(details.GetNotificationResponse.SubscriptionPeriod, 2);
        System.assertEquals(details.GetNotificationResponse.SubscriptionRecurrences, '3');
        System.assertEquals(details.GetNotificationResponse.SubscriptionRemaining, 4);
		
	}
	
	static testmethod void testAcknowledgeNotification() {
        AttPaymentNotification notification = new AttPaymentNotification('', auth);
        
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{ "Version":"1", "IsSuccess":true}'));
        AttNotificationAcknowledgeResponse acknowledge;
        try {
            acknowledge = notification.acknowledge();
        } catch (AttException ex){
            System.assertEquals(ex.getMessage(), 'Notification Id must be specified.');
        }
        
        notification = new AttPaymentNotification('testNotificationId', auth);
        
        acknowledge = notification.acknowledge();
        System.assert(acknowledge != null);
        System.assertEquals(acknowledge.Version, '1');
        System.assertEquals(acknowledge.IsSuccess, true);
    }
}