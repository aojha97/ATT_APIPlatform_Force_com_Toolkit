@isTest
public class TestAttClientCredentialsAuthorization {
	
	private static ServiceConstants.ScopeType[] SCOPE = new ServiceConstants.ScopeType[] {ServiceConstants.ScopeType.WAPPUSH, ServiceConstants.ScopeType.MMS, ServiceConstants.ScopeType.SMS};
	
	static testmethod void testAccessToken() {
		// obtain access token without scope
		try {
			new AttClientCredentialsAuthorization(new ServiceConstants.ScopeType[] {null});
		} catch (AttException ex) {
			System.assertEquals('AttClientCredentialsAuthorization: scopeType is null', ex.getMessage());
		}
		
		try {
			ServiceConstants.ScopeType[] scopeTypes = null;
			new AttClientCredentialsAuthorization(scopeTypes);
		} catch (AttException ex) {
			System.assertEquals('AttClientCredentialsAuthorization: scopeTypeList is null', ex.getMessage());
		}
		
		AttClientCredentialsAuthorization auth = new AttClientCredentialsAuthorization(ServiceConstants.ScopeType.WAPPUSH);
		System.assertEquals(false, auth.authorized());
		
		// obtain access token
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"access_token":"40da93dc50663e4f2cd9ea5c2c36b54b","expires_in":"-1000","refresh_token":"941744be3d2ddec96bc2de1f2b20bd6c7ca8feae"}'));
		String accesssToken = auth.getAccessToken();
		System.assertEquals('40da93dc50663e4f2cd9ea5c2c36b54b', accesssToken);
		
		// refresh access token
		auth = new AttClientCredentialsAuthorization(SCOPE);
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"access_token":"d3e37eb199343addd92bf00d061fb9a3","expires_in":"86400000","refresh_token":"941744be3d2ddec96bc2de1f2b20bd6c7ca8feae"}'));
		accesssToken = auth.getAccessToken();
		System.assertEquals('d3e37eb199343addd92bf00d061fb9a3', accesssToken);		
	}  
}