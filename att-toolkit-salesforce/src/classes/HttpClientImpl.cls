/**
 * @description Provides common implementation of HttpClient interface.
 */ 
public virtual class HttpClientImpl implements HttpClient {
	
	/**
	 * @description Creates HTTP request with end point for specified service type. 
	 * Throws AttException with create request errors.
	 * @param serviceType service type.
	 * @returns HTTP request.
	 */	
	public virtual HttpRequest createRequest(ServiceConstants.ServiceType serviceType) {
		return createRequest(serviceType, ''); 
	}
	
	/**
	 * @description Creates multi-part HTTP request with end point for specified service type. 
	 * Throws AttException with create request errors.
	 * @param serviceType service type.
	 * @returns HTTP request.
	 */	
	public virtual MultipartHttpRequest createMultipartRequest(ServiceConstants.ServiceType serviceType) {
		return createMultipartRequest(serviceType, '');
	}
	
	/**
	 * @description Creates HTTP request with end point for specified service type and URL parameters.
	 * Throws AttException with create request errors.	 
	 * @param serviceType service type.
	 * @param urlParameters map with URL parameters.
	 * @returns HTTP request.
	 */	
	public virtual HttpRequest createRequest(ServiceConstants.ServiceType serviceType, Map<String, String> urlParameters) {
		String url = UtilityFactory.getUtils().addParametersToUrl(ServiceConstants.getUrlByServiceType(serviceType), urlParameters);
		return createRequest(url);
	}
	
	/**
	 * @description Creates HTTP request with end point for specified service type and URL parameters.
	 * Throws AttException with create request errors.	 
	 * @param serviceType service type.
	 * @param urlParameters string with URL parameters.
	 * @returns HTTP request.
	 */
	public virtual HttpRequest createRequest(ServiceConstants.ServiceType serviceType, String urlParameters) {
		if (serviceType == null) {
			throw new AttException('HttpClientImpl.createRequest: serviceType is null');
		}
		return createRequest(ServiceConstants.getUrlByServiceType(serviceType) + (urlParameters == null ? '' : urlParameters));
	}
	
	/**
	 * @description Creates HTTP request with end point specified by URL.
	 * Throws AttException with create request errors.	 
	 * @param url URL.
	 * @returns HTTP request.
	 */		
	public virtual HttpRequest createRequest(String url) {
		HttpRequest request = new HttpRequest();        
        request.setEndpoint(url);
        request.setTimeout(ServiceConstants.REQUEST_TIME_OUT);        
        return request;
	} 
	
	/**
	 * @description Creates multi-part HTTP request with end point for specified service type and URL parameters. 
	 * Throws AttException with create request errors.
	 * @param serviceType service type.
	 * @returns HTTP request.
	 */	
	public virtual MultipartHttpRequest createMultipartRequest(ServiceConstants.ServiceType serviceType, String urlParameters) {
		if (serviceType == null) {
			throw new AttException('HttpClientImpl.createRequest: serviceType is null');
		}
		
		return new MultipartHttpRequest(ServiceConstants.getUrlByServiceType(serviceType) +
			(urlParameters == null ? '' : urlParameters),ServiceConstants.REQUEST_TIME_OUT);
	}
	
	/**
	 * @description Sends request and returns responce. Throws AttException when sending errors occurs.
	 * @param request HTTP request.
	 * @return HTTP response.
	 */	
	public virtual HttpResponse sendRequest(HttpRequest request) {
		if (request == null) {
			throw new AttException('HttpClientImpl.sendRequest: request is null');
		}

        return new Http().send(request);
	}
	
	public static testmethod void testClient() {
		HttpClient client = new HttpClientImpl();

		try {
			for (ServiceConstants.ServiceType stype : ServiceConstants.ServiceType.values()) {
				HttpRequest request = client.createRequest(stype);
				System.assertNotEquals(null, request);
			}
		} catch (AttException ex) {
			System.assertEquals('ServiceConstants.getUrlByServiceType: serviceType is null', ex.getMessage());
		}
		
		try {
			client.sendRequest((HttpRequest)null);
		} catch (AttException ex) {
			System.assertEquals('HttpClientImpl.sendRequest: request is null', ex.getMessage());
		}
		
		// test createRequest(ServiceConstants.ServiceType serviceType, Map<String, String> urlParameters) function
		Map<String, String> params = new Map<String, String> {
			'param1' => 'value1',
			'param2' => 'value2'
		};
		Httprequest request = client.createRequest(ServiceConstants.ServiceType.TERMINAL_LOCATION, params);
		String endPoint = request.getEndpoint();
		System.assert(endPoint.startsWith('https://api.att.com/gsma/2/location/queries/location'));
		System.assert(endPoint.contains('param1=value1'));
		System.assert(endPoint.contains('param2=value2'));
	}
}