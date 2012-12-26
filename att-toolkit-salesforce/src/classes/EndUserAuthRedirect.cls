/**
 * @description This service used to hide 'code' parameter returned from AT&T OAuth servcer after end-user authoriation.
 */
@RestResource(urlMapping='/EndUserAuthRedirect')
global class EndUserAuthRedirect {
	
	/**
	 * @description The URL where the subscriber’s browser will be redirected following completion of the AT&T authorization process.
	 */
	public static String END_USER_REDIRECT_REST_URL = 'https://att-forcecom-sdk-developer-edition.na9.force.com/services/apexrest/EndUserAuthRedirect';
	
	/**
	 * @description Return URL parameter name.
	 */
	public static String PARAM_RETURN_URL = 'returnUrl';
	
	/**
	 * @description Handles GET HTTP request, saves 'code' parameter to database and redirects to 'returnUrl'
	 */
	@HttpGet
    global static void doGet() {
    	Map<String, String> params = RestContext.request.params;
		
		// save authorization code to database
		if (params.containsKey('code')) {
			AttCodeAuth__c auth = new AttCodeAuth__c();
	        auth.Name = params.remove('code');
	        auth.expire_in__c = Datetime.now().addMinutes(60);
	        insert auth;
	        params.put('authId', auth.Id);
		}
        
        // send redirect to service
        if (params.containsKey(PARAM_RETURN_URL)) {
	        RestResponse resp = RestContext.response;
	        resp.statusCode = 302;	        
	        String redirectUrl = UtilityFactory.getUtils().addParametersToUrl(params.remove(PARAM_RETURN_URL), params);        
	     	resp.addHeader('Location', redirectUrl);
        } else {
        	throw new AttException('Return URL must be specified.');
        }     	
    }
}