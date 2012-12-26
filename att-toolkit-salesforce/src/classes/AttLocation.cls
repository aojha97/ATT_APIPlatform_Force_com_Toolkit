/**
 * @description Base class for Location service, provides methods to invoke and retrieve results from AT&T Location services.
 */
public virtual class AttLocation {
	
	/**
	 * @description Authorization object.
	 */
	public AttCodeAuthorization auth { get; set; }	
		
	/**
	 * @description Constructs Location service with authorization object.
	 * @param auth authorization object.
	 */
	public AttLocation(AttCodeAuthorization auth) {
		this.auth = auth;
	}
	
	/**
	 * @description Constants for AT&T Location service types.
	 */
	public enum ServiceType { DEVICE_LOCATION, TERMINAL_LOCATION }
	
	/**
	 * @description Constants for request tolerance.
	 */
	public enum Tolerance { NoDelay, LowDelay, DelayTolerant }
	
	/**
 	 * @description Returns location for specified arguments.
 	 * One transaction to Location service is made. Transaction limits: https://devconnect-api.att.com/docs/att-apis/overview.
 	 * @param serviceType AT&T Location service type,
 	 * @param requestedAccuracy specifies the accuracy of the request, in meters.
 	 * @param tolerance specifies the priority of response time versus accuracy for the request.
 	 * @param acceptableAccuracy specifies the acceptable accuracy, in meters. 
 	 */
 	public virtual AttLocationResult getLocation(ServiceType serviceType, Integer requestedAccuracy, Tolerance tolerance, Integer acceptableAccuracy) {
 		checkRequestParameters(serviceType); 		
		String urlParameters = createUrlParameters(serviceType, requestedAccuracy, tolerance, acceptableAccuracy);
		HttpRequest request = createRequest(serviceType, urlParameters);
		HttpResponse response = UtilityFactory.getUtils().execute(request);   	
		return getLocation(serviceType, response);
	}
	
	/**
	 * Checks for location request parameters and throws corresponding error.
	 */
	protected virtual void checkRequestParameters(ServiceType serviceType) {
		if (serviceType == null) {
			throw new AttException('Service type must be specified.');
		}
	}
	
	/**
	 * Creates location request URL parameters string.
	 */	
	protected virtual String createUrlParameters(ServiceType serviceType, Integer requestedAccuracy, Tolerance tolerance, Integer acceptableAccuracy) {
		Map<String, String> parameters = new Map<String, String> {
			'requestedAccuracy' => (requestedAccuracy != null && requestedAccuracy > 0) ? String.valueOf(requestedAccuracy) : '',
			'tolerance' => tolerance == null ? '' : tolerance.name(), 
			'acceptableAccuracy' => (acceptableAccuracy != null && acceptableAccuracy > 0) ? String.valueOf(acceptableAccuracy) : '' };
		if (AttLocation.ServiceType.TERMINAL_LOCATION == serviceType) {
			parameters.put('address', 'acr:authorization');
		}
		return UtilityFactory.getUtils().createUrlParametersString(parameters);
	}
		
	/**
	 * Returns location service request.
	 */
	protected virtual HttpRequest createRequest(ServiceType serviceType, String urlParameters) {
		ServiceConstants.ServiceType requestServiceType = (AttLocation.ServiceType.DEVICE_LOCATION == serviceType ? ServiceConstants.ServiceType.DEVICE_LOCATION : ServiceConstants.ServiceType.TERMINAL_LOCATION);
		HttpRequest request = UtilityFactory.getHttpClient().createRequest(requestServiceType, urlParameters);
		request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + auth.getAccessToken());
        request.setHeader('Accept', 'application/json');
        request.setHeader('Connection', 'Keep-Alive');
        return request;
	}
	
	/**
	 * Handles result from AT&T Location service.
	 */
	protected virtual AttLocationResult getLocation(ServiceType serviceType, HttpResponse response) {
		String json = response.getBody();
		if (AttLocation.ServiceType.DEVICE_LOCATION == serviceType) {
			return AttDeviceLocationResult.parse(json);
		} else {
			return AttTerminalLocationResult.parse(json);
		}
	}
}