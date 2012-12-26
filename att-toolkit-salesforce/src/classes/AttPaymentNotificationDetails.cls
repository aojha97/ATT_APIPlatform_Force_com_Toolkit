/*
 * @description AttPaymentNotificationDetails holds information about notification details.
 */
public virtual class AttPaymentNotificationDetails {
	
    /*
    * @description Notification response object.
    */
    public class GetNotificationResponse {
    	/*
         * @description Specifies the notification type.
         */
        public String NotificationType  {get; set;}
        
        /*
         * @description Specifies the date and time that the refund transaction occurred.
         */
        public DateTime TransactionDate  {get; set;}
        
        /*
         * @description Specifies the transaction ID of the original transaction.
         */
        public String OriginalTransactionId  {get; set;}
        
        /*
         * @description Specifies the ID associated with the transaction.
         */
        public String ConsumerId  {get; set;}
        
        /*
         * @description Specifies the amount refunded.
         */
        public Decimal RefundPriceAmount  {get; set;}
        
        /*
         * @description Specifies the currency of the refund.
         */
        public String RefundCurrency  {get; set;}
        
        /*
         * @description Specifies the reason code for the refund.
         */
        public Integer RefundReasonId  {get; set;}
        
        /*
         * @description Specifies the text description of the reason for the refund.
         */
        public String RefundFreeText  {get; set;}
        
        /*
         * @description Specifies the transaction identifier of the refunded transaction.
         */
        public String RefundTransactionId  {get; set;}
        
        /*
         * @description Specifies the merchant subscription ID specified in the New Subscription method.
         */
        public String MerchantSubscriptionId  {get; set;}
        
        /*
         * @description Specifies the price of the original transaction.
         */
        public Decimal OriginalPriceAmount  {get; set;}
        
        /*
         * @description Specifies the start date for the current subscription period.
         */
        public DateTime CurrentPeriodStartDate  {get; set;}
        
        /*
         * @description Specifies the end date for the current subscription period.
         */
        public DateTime CurrentPeriodEndDate  {get; set;}
        
        /*
         * @description Specifies the number of remaining subscription periods.
         */
        public Integer SubscriptionPeriodAmount  {get; set;}
        
        /*
         * @description Specifies the time unit for the subscription period.
         */
        public Integer SubscriptionPeriod  {get; set;}
        
        /*
         * @description Specifies the number of renewals for subscription.
         */
        public String SubscriptionRecurrences  {get; set;}
        
        /*
         * @description Specifies the remaining number of renewals for the subscription.
         */
        public Integer SubscriptionRemaining  {get; set;}
    }
    
    
    /*
     * @description Object, containing summary information of notification.
     */        
    public GetNotificationResponse getNotificationResponse  {get; set;}
    
    /*
     * @description Version of the API signature.
     */        
    public String Version  {get; set;}
    
    /*
     * @description  A flag indicating the status of the request.
     */        
    public Boolean IsSuccess  {get; set;}
    
    /*
     * @description Parses JSON string into class fields.
     * @param json A JSON string as responce of get notification details service.
     * @return parsed notification details object.
     */
    public static AttPaymentNotificationDetails parse(String json) {
    	Map<String, Object> fieldMap = (Map<String, Object>)System.JSON.deserializeUntyped(json);
    	
    	AttPaymentNotificationDetails details = new AttPaymentNotificationDetails();
    	
    	details.Version = (String)fieldMap.get('Version');
    	
    	if (fieldMap.get('IsSuccess') != null) {
            details.IsSuccess = Boolean.valueOf(fieldMap.get('IsSuccess'));
        }
        
        if (fieldMap.get('GetNotificationResponse') != null) {
            Map<String, Object> notifMap = (Map<String, Object>)fieldMap.get('GetNotificationResponse');
            
            details.GetNotificationResponse = new GetNotificationResponse();
            details.GetNotificationResponse.NotificationType = (String)notifMap.get('NotificationType');            
            
            if (notifMap.get('TransactionDate') != null && !String.isBlank((String)notifMap.get('TransactionDate'))) {
				details.GetNotificationResponse.TransactionDate = Datetime.valueOf(prepareDate((String)notifMap.get('TransactionDate')));
			}
            
            details.GetNotificationResponse.OriginalTransactionId = (String)notifMap.get('OriginalTransactionId');
            details.GetNotificationResponse.ConsumerId = (String)notifMap.get('ConsumerId');
            
            if (notifMap.get('RefundPriceAmount') != null && !String.isBlank((String)notifMap.get('RefundPriceAmount'))) {
                details.GetNotificationResponse.RefundPriceAmount = Decimal.valueOf((String)notifMap.get('RefundPriceAmount'));
            }
            
            details.GetNotificationResponse.RefundCurrency = (String)notifMap.get('RefundCurrency');
            
            if (notifMap.get('RefundReasonId') != null && !String.isBlank((String)notifMap.get('RefundReasonId'))) {
                details.GetNotificationResponse.RefundReasonId = Integer.valueOf(notifMap.get('RefundReasonId'));
            }
            
            details.GetNotificationResponse.RefundFreeText = (String)notifMap.get('RefundFreeText');
            details.GetNotificationResponse.RefundTransactionId = (String)notifMap.get('RefundTransactionId');
            details.GetNotificationResponse.MerchantSubscriptionId = (String)notifMap.get('MerchantSubscriptionId');
            
            if (notifMap.get('OriginalPriceAmount') != null && !String.isBlank((String)notifMap.get('OriginalPriceAmount'))) {
                details.GetNotificationResponse.OriginalPriceAmount = Decimal.valueOf((String)notifMap.get('OriginalPriceAmount'));
            }
            
            if (notifMap.get('CurrentPeriodStartDate') != null && !String.isBlank((String)notifMap.get('CurrentPeriodStartDate'))) {
				details.GetNotificationResponse.CurrentPeriodStartDate = Datetime.valueOf(prepareDate((String)notifMap.get('CurrentPeriodStartDate')));
			}
			
			if (notifMap.get('CurrentPeriodEndDate') != null && !String.isBlank((String)notifMap.get('CurrentPeriodEndDate'))) {
				details.GetNotificationResponse.CurrentPeriodEndDate = Datetime.valueOf(prepareDate((String)notifMap.get('CurrentPeriodEndDate')));
			}
            
            if (notifMap.get('SubscriptionPeriodAmount') != null && !String.isBlank((String)notifMap.get('SubscriptionPeriodAmount'))) {
                details.GetNotificationResponse.SubscriptionPeriodAmount = Integer.valueOf(notifMap.get('SubscriptionPeriodAmount'));
            }
            
            if (notifMap.get('SubscriptionPeriod') != null && !String.isBlank((String)notifMap.get('SubscriptionPeriod'))) {
                details.GetNotificationResponse.SubscriptionPeriod = Integer.valueOf(notifMap.get('SubscriptionPeriod'));
            }
            
            details.GetNotificationResponse.SubscriptionRecurrences = (String)notifMap.get('SubscriptionRecurrences');
            
            if (notifMap.get('SubscriptionRemaining') != null && !String.isBlank((String)notifMap.get('SubscriptionRemaining'))) {
                details.GetNotificationResponse.SubscriptionRemaining = Integer.valueOf(notifMap.get('SubscriptionRemaining'));
            }
        }
    	return details;
    }
    
    private static String prepareDate(String dTime){
		return dTime.replace('T', ' ').replace('Z', '');
	}
    
    static testMethod void testParse() {
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
        AttPaymentNotificationDetails obj = parse(json);
        System.assert(obj != null);
        System.assertEquals(obj.Version, '1');
        System.assertEquals(obj.IsSuccess, true);
        System.assertEquals(obj.GetNotificationResponse.NotificationType, 'SuccesfulRefund');
        System.assertEquals(obj.GetNotificationResponse.TransactionDate, Datetime.valueOf('2012-10-16 00:03:54'));
        System.assertEquals(obj.GetNotificationResponse.OriginalTransactionId, 'qICS6NsAH61ID8IpUorPhG4jXCeMYLG5KAZ5');
        System.assertEquals(obj.GetNotificationResponse.ConsumerId, '30eadde4-f26b-4f9b-92eb-6fb9172e86d3');
        System.assertEquals(obj.GetNotificationResponse.RefundPriceAmount, 1.15);
        System.assertEquals(obj.GetNotificationResponse.RefundCurrency, 'USD');
        System.assertEquals(obj.GetNotificationResponse.RefundReasonId, 1);
        System.assertEquals(obj.GetNotificationResponse.RefundFreeText, 'Customer was not happy');
        System.assertEquals(obj.GetNotificationResponse.RefundTransactionId, 'qICS6NsARsQzYpmqb0XkEJWRkd85TFsj5XwW');
        System.assertEquals(obj.GetNotificationResponse.MerchantSubscriptionId, '015170205160');
        System.assertEquals(obj.GetNotificationResponse.OriginalPriceAmount, 1.15);
        System.assertEquals(obj.GetNotificationResponse.CurrentPeriodStartDate, Datetime.valueOf('2012-10-16 00:02:45'));
        System.assertEquals(obj.GetNotificationResponse.CurrentPeriodEndDate, Datetime.valueOf('2012-11-16 00:02:44'));
        System.assertEquals(obj.GetNotificationResponse.SubscriptionPeriodAmount, 1);
        System.assertEquals(obj.GetNotificationResponse.SubscriptionPeriod, 2);
        System.assertEquals(obj.GetNotificationResponse.SubscriptionRecurrences, '3');
        System.assertEquals(obj.GetNotificationResponse.SubscriptionRemaining, 4);
        
        json = '{'+
        '    "GetNotificationResponse": {'+
        '        "NotificationType": "",'+
        '        "TransactionDate": "",'+
        '        "OriginalTransactionId": "",'+
        '        "ConsumerId": "",'+
        '        "RefundPriceAmount": "",'+
        '        "RefundCurrency": "",'+
        '        "RefundReasonId": "",'+
        '        "RefundFreeText": "",'+
        '        "RefundTransactionId": "",'+
        '        "MerchantSubscriptionId": "",'+
        '        "OriginalPriceAmount": "",'+
        '        "CurrentPeriodStartDate": "",'+
        '        "CurrentPeriodEndDate": "",        '+
        '        "SubscriptionPeriodAmount": "",'+
        '        "SubscriptionPeriod": "",'+
        '        "SubscriptionRecurrences": "",'+
        '        "SubscriptionRemaining": ""'+
        '    },'+
        '    "Version": "",'+
        '    "IsSuccess": null'+
        '}';
        obj = parse(json);
        System.assert(obj != null);
        System.assertEquals(obj.Version, '');
        System.assertEquals(obj.IsSuccess, null);
        System.assertEquals(obj.GetNotificationResponse.NotificationType, '');
        System.assertEquals(obj.GetNotificationResponse.TransactionDate, null);
        System.assertEquals(obj.GetNotificationResponse.OriginalTransactionId, '');
        System.assertEquals(obj.GetNotificationResponse.ConsumerId, '');
        System.assertEquals(obj.GetNotificationResponse.RefundPriceAmount, null);
        System.assertEquals(obj.GetNotificationResponse.RefundCurrency, '');
        System.assertEquals(obj.GetNotificationResponse.RefundReasonId, null);
        System.assertEquals(obj.GetNotificationResponse.RefundFreeText, '');
        System.assertEquals(obj.GetNotificationResponse.RefundTransactionId, '');
        System.assertEquals(obj.GetNotificationResponse.MerchantSubscriptionId, '');
        System.assertEquals(obj.GetNotificationResponse.OriginalPriceAmount, null);
        System.assertEquals(obj.GetNotificationResponse.CurrentPeriodStartDate, null);
        System.assertEquals(obj.GetNotificationResponse.CurrentPeriodEndDate, null);
        System.assertEquals(obj.GetNotificationResponse.SubscriptionPeriodAmount, null);
        System.assertEquals(obj.GetNotificationResponse.SubscriptionPeriod, null);
        System.assertEquals(obj.GetNotificationResponse.SubscriptionRecurrences, '');
        System.assertEquals(obj.GetNotificationResponse.SubscriptionRemaining, null);
    }
}