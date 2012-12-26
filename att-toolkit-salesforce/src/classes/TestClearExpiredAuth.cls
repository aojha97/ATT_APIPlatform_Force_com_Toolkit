@isTest
public class TestClearExpiredAuth {

	static testmethod void testTrigger() {
		
		List<AttCodeAuth__c> del = [select id, Name, expire_in__c from AttCodeAuth__c];
		delete del;
		
		// insert first element		
		AttCodeAuth__c auth = new AttCodeAuth__c();		
	    auth.Name = TestHttpMockFactory.AUTH_CODE;
	    auth.expire_in__c = Datetime.now().addMinutes(60);
	    insert auth;
	    
	    List<AttCodeAuth__c> authList = [select id, Name, expire_in__c from AttCodeAuth__c where id = :auth.id];
	    System.assertEquals(1, authList.size());
	    AttCodeAuth__c value = authList.get(0); 
	    System.assertEquals(TestHttpMockFactory.AUTH_CODE, value.Name);
	    System.assertEquals(auth.expire_in__c, value.expire_in__c);
	    
	    // check for clearing expired objects on insert
	    AttCodeAuth__c auth1 = new AttCodeAuth__c();
	    auth1.Name = TestHttpMockFactory.AUTH_CODE;	    
	    insert auth1;
	    
	    AttCodeAuth__c auth2 = new AttCodeAuth__c();
	    auth2.Name = TestHttpMockFactory.AUTH_CODE;
	    auth2.expire_in__c = Datetime.now().addDays(1);
	    insert auth2;
	    
	    authList = [select id, Name, expire_in__c from AttCodeAuth__c where id = :auth1.id or id = :auth2.id];
	    System.debug('List: ' + authList);
	    System.assertEquals(1, authList.size());
	    value = authList.get(0); 
	    System.assertEquals(TestHttpMockFactory.AUTH_CODE, value.Name);
	    System.assertEquals(auth2.expire_in__c, value.expire_in__c);
	}
}