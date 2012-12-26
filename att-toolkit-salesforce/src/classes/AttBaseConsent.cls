/**
 * @description Base class for consent requests. Implements common logic for consent requests.
 */
public abstract class AttBaseConsent {
	
	/**
	 * @description Authorization object.
	 */
	public AttCodeAuthorization auth { get; set; }
	
	/**
	 * @description Authorization status.
	 */
	public Boolean authorized { get; set; }
	
	/**
	 * @description Constructs authorization object, initializes controller fields and services.
	 */
	public AttBaseConsent() {
		try {
			authorized = false;						
			auth = new AttCodeAuthorization();
			Map<String, String> params = ApexPages.currentPage().getParameters();
			initialize();
			handleUrlError();
			if (params.containsKey('code')) {
				auth.setAuthorizationCode(params.remove('code'));
				authorized = true;
			}
		} catch (Exception ex) {
			System.debug(Logginglevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}
	
	/*
     * @description Handles URL for error in case of failed authorization.
     */
	protected virtual void handleUrlError(){		
        String error = ApexPages.currentPage().getParameters().get('error');
        String errorDescription = ApexPages.currentPage().getParameters().get('error_description');
        if (String.isNotBlank(error) || String.isNotBlank(errorDescription)){
        	String errorMessage = (String.isNotBlank(error)?'Error: ' + error:'') + (String.isNotBlank(errorDescription)?' Error description: ' + errorDescription:'');
            throw new AttException(errorMessage); 
        }
    }
	
	/**
	 * Initializes controller fields and services.
	 */
	protected abstract void initialize();
	
	/**
	 * @description Executes controller services and actions.
	 */	
	public abstract void execute();
	
	/**
	 * Returns ServiceConstants.ScopeType array of controller services where subscriber authorization is required.
	 */
	protected abstract ServiceConstants.ScopeType[] getConsentScope();
	
	/**
	 * @description Returns page reference to AT&T End-User Authorization service.
	 * @param scope array of ServiceConstants.ScopeType enumerations elements. Only services where subscriber authorization required can be used.
	 * @param returnUrl the URL where the subscriber’s browser will be redirected following completion of the authorization process.
	 * @param returnUrlParameters return URL parameters.
	 * @return page reference to AT&T End-User Authorization service.
	 */
	public virtual PageReference getConsentPageReference(ServiceConstants.ScopeType[] scopeTypeList, String returnUrl, Map<String, String> returnUrlParams) {
		returnUrl = UtilityFactory.getUtils().addParametersToUrl(returnUrl, returnUrlParams, true);
    	return getConsentPageReference(scopeTypeList, returnUrl);
    }

	/**
	 * @description Returns page reference to AT&T End-User Authorization service.
	 * @param scope array of ServiceConstants.ScopeType enumerations elements. Only services where subscriber authorization required can be used.
	 * @param returnUrl the URL where the subscriber’s browser will be redirected following completion of the authorization process.
	 * @return page reference to AT&T End-User Authorization service.
	 */
	public virtual PageReference getConsentPageReference(ServiceConstants.ScopeType[] scopeTypeList, String returnUrl) {		
		HttpRequest request = createConsentRequest(scopeTypeList, returnUrl);
		HttpResponse response = UtilityFactory.getUtils().execute(request);
		if (response.getStatusCode() != 302) {
			throw new AttException('Page wasn\'t redirected to AT&T End-User authorization service');
		}
		return new PageReference(response.getHeader('Location'));
    }    
    
    /**
     * Returns request to AT&T End-User Authorization service.
     */
    protected virtual HttpRequest createConsentRequest(ServiceConstants.ScopeType[] scopeTypeList, String redirectUri) {
    	Map<String, String> requestParameters = new Map<String, String> {
    		'scope' => ServiceConstants.getScopeByType(scopeTypeList),
    		'redirect_uri' => redirectUri,
    		'client_id' => UtilityFactory.getSecurityTokenProvider().getApplicationKey().API_Key__c
    	};    	
    	HttpRequest request = UtilityFactory.getHttpClient().createRequest(ServiceConstants.ServiceType.AUTHORIZE, requestParameters);
		request.setMethod('GET');
		return request;
    }
}