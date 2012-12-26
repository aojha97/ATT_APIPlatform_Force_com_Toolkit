/**
 * @description Provides methods to create HTTP request and retrieve HTTP response. 
 */
public interface HttpClient {
	
	/**
	 * @description Creates HTTP request with end point for specified service type. 
	 * Throws AttException with create request errors.
	 * @param serviceType service type.
	 * @returns HTTP request.
	 */
	HttpRequest createRequest(ServiceConstants.ServiceType serviceType);

	/**
	 * @description Creates HTTP request with end point for specified service type and URL parameters.
	 * Throws AttException with create request errors.	 
	 * @param serviceType service type.
	 * @param urlParameters map with URL parameters.
	 * @returns HTTP request.
	 */
	HttpRequest createRequest(ServiceConstants.ServiceType serviceType, Map<String, String> urlParameters);
	
	/**
	 * @description Creates HTTP request with end point for specified service type and URL parameters.
	 * Throws AttException with create request errors.	 
	 * @param serviceType service type.
	 * @param urlParameters string with URL parameters.
	 * @returns HTTP request.
	 */
	HttpRequest createRequest(ServiceConstants.ServiceType serviceType, String urlParameters);
	
	/**
	 * @description Creates HTTP request with end point specified by URL.
	 * Throws AttException with create request errors.	 
	 * @param url URL.
	 * @returns HTTP request.
	 */	
	HttpRequest createRequest(String url);
	
	/**
	 * @description Sends request and returns responce. Throws AttException when sending errors occurs.
	 * @param request HTTP request.
	 * @return HTTP response.
	 */
	HttpResponse sendRequest(HttpRequest request);
	
	/**
	 * @description Creates multi-part HTTP request with end point for specified service type. 
	 * Throws AttException with create request errors.
	 * @param serviceType service type.
	 * @returns HTTP request.
	 */
	MultipartHttpRequest createMultipartRequest(ServiceConstants.ServiceType serviceType);
	
	/**
	 * @description Creates multi-part HTTP request with end point for specified service type and URL parameters. 
	 * Throws AttException with create request errors.
	 * @param serviceType service type.
	 * @returns HTTP request.
	 */	
	MultipartHttpRequest createMultipartRequest(ServiceConstants.ServiceType serviceType, String urlParameters); // throws AttException
}