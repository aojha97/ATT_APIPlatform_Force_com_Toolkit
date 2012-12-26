@isTest
public class TestAttConsentExtWorkflow {
	
	/**
	 * Simple implementation of AttConsentExtWorkflow.
	 */
	private virtual class SimpleConsentExtWorkflow extends AttConsentExtWorkflow {
		
		public AttMoboClient mobo;
		public AttDeviceCapabilities dc;
		
		protected override void initialize() {
			mobo = new AttMoboClient(TestHttpMockFactory.getCodeAuthMock());
			dc = new AttDeviceCapabilities();
		}
		
		public override virtual void execute() {
			// invoke services
		}
		
		protected override ServiceConstants.ScopeType[] getConsentScope() {
			return new ServiceConstants.ScopeType[] { ServiceConstants.ScopeType.DEVICE_CAPABILITIES, ServiceConstants.ScopeType.MOBO };
		}
	}
	
	/**
	 * Extends SimpleConsentExtWorkflow to test exceptions.
	 */
	private class BrokenConsentExtWorkflow extends SimpleConsentExtWorkflow {
		
		public override void execute() {
			throw new AttException('Cannot execute DC service.');
		}
	}
	
	static testmethod void testInitialization() {
		// initialization without authorization code
		SimpleConsentExtWorkflow workflow = new SimpleConsentExtWorkflow();
		System.assertEquals(false, workflow.authorized);

		System.assertEquals(new ServiceConstants.ScopeType[] { 
			ServiceConstants.ScopeType.DEVICE_CAPABILITIES,
			ServiceConstants.ScopeType.MOBO			
			}, workflow.getConsentScope());
		
		// initialization with authorization code
		Map<String, String> params = Apexpages.currentPage().getParameters();
		params.put('code', TestHttpMockFactory.AUTH_CODE);
		workflow = new SimpleConsentExtWorkflow();
		System.assertEquals(true, workflow.authorized);		
		
		// initialization with error returned from AT&T OAuth server.
		params.clear();
		params.put('error', 'access_denied');
		params.put('error_description', 'POL1011 Authorization cannot be granted.');
		workflow = new SimpleConsentExtWorkflow();
		System.assertEquals(1, ApexPages.getMessages().size());
		System.assertEquals('Error: access_denied Error description: POL1011 Authorization cannot be granted.', ApexPages.getMessages().get(0).getSummary());
		
		workflow.invokeService();
	}
	
	static testmethod void testConsentAuthorization() {		
		SimpleConsentExtWorkflow workflow = new SimpleConsentExtWorkflow();
		
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(''));		
		try {
			Pagereference consentRedirect = workflow.authorize();
		} catch (Exception ex) {
			System.assertEquals('Page wasn\'t redirected to AT&T End-User authorization service', ex.getMessage());
		}
		
		Test.setMock(HttpCalloutMock.class, new TestHttpMockFactory.SingleRequestMock(302, 'Redirect', Blob.valueOf(''), new Map<String, String> {
			'Location' => URL.getCurrentRequestUrl().toExternalForm()
		}));
		Pagereference consentRedirect = workflow.authorize();
		System.assertNotEquals(null, consentRedirect);
		
		Map<String, String> params = Apexpages.currentPage().getParameters();
		params.put('code', TestHttpMockFactory.AUTH_CODE);
		workflow = new SimpleConsentExtWorkflow();
		consentRedirect = workflow.authorize();
		System.assertEquals(ApexPages.currentPage(), consentRedirect);
		System.assertEquals(2, ApexPages.getMessages().size());
		System.assertEquals('Service already authorized.', ApexPages.getMessages().get(1).getSummary());		
	}
	
	static testmethod void testServicesInvocation() {
		Map<String, String> params = Apexpages.currentPage().getParameters();
		params.put('code', TestHttpMockFactory.AUTH_CODE);
		BrokenConsentExtWorkflow brokenWf = new BrokenConsentExtWorkflow();
		brokenWf.invokeService();
		System.assertEquals(true, brokenWf.authorized);
	}
}