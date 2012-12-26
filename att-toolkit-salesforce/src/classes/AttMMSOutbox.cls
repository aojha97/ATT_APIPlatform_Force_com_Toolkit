/**
 @description This service for sending MMS. 
 
 Usage example:
 
	//Prepare MMS
	AttAttachment attachment = new AttAttachment(fileContentBlob, 'file.txt', 'text/txt');
	AttMMS message = new AttMMS();
	message.phoneNumber = '4258028620';
	message.subject = 'test';		
	message.attachments.add(attachment); 
 
 	//send MMS
 	AttMMSOutbox box = new AttMMSOutbox();
 	AttMMSOutboxStatus sendStatus = box.sendMessage(message);
 	
 	//check delivery status
 	AttMMSDeliveryStatus deliveryStatus = sendStatus.getDeliveryStatus();
 */
public virtual class AttMMSOutbox {
    
    /**
     * @description Authorization provider. Usually it should be set through AttMMSOutbox constructor,
     * but you can redefime it if you need.
     */
    public AttClientCredentialsAuthorization auth { get; set; }
    
   	protected HttpClient client { get; set; }
   	
   	/**
     * @description Create new MMS Outbox service
     *
     * @param auth authorization provider
     */
   	public AttMMSOutbox(AttClientCredentialsAuthorization auth) {   		
   		client = UtilityFactory.getHttpClient();
   		this.auth = auth;
   	}
    
    /**
     * @description Perform call to AT&T services and send MMS.
     * One transaction to MMS Send service is made. Transaction limits: https://devconnect-api.att.com/docs/att-apis/overview
     *
     * @param AttMMS message mms message
     * @return AttMMSOutboxStatus that can be used directly for getting delivery status
     */
    public AttMMSOutboxStatus sendMessage(AttMMS message){
        String phoneNumber = message.phoneNumber;
        String subject = message.subject;
        
        if (phoneNumber == null || phoneNumber == '') {
            throw new AttException('Phone number must be specified.'); 
        }
        
        if (subject == null || subject == '') {
            throw new AttException('Subject must be specified.'); 
        }
        
        if (message.attachments == null || message.attachments.isEmpty()) {
            throw new AttException('No file has been attached.'); 
        } 
        
        String accessToken = getAuth().getAccessToken();
        
		HttpRequest req = client.createRequest(ServiceConstants.ServiceType.SEND_MMS);
        req.setMethod('POST'); 
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Accept', 'application/json');
        req.setHeader('MIME-Version', '1.0');
        
        
        String boundary = getBoundary();        
        req.setHeader('Content-Type', 'multipart/related; type="application/json"; start="<startpart>"; boundary="' + boundary +'"');
        
        
        String reqText = '--' + boundary + '\n' + 
        'Content-Type: application/json; charset=UTF-8\n' + 
        'Content-Transfer-Encoding: 8bit\n' +
        'Content-ID: <startpart>\n' + 
        '\n' +
		'{ "Address" : "tel:' + phoneNumber +'", "Subject" : "' + subject +'", "Priority": "High" }\n';
				
		reqText += prepareAttachments(message.attachments, boundary);		
		reqText += '--' + boundary + '\n';
		
		req.setHeader('Content-Length', String.valueOf(reqText.length()));
		req.setBody(reqText);
		
        HTTPResponse resp = client.sendRequest(req);
        
        UtilityFactory.getRestErrorHandler().checkResponseCode(resp);
        return new AttMMSOutboxStatus(resp.getBody(), getAuth());
    }
    
    /**
     * @description Use this method to restore MMS from persistent objects.
     * @param String id
     * @return AttMMSOutboxStatus for specific MMS id. Result object can then be used to get MMS status.  
     */ 
    public AttMMSOutboxStatus restoreOutboxStatusByMMSId(String id) {
    	String url = ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.SEND_MMS) + '/' + id;
    	return new AttMMSOutboxStatus(id, url, getAuth());
    }
        
    private static String prepareAttachments(List<AttAttachment> attachments, String boundary) {
    	String rez = '';
    	for (AttAttachment attachment : attachments) {
    		rez += '--' + boundary + '\n' +
    		attachment.toHttpRequestPart(attachment.fileName);
    	}
    	return rez;
    }
    
    private static String getBoundary() {
    	Datetime dt = DateTime.now();
		return '----=_Part_0_1' + Math.round((Math.random() * 10000000));

	}
	
	private AttClientCredentialsAuthorization getAuth() {
		if (auth == null) throw new AttException('You need to define auth provider useing constructror parameter or field "auth"');
		return auth;
	}
}