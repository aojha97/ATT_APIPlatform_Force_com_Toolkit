/**
 * @description Implements AT&T Authorization Code Model. Uses for AT&T services where subscriber authorization is required (Location, Device Capabilities, etc).
 */
public virtual class AttCodeAuthorization extends AttOAuth {
	
	private GrantType grantType;
	private String authorizationCode;
	
	/**
	 * @description Constructs code authorization.
	 */
	public AttCodeAuthorization() {
		grantType = AttOAuth.GrantType.authorization_code;
	}
	
	/**
	 * @description Sets authorization code. Authorization code obtained by AT&T End-User authorization workflow.
	 * @param authorizationCode authorization code.
	 */
	public virtual void setAuthorizationCode(String authorizationCode) {
		this.authorizationCode = authorizationCode;		
	}
	
	/**
	 * @description Returns true when authorization code is not empty.
	 * @return true when authorization code is not empty.
	 */
	public virtual boolean codeIsDefined() {
		return String.isNotEmpty(authorizationCode);
	}
	
	/**
	 * Checks for AT&T Authorization Code Model required parameters.
	 * Thorws AttException with errors description.
	 */
	protected override virtual void checkRequiredParameters() {
		if (!codeIsDefined()) {
			throw new AttException('You should obtain authorization code first.');
		}
	}	
	
	/**
	 * Overrides method to correct authorization exceptions.
	 */
	protected override virtual void obtainAccessToken() {
		try {
			super.obtainAccessToken();
		} catch (AttException ex) {
			System.debug('Auth exception: ' + ex);
			// access token can be obtained by the same authorization code only one time, second time AT&T server throws 'invalid_grant' exception
			String msg = ex.messageId;   
			if (String.isNotBlank(msg) && (msg.contains('invalid_grant') || msg.contains('invalid_client'))) {
				authorizationCode = null;
				throw new AttException('AT&T authorization is broken. You will be re-authorized.');
			}
			throw ex;
		}
	}
	
    /**
     * Returns map with AT&T Authorization Code model parameters.
     */
	protected override virtual Map<String, String> getAuthorizationParameters() {
		return new Map<String, String> {
			'grant_type' => grantType.name(),
			'code' => authorizationCode
		};
	}
}