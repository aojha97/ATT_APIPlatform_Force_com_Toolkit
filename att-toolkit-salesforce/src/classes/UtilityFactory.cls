/**
 * @description Services and utilities objects factory. Provides methods to retrieve services and utilities instances. 
 */
public class UtilityFactory {
	
	private static RestErrorHandler restErrorHandler;
	private static SecurityTokenProvider accessTokenProvider;
	private static HttpClient httpClient;
	private static Utils utils;
	
	/**
	 * @description Returns REST errors handler instance.
	 * @return REST errors handler instance. 
	 */
	public static RestErrorHandler getRestErrorHandler() {
		if (restErrorHandler == null) {
			restErrorHandler = new RestErrorHandlerImpl();
		}
		return restErrorHandler;
	}
	
	/**
	 * @description Returns security token provider instance.
	 * @return security token provider instance.
	 */
	public static SecurityTokenProvider getSecurityTokenProvider() {
		if (accessTokenProvider == null) {
			accessTokenProvider = new SecurityTokenProviderImpl();
		}
		return accessTokenProvider;
	}
	
	/**
	 * @description Returns utilities instance. 
	 * @return utilities instance.
	 */	
	public static Utils getUtils() {
		if (utils == null) {
			utils = new UtilsImpl();
		}
		return utils;
	}
	
	/**
	 * @description Returns HTTP client instance.
	 * @return HTTP client instance.
	 */	
	public static HttpClient getHttpClient() {
		if (httpClient == null) {
			httpClient = new HttpClientImpl();
		}
		return httpClient;
	}
	
	public static testmethod void testFactory() {
		RestErrorHandler handler = getRestErrorHandler();
		System.assertNotEquals(null, handler);
		
		SecurityTokenProvider manager = getSecurityTokenProvider();
		System.assertNotEquals(null, manager);
		
		HttpClient client = getHttpClient();
		System.assertNotEquals(null, client);
	}
}