/*
 * @description Base class for Payment Notification service, provides methods to invoke and retrieve results from AT&T Notification services.
 */
public virtual class AttPaymentNotification {
	
	/**
     * @description Authorization object.
     */
	public AttClientCredentialsAuthorization auth{ get; set; }
	
	/**
     * @description Notification ID for given object. Read only.
     */
	public String notificationId { get; private set; }
	
	/*
     * @description Initializes payment notification object for specific notification Id.
     * @param payload notification Id retrieved by notification callback.
	 * @param auth instance for client authentication.
     */
	public AttPaymentNotification(String notificationId, AttClientCredentialsAuthorization auth){
	   this.notificationId = notificationId;
	   this.auth = auth;
	} 
	
	/*
     * @description Gets notification details from server for a particular notification Id.
     * @param auth Authorization instance.
     * @return notification details object.
     */
	public virtual AttPaymentNotificationDetails getNotification() {
		if (String.isBlank(notificationId)) {
            throw new AttException('Notification Id must be specified.'); 
        }
		HttpRequest req = UtilityFactory.getHttpClient().createRequest(ServiceConstants.ServiceType.GET_NOTIFICATION, notificationId);
        req.setMethod('GET'); 
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + auth.getAccessToken());
        HttpResponse resp = execute(req);   
                
        return AttPaymentNotificationDetails.parse(resp.getBody());
	} 
	
	/*
     * @description Acknowledges the receipt of a notification and requests that further notifications be stopped for a particular notification Id.
     * @param auth Authorization instance.
     * @return acknowledge details object.
     */
	public virtual AttNotificationAcknowledgeResponse acknowledge() {
		if (String.isBlank(notificationId)) {
            throw new AttException('Notification Id must be specified.'); 
        }
		HttpRequest req = UtilityFactory.getHttpClient().createRequest(ServiceConstants.ServiceType.ACKNOLEDGE_NOTIFICATION, notificationId);
        
        req.setMethod('PUT'); 
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + auth.getAccessToken());
        req.setHeader('Content-Length', '0');
        HttpResponse resp = execute(req);
                
        return AttNotificationAcknowledgeResponse.parse(resp.getBody());
    }
    
    protected virtual HttpResponse execute(HttpRequest request) {
    	HttpResponse response = UtilityFactory.getHttpClient().sendRequest(request);   
        UtilityFactory.getRestErrorHandler().checkServiceErrorResponce(response);     
        UtilityFactory.getRestErrorHandler().checkResponseCode(response);
        return response;  
    }

}