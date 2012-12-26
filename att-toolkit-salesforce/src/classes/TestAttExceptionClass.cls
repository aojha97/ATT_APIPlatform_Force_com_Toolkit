@isTest
public class TestAttExceptionClass {

	static testmethod void testException() {
		// test null values
		AttException ex = new AttException(null, null, null);
		System.assertEquals(null, ex.statusCode);
		System.assertEquals(null, ex.messageId);
		System.assertEquals(null, ex.messageText);
		System.assertEquals(null, ex.variables);
		
		// test exception with empty message text and variables
		ex = new AttException(401, 'POL0001', null);
		System.assertEquals(401, ex.statusCode);
		System.assertEquals('POL0001', ex.messageId);
		System.assertEquals(null, ex.messageText);
		System.assertEquals(null, ex.variables);
		System.assertEquals('POL0001', ex.getMessage());
		
		// test exception with empty variables
		ex = new AttException(401, 'POL0001', 'UnAuthorized Request');
		System.assertEquals(401, ex.statusCode);
		System.assertEquals('POL0001', ex.messageId);
		System.assertEquals('UnAuthorized Request', ex.messageText);
		System.assertEquals(null, ex.variables);
		System.assertEquals('POL0001: UnAuthorized Request', ex.getMessage());
		
		// test with all fields
		ex = new AttException(401, 'POL0002', 'Privacy verification failed for %1 variable', 'address');
		System.assertEquals(401, ex.statusCode);
		System.assertEquals('POL0002', ex.messageId);
		System.assertEquals('Privacy verification failed for %1 variable', ex.messageText);
		System.assertEquals('address', ex.variables);
		System.assertEquals('POL0002: Privacy verification failed for <address> variable', ex.getMessage());
	}
}