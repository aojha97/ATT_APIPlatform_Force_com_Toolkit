/**
 * @description Implements common logic to obtain and refresh access token. 
 */
public abstract class AttOAuth implements AttAuthorization {
	
	/**
	 * @description Enumeration of AT&T OAuth grant types.
	 */
	public enum GrantType {authorization_code, client_credentials, refresh_token}
	
	/**
	 * Authorization object.
	 */
	private AttOAuthResult auth;
	
	/**
	 * @description Returns access token obtained from AT&T OAuth service.
	 * Throws AttException when AT&T OAuth service exceptions occurs, or access token cannot be returned.
	 * @return access token value.
	 */
	public virtual String getAccessToken() {
		if (!authorized()) {
			obtainAccessToken();
		} else {
			if (auth.expired()) {
				refreshAccessToken();
			}
		}
		return auth.access_token;
	}
	
	/**
	 * @description Returns true when authorization is obtained from AT&T OAuth service and access token is not empty, false otherwise.
	 * @return true when authorization is obtained, false otherwise.
	 */
	public virtual boolean authorized() {
		return auth != null && String.isNotBlank(auth.access_token);
	}
	
	/**
	 * Obtains access token from AT&T OAuth service.
	 * Throws AttException when authorization request required data is absent or AT&T service returns error.
	 */
	protected virtual void obtainAccessToken() {
		checkRequiredParameters();
		invokeOAuthService(false);
	}
	
	/**
	 * Checks for required authorization parameters.
	 * Thorws AttException with errors description.
	 */
	protected abstract void checkRequiredParameters();
	
	/**
	 * Invoke AT&T refresh access token service and update authorization.	 	 
	 * Throws AttException when AT&T service returns error or you trying to refresh access token before you obtained it.
	 */
	protected virtual void refreshAccessToken() {
		if (!authorized()) {
			throw new AttException('You should obtain access token first.'); 
		} else {
			invokeOAuthService(true);
		}
	}	
	
	/**
	 * Invokes AT&T OAuth service and handle result. 
	 * Throws AttException when AT&T service returns error.
	 */
	protected virtual void invokeOAuthService(Boolean refreshToken) {
		HttpRequest request = createOAuthRequest(refreshToken);
		HttpResponse response = UtilityFactory.getUtils().execute(request);	
       	auth = AttOAuthResult.parse(response.getBody());
	}
	
	/**
     * Creates HTTP request to AT&T OAuth service.
     * refreshToken - when value is true, will be returned refresh token request.
     */ 
    protected virtual HttpRequest createOAuthRequest(Boolean refreshToken) {    	
	    HttpRequest request = UtilityFactory.getHttpClient().createRequest(ServiceConstants.ServiceType.GET_ACCESS_TOKEN);
	    request.setMethod('POST');
		request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		request.setHeader('Accept', 'application/json');
		String params = UtilityFactory.getUtils().convertMapToParametersString(getOAuthRequestParameters(refreshToken));
		request.setBody(params);
        return request;
    }
    
    /**
     * Returns AT&T OAuth service request parameters map.
     * refreshToken - when value is true, will be returned parameters for refresh token request.
     */
    protected virtual Map<String, String> getOAuthRequestParameters(Boolean refreshToken) {    	
    	Map<String, String> parameters = new Map<String, String>();
    	
    	if (refreshToken) {
    		parameters.put('refresh_token', auth.refresh_token);
    		parameters.put('grant_type', AttOAuth.GrantType.refresh_token.name());
    	} else {
    		parameters.putAll(getAuthorizationParameters());
    	}
	    
	    Att_Application_Security_Key__c applicationKey = UtilityFactory.getSecurityTokenProvider().getApplicationKey();
    	parameters.put('client_id', applicationKey.API_Key__c);
    	parameters.put('client_secret', applicationKey.Secret_Key__c);
	    return parameters;
    }
    
    /**
     * Returns map with authorization parameters.
     */
    protected abstract Map<String, String> getAuthorizationParameters();
}