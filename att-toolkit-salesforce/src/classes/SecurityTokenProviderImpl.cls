/**
 * @description Provides common implementation of SecurityTokenProvider interface.
 */
public virtual class SecurityTokenProviderImpl implements SecurityTokenProvider {
	
    /**
     * @description Returns short code by name. Returns null when short code can't be founded.
     * @param name short code name.
     * @return short code value or null when short code can't be founded.
     */	
	public virtual String getShortcodeByName(String name) {
        try {
        	//method is adoptated according to changes of getApplicationKey()
            Att_Application_Security_Key__c applicationKey = getApplicationKey();
            Att_Shortcode__c shortcode;
            if (Test.isRunningTest()) {
            	shortcode = new Att_Shortcode__c(Name = 'Default', Shortcode__c = '3333');
            	shortcode.AT_T_Application_Security_Key__c = applicationKey.Id;
            } else {
            	shortcode = [SELECT Id, Name, Shortcode__c FROM Att_Shortcode__c 
                                          WHERE AT_T_Application_Security_Key__c = :applicationKey.Id AND
                                                Name = :name LIMIT 1];
            }
            return shortcode.Shortcode__c;
        } catch (System.QueryException ex) {
            throw new AttException('Shortcode is not found by name "' + name + '"');
        }
	}
	
    /**
     * @description Returns Att_Application_Security_Key__c object, which contains AT&T application keys.
     * @return Att_Application_Security_Key__c object.
     */
	public virtual Att_Application_Security_Key__c getApplicationKey() {
        try {
        	// insert operation during test make uncommited db transaction
        	// which prevents HttpCalloutMock usage
            Att_Application_Security_Key__c applicationKey;
            if (Test.isRunningTest()) {
            	applicationKey = new Att_Application_Security_Key__c(API_Key__c = '1111', Secret_Key__c = '2222', Name = 'at&t toolkit');
            } else {
            	applicationKey = [SELECT Name, API_Key__c, Secret_Key__c FROM Att_Application_Security_Key__c LIMIT 1];
            }
            return applicationKey;
        } catch (System.QueryException ex) {
            throw new AttException('Application key is not found');
        }
	}
}