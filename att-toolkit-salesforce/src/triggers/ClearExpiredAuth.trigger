/*
 * Trigger used for clear expired authorization records
 */
trigger ClearExpiredAuth on AttCodeAuth__c (before insert) {
	
	// delete expired records
	for (AttCodeAuth__c auth : [select id, expire_in__c from AttCodeAuth__c where expire_in__c = null or expire_in__c < :Datetime.now()]) {
       	delete auth;
    }
}