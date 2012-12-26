/*
 * @description AttDeviceCapabilitiesService provides methods to invoke and retrieve results from AT&T Device Capabilities REST services
 */
public virtual class AttDeviceCapabilitiesService {
	/**
     * @description Authorization object.
     */
	public AttCodeAuthorization auth{ get; set; }
	
	protected HttpClient httpClient { get; set; }
	
   /*
    * @description Default constructor for AttDeviceCapabilitiesService.
    * @param auth instance for client authentication.
    */
	public AttDeviceCapabilitiesService(AttCodeAuthorization auth) {
		httpClient = UtilityFactory.getHttpClient();
		this.auth = auth;
	}
	
	/*
     * @description Invokes AT&T GET Device Capabilities REST service and handle result 
     * @return the device capabilities returned from the AT&T server.
     */	
	public virtual AttDeviceCapabilities getDeviceCapabilities() {
        HttpRequest req = httpClient.createRequest(ServiceConstants.ServiceType.GET_DEVICE_CAPABILITIES);
        Http http = new Http();
        req.setMethod('GET'); 
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + auth.getAccessToken());        
        HttpResponse resp;
        resp = httpClient.sendRequest(req);
        UtilityFactory.getRestErrorHandler().checkResponseCode(resp);     
        return AttDeviceCapabilities.parse(resp.getBody());
	}

}