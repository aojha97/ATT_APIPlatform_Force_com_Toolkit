/*
 * @description Class allow defining of notification callback for processing incomming notification IDs
 * 
 * For implement incomming notifications processing user should 
 * 1) Inherit this class and override method processNotification(List<String> notificationIdList). Method
 *    implementation can contain any custom logic, like persisting IDs as objects and getting notification details
 * 2) Create REST callback, define doPost() method where instantiate class defined in previous step.
 * 
 * See DemoPaymentNotificationController for example.
 */
public abstract class AttNotificationCallbackProcessor {
	
	/**
     * @description Creates new instance of AttNotificationCallbackProcessor which 
     * encapsulates notification IDs from callback and passes to processNotification() abstract method.
     */
	public AttNotificationCallbackProcessor() {
	    RestRequest req = RestContext.request;
        String xml = req.requestBody.toString();
        
        List<String> notificationIdList = new List<String>();
        
        DOM.Document doc = new DOM.Document();
        try {
            doc.load(xml);
            DOM.XMLNode root = doc.getRootElement();
            List<DOM.XMLNode> childList = root.getChildElements();
        
            for (DOM.XMLNode node : childList) {
                if(node.getName() == 'NotificationId'){
                    notificationIdList.add(node.getText());
                }
            }
        } catch (System.XMLException e) {  // invalid XML
            throw new AttException('Wrong notification xml: ' + xml, e);
        }
        
        processNotification(notificationIdList);
	}
	
	/**
     * @description You need to override this method and implement there your custom logic
     * @param notificationIdList list with notification IDs obtained from callback request
     */
	public abstract void processNotification(List<String> notificationIdList);

}