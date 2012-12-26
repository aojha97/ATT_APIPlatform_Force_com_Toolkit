/**
 * @description Storage of AT&T OAuth service result. 
 */
public virtual class AttOAuthResult {
	
	/**
	 * @description Access token value.
	 */
    public String access_token {set; get;}
    
    /**
	 * @description Time in seconds 
	 */
    public Integer expires_in {set; get;}
    
    /**
	 * @description Refresh token value. 
	 */
    public String refresh_token {set; get;}
    
    /**
	 * Access token expireation date and time.   
	 */
	private Datetime tokenExpireIn { get; set; }
	
	/**
	 * @description Parses JSON string into class fields.
	 * @param json string with AT&T OAuth service JSON response data.
	 * @return instance of AttOAuthResult class with data from JSON string.
	 */
	public static AttOAuthResult parse(String json) {
		try {		
			AttOAuthResult result = (AttOAuthResult) System.JSON.deserialize(json, AttOAuthResult.class);
			if (result.expires_in == null || result.expires_in == 0) {
				result.expires_in = 86400; // 24 hours
			}
			result.tokenExpireIn = Datetime.now().addSeconds(Integer.valueOf(result.expires_in));			
			return result;
		} catch (Exception ex) {
    		throw new AttException(ex);
    	}
	}
	
	/**
	 * @description Returns true when access token is expired, false otherwise.
	 * @return true when access token is expired, false otherwise.
	 */
	public virtual Boolean expired() {
		return Datetime.now() > tokenExpireIn;
	}	

}