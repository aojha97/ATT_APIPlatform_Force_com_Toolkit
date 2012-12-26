@isTest
public class TestAttCodeAuthorization {
	private static ServiceConstants.ScopeType[] SCOPE = new ServiceConstants.ScopeType[] {ServiceConstants.ScopeType.TL, ServiceConstants.ScopeType.MIM}; 
	
	static testmethod void testAccessToken() {
		AttCodeAuthorization auth = new AttCodeAuthorization();
		System.assertEquals(false, auth.authorized());
		System.assertEquals(false, auth.codeIsDefined());
		try {
			auth.getAccessToken();
		} catch (AttException ex) {
			System.assertEquals('You should obtain authorization code first.', ex.getMessage());
			System.assertEquals(false, auth.authorized());
			System.assertEquals(false, auth.codeIsDefined());
		}
		
		auth.setAuthorizationCode(TestHttpMockFactory.AUTH_CODE);
		Test.setMock(HttpCalloutMock.class, new TestHttpMockFactory.SingleRequestMock(400, 'Bad Request', '{ "error":"invalid_grant" }'));
		try {
			String accesssToken = auth.getAccessToken();
		} catch (AttException ex) {
			System.assertEquals(false, auth.codeIsDefined());
			System.assertEquals('AT&T authorization is broken. You will be re-authorized.', ex.getMessage());
		}
		
		// obtain expired access token
		auth.setAuthorizationCode(TestHttpMockFactory.AUTH_CODE);
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"access_token":"40da93dc50663e4f2cd9ea5c2c36b54b","expires_in":"-1000","refresh_token":"941744be3d2ddec96bc2de1f2b20bd6c7ca8feae"}'));
		String accesssToken = auth.getAccessToken();
		System.assertEquals('40da93dc50663e4f2cd9ea5c2c36b54b', accesssToken);
		
		// refresh access token
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"access_token":"d3e37eb199343addd92bf00d061fb9a3","expires_in":"86400000","refresh_token":"941744be3d2ddec96bc2de1f2b20bd6c7ca8feae"}'));
		accesssToken = auth.getAccessToken();
		System.assertEquals('d3e37eb199343addd92bf00d061fb9a3', accesssToken);
	}	
}