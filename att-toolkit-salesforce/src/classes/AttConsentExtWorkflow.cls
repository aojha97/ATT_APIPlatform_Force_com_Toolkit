/**
 * @description Implements AT&T OAuth AT&T OAuth End-User authorization workflow for controllers where 
 * user input parameters cannot be passed through end-user authorization (attachments, large data, etc.).
 * Before use any controller services you need to obtain authorization. 
 */
public abstract class AttConsentExtWorkflow extends AttBaseConsent {

	/**
	 * @description Returns page reference to AT&T OAuth server when authorization is missing.
	 * @return page reference to AT&T OAuth server when authorization is missing.
	 */
	public virtual Pagereference authorize() {
		Pagereference pageReference = ApexPages.currentPage();
		try {
			if (authorized) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Service already authorized.'));
			} else {
				pageReference = getConsentPageReference(getConsentScope(), URL.getCurrentRequestUrl().toExternalForm());
			}
		} catch (Exception ex) {			
			System.debug(Logginglevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}			
		return pageReference;
	}
	
	/**
	 * @description Invokes controller services and actions.
	 */
	public virtual void invokeService() {
		try {
			execute();
		} catch (Exception ex) {
			authorized = auth.codeIsDefined();
			System.debug(Logginglevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}			
	}
}