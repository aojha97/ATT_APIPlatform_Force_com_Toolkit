/**
 * @description Provides common implementation of Utils interface.
 */
public interface Utils {
	
	/**
	 * @description Converts map to url parameters string and add it to specified url.
	 * @param url URL.
	 * @param parameters map with parameters.
	 * @return URL with added parameters. 
	 */
	String addParametersToUrl(String url, Map<String, String> parameters);
	
	/**
	 * @description Converts map to url parameters string, encode string and add it to specified url
	 * @param url URL.
	 * @param parameters map with parameters.
	 * @param encodeParametersString pass true to encode URL parameters with Encodingutil.urlEncode(...) method.
	 * @return URL with added parameters.
	 */	
	String addParametersToUrl(String url, Map<String, String> parameters, boolean encodeParametersString);
	
	/**
	 * @description Converts map to url parameters string. Add '?' to the beginning of the line. Parameters with empty or null values excluded from result.
	 * @param parameters map with parameters.
	 * @return url parameters string with leading '?' symbol, or empty string for empty parameters.
	 */	
	String createUrlParametersString(Map<String, String> parameters);
	
	/**
	 * @description Converts map to url string, each pair of key=value splitted with '&' symbol`. Parameters with empty or null values excluded from result.
	 * @param parameters map with parameters.
	 * @return url parameters string, or empty string for empty parameters.
	 */
	String convertMapToParametersString(Map<String, String> parameters);
	
	/**
     * @description Executes HTTP request and checks status code of response for common errors.
     * @param request HTTP request
     * @return HTTP response.
     */
    HttpResponse execute(HttpRequest request);
}