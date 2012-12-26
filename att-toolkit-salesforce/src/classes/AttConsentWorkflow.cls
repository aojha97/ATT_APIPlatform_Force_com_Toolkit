/**
 * @description Implements AT&T OAuth End-User authorization workflow. 
 */
public abstract class AttConsentWorkflow extends AttBaseConsent {
	
	/**
	 * @description Constructs class and executes invokeService() function after redirect from end-user authorization.	
	 */
	public AttConsentWorkflow() {
		super();
		try {						
			if (authorized) {
				loadParams(ApexPages.currentPage().getParameters());
				invokeService();
			}
		} catch (Exception ex) {
			System.debug(Logginglevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}
	
	/*
	 * Initilalize controller fields and services
	 */
	protected abstract void loadParams(Map<String, String> params);
	
	/**
	 * @description Invokes controller services and actions. Check for missing authorization before execute any actions.
	 * @return page reference to AT&T OAuth server when authorization is missing.
	 */
	public virtual Pagereference invokeService() {
		Pagereference pageReference = ApexPages.currentPage();
		try {
			if (authorized) {
				execute();
			} else {
				pageReference = getConsentPageReference(getConsentScope(), URL.getCurrentRequestUrl().toExternalForm(), getParams());
			}
		} catch (Exception ex) {
			authorized = auth.codeIsDefined();
			System.debug(Logginglevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}			
		return pageReference;
	}

	
	/**
	 * Returns map with parameters and user input data which should be passed through redirect to AT&T OAuth server.
	 */	
	protected abstract Map<String, String> getParams();
}