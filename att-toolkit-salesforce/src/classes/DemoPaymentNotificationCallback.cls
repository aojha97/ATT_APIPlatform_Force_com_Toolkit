@RestResource(urlMapping='/NotificationCallback')
global class DemoPaymentNotificationCallback {  
    
    public class NotificationCallbackProcessor extends AttNotificationCallbackProcessor {
        public Response resp;
                
        public override void processNotification (List<String> notificationIdList){
            resp = new Response();
            resp.IdsHandled = 0;
            for (String id : notificationIdList) {
                AttNotificationIdRecord__c notification = new AttNotificationIdRecord__c();
                notification.NotificationId__c = id;
                insert notification;
                resp.IdsHandled++;
            }
            resp.IsSuccess = true;
        }
    }
    
    @HttpGet
    global static String doGet() {        
        return 'Your request has been processed';      
    }
    
    @HttpPost
    global static Response doPost() {
        
        RestRequest req = RestContext.request;        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{'dgruzda@exadel.com'});
        mail.setSubject('Notification forwarding');
        mail.setPlainTextBody(req.requestBody.toString());
        Messaging.sendEmail(new Messaging.Email[]{mail});
        
        NotificationCallbackProcessor notProcessor = new NotificationCallbackProcessor();
        return notProcessor.resp;
    }
    
    global class Response {
        public Boolean IsSuccess {get; set;}
        public Integer IdsHandled {get; set;}
    }
    
    public static testmethod void testController() {
    	RestContext.request = new RestRequest(); 
        RestContext.request.requestBody = Blob.valueOf('<Notifications> <NotificationId>728dc361-8b4f-4acc-ad2d-9a63125c5114</NotificationId> </Notifications>');
        doPost();
        List<AttNotificationIdRecord__c> idList = [SELECT NotificationId__c, CreatedDate FROM AttNotificationIdRecord__c ORDER BY CreatedDate];  
        System.assert(idList.size() == 1);
        System.assertEquals(idList.get(0).NotificationId__c, '728dc361-8b4f-4acc-ad2d-9a63125c5114');
        
        doGet();
    }
}