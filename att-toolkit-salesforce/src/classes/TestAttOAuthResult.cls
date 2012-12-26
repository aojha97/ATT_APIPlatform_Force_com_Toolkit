@isTest
public class TestAttOAuthResult {
	
	public static testmethod void testOAuthResult() {
		String json = '{ wrong JSON }';
		try {
			AttOAuthResult result = AttOAuthResult.parse(json);
		} catch (AttException ex) {
			System.assertEquals('Script-thrown exception', ex.getMessage());
		}
		
		// access token without expiration period 
		json = '{"access_token":"40da93dc50663e4f2cd9ea5c2c36b54b","expires_in":"0","refresh_token":"941744be3d2ddec96bc2de1f2b20bd6c7ca8feae"}';
		AttOAuthResult result = AttOAuthResult.parse(json);
		System.assertEquals(86400, result.expires_in);
		System.assertEquals('941744be3d2ddec96bc2de1f2b20bd6c7ca8feae', result.refresh_token);
		System.assertEquals('40da93dc50663e4f2cd9ea5c2c36b54b', result.access_token);
		System.assertEquals(false, result.expired());
		
		// access tooken withn expiration period
		json = '{"access_token":"d3e37eb199343addd92bf00d061fb9a3","expires_in":"3600","refresh_token":"941744be3d2ddec96bc2de1f2b20bd6c7ca8feae"}';
		result = AttOAuthResult.parse(json);
		System.assertEquals(3600, result.expires_in);
		System.assertEquals('941744be3d2ddec96bc2de1f2b20bd6c7ca8feae', result.refresh_token);
		System.assertEquals('d3e37eb199343addd92bf00d061fb9a3', result.access_token);
		System.assertEquals(false, result.expired());
	}
}