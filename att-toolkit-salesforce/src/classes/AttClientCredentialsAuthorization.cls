/**
 * @description Implements AT&T Client Credentials Authorization Model. Uses for AT&T services where is no specific subscriber authorization or consent required (SMS, MMS, WAP Push, etc).
 */
public virtual class AttClientCredentialsAuthorization extends AttOAuth {
	
	/**
	 * @description Authorization scope. Multiple scopes can be a comma delimited list of values. Only AT&T services where is no specific subscriber authorization or consent required can be used (SMS, MMS, WAP Push, etc).
	 */
	private String scope;
	
	private GrantType grantType;

	/**
	 * @description Constructs class with array of services scope types.
	 * @param scopeTypeList array of ServiceConstants.ScopeType enumerations elements.
	 */
	public AttClientCredentialsAuthorization(ServiceConstants.ScopeType[] scopeTypeList) {
		if (scopeTypeList == null) {
			throw new AttException('AttClientCredentialsAuthorization: scopeTypeList is null');
		}
		for (ServiceConstants.ScopeType scopeType : scopeTypeList) {
			if (scopeType == null) {
				throw new AttException('AttClientCredentialsAuthorization: scopeType is null');
			}
		}
		grantType = AttOAuth.GrantType.client_credentials;	
		scope = ServiceConstants.getScopeByType(scopeTypeList);
	}

	/**
	 * @description Constructs Constructs class with service scope type.
	 * @param scopeType ServiceConstants.ScopeType enumeration element.
	 */
	public AttClientCredentialsAuthorization(ServiceConstants.ScopeType scopeType) {
		this(new ServiceConstants.ScopeType[] {scopeType});
	}
	
	/**
	 * Checks for AT&T Client Credentials authorization model required parameters.
	 * Thorws AttException with errors description.
	 */
	protected override virtual void checkRequiredParameters() {
		if (String.isBlank(scope)) {
			throw new AttException('AttClientCredentialsAuthorization.checkRequiredParameters: scope is required'); 
		}
	}

    /**
     * Returns map with AT&T Client Credentials authorization model parameters.
     */
	protected override virtual Map<String, String> getAuthorizationParameters() {		
		return new Map<String, String> {
			'grant_type' => grantType.name(),
			'scope' => scope
		};
	}
}