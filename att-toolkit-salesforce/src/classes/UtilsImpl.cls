/**
 * @description Provides utilities methods.
 */
public virtual class UtilsImpl implements Utils {
	
	/**
	 * @description Converts map to url parameters string and add it to specified url.
	 * @param url URL.
	 * @param parameters map with parameters.
	 * @return URL with added parameters. 
	 */
	public virtual String addParametersToUrl(String url, Map<String, String> parameters) {
		return addParametersToUrl(url, parameters, false);
	}
	
	/**
	 * @description Converts map to url parameters string, encode string and add it to specified url
	 * @param url URL.
	 * @param parameters map with parameters.
	 * @param encodeParametersString pass true to encode URL parameters with Encodingutil.urlEncode(...) method.
	 * @return URL with added parameters.
	 */	
	public virtual String addParametersToUrl(String url, Map<String, String> parameters, boolean encodeParametersString) {
		String parametersString = convertMapToParametersString(parameters);
		if (!String.isBlank(parametersString)) {
			parametersString = (url.contains('?') ? '&' + parametersString : '?' + parametersString);
			url += encodeParametersString ? Encodingutil.urlEncode(parametersString, 'UTF-8') : parametersString;
		}
		return url;
	}
	
	/**
	 * @description Converts map to url parameters string. Add '?' to the beginning of the line. Parameters with empty or null values excluded from result.
	 * @param parameters map with parameters.
	 * @return url parameters string with leading '?' symbol, or empty string for empty parameters.
	 */		
	public virtual String createUrlParametersString(Map<String, String> parameters) {
		String parametersString = convertMapToParametersString(parameters);
		return (!String.isBlank(parametersString) ? '?' + parametersString : '');
	}
	
	/**
	 * @description Converts map to url string, each pair of key=value splitted with '&' symbol`. Parameters with empty or null values excluded from result.
	 * @param parameters map with parameters.
	 * @return url parameters string, or empty string for empty parameters.
	 */
	public virtual String convertMapToParametersString(Map<String, String> parameters) {
		String parametersString = '';
		boolean firstParam = true;
		for (String key : parameters.keySet()) {
			String value = parameters.get(key);
			if (!String.isBlank(value)) {
				parametersString += (!firstParam ? '&' : '') + key + '=' + value;
				firstParam = false;				
			}
		}
		return parametersString;
	}
	
	/**
     * @description Executes HTTP request and checks status code of response for common errors.
     * @param request HTTP request
     * @return HTTP response.
     */
    public virtual HttpResponse execute(HttpRequest request) {
        HttpResponse response = UtilityFactory.getHttpClient().sendRequest(request);        
        UtilityFactory.getRestErrorHandler().checkResponseCode(response);
        return response;
    }
}