/**
 * @description Provides methods to retrieve AT&T application keys and shortcodes.
 */
public interface SecurityTokenProvider {
	
    /**
     * @description Returns short code by name. Returns null when short code can't be founded.
     * @param name short code name.
     * @return short code value or null when short code can't be founded.
     */
	String getShortcodeByName(String name);
	
    /**
     * @description Returns Att_Application_Security_Key__c object, which contains AT&T application keys.
     * @return Att_Application_Security_Key__c object.
     */
	Att_Application_Security_Key__c getApplicationKey();
}