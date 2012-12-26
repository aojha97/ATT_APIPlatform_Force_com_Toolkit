@isTest
public class TestAttConsentWorkflow {

	/**
	 * Simple implementation of AttConsentWorkflow.
	 */
	private virtual class SimpleConsentWorkflow extends AttConsentWorkflow {
		
		public String param1 { get; set; }
		public String param2 { get; set; }
		
		public AttLocation locationService;
		
		protected override void initialize() {
			locationService = new AttLocation(auth);
			param1 = 'value1';
			param2 = 'value2';
		}
		
		protected override virtual void loadParams(Map<String, String> params) {
			param1 = params.get('param1');
			param2 = params.get('param2');
		}
		
		protected override Map<String, String> getParams() {
			return new Map<String, String> {
				'param1' => 'value3',
				'param2' => 'value4'
			};
		}
		
		public override void execute() {
			// invoke location service		
		}
		
		protected override ServiceConstants.ScopeType[] getConsentScope() {
			return new ServiceConstants.ScopeType[] { ServiceConstants.ScopeType.TL };
		}		
	}
	
	/**
	 * Extends SimpleConsentWorkflow to test exceptions.
	 */
	private class BrokenConsentWorkflow extends SimpleConsentWorkflow {
		
		protected override void loadParams(Map<String, String> params) {
			throw new AttException('Load parameters error occurs.');
		}
	}
	
	static testmethod void testInitialization() {
		// initialization without authorization code
		SimpleConsentWorkflow workflow = new SimpleConsentWorkflow();
		System.assertEquals(false, workflow.authorized);
		System.assertEquals('value1', workflow.param1);
		System.assertEquals('value2', workflow.param2);

		System.assertEquals(new Map<String, String> {
				'param1' => 'value3',
				'param2' => 'value4'
			}, workflow.getParams());
		System.assertEquals(new ServiceConstants.ScopeType[] { 
			ServiceConstants.ScopeType.TL			
			}, workflow.getConsentScope());
		
		// initialization with authorization code
		Map<String, String> params = Apexpages.currentPage().getParameters();
		params.put('code', TestHttpMockFactory.AUTH_CODE);
		params.put('param1', 'value5');
		params.put('param2', 'value6');
		workflow = new SimpleConsentWorkflow();
		System.assertEquals(true, workflow.authorized);		
		System.assertEquals('value5', workflow.param1);
		System.assertEquals('value6', workflow.param2);
		
		// initialization with error returned from AT&T OAuth server.
		params.clear();
		params.put('error', 'access_denied');
		params.put('error_description', 'POL1011 Authorization cannot be granted.');
		workflow = new SimpleConsentWorkflow();
		System.assertEquals(1, ApexPages.getMessages().size());
		System.assertEquals('Error: access_denied Error description: POL1011 Authorization cannot be granted.', ApexPages.getMessages().get(0).getSummary());
		
		params.clear();
		params.put('code', TestHttpMockFactory.AUTH_CODE);
		params.put('param1', 'value5');
		params.put('param2', 'value6');
		BrokenConsentWorkflow brokenWf = new BrokenConsentWorkflow();
		System.assertEquals(2, ApexPages.getMessages().size());
		System.assertEquals('Load parameters error occurs.', ApexPages.getMessages().get(1).getSummary());
	}
	
	static testmethod void testConsentAuthorization() {		
		SimpleConsentWorkflow workflow = new SimpleConsentWorkflow();
		
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(''));		
		try {
			Pagereference consentRedirect = workflow.invokeService();
		} catch (Exception ex) {
			System.assertEquals('Page wasn\'t redirected to AT&T End-User authorization service', ex.getMessage());
		}
		
		Test.setMock(HttpCalloutMock.class, new TestHttpMockFactory.SingleRequestMock(302, 'Redirect', Blob.valueOf(''), new Map<String, String> {
			'Location' => URL.getCurrentRequestUrl().toExternalForm()
		}));
		Pagereference consentRedirect = workflow.invokeService();
		System.assertNotEquals(null, consentRedirect);
	}		
}