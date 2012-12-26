/**
 * Factory of HttpCalloutMock, support single request mocks by SingleRequestMock class
 * and multiple requests mock by MultiRequestMock (for uage example 
 * see code of testMultiRequestMock() method)
 */
public class TestHttpMockFactory {
	
	/**	
	 * @description Authorization code.
	 */	
	public static final String AUTH_CODE = 'AtDQkEf3G8gojYFJMTLr8lwFQ';
	
	public class SingleRequestMock implements HttpCalloutMock {
		protected Integer code;
		protected String status;
		protected String bodyAsString;		
		protected Blob bodyAsBlob;
		protected Map<String, String> requestHeaders;
		
		public SingleRequestMock(Integer code, String status, String body) {
			this.code = code;
			this.status = status;
			this.bodyAsString = body;
			this.bodyAsBlob = null;
			this.requestHeaders = new Map<String, String>();
		}
		
		public SingleRequestMock(Integer code, String status, Blob body, Map<String, String> requestHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsBlob = body;
			this.bodyAsString = null;
			this.requestHeaders = requestHeaders;
		}
		
	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			resp.setStatus(status);
			if (bodyAsBlob != null) {
				resp.setBodyAsBlob(bodyAsBlob);	
			} else {
				resp.setBody(bodyAsString);
			}
			for (String key : requestHeaders.keySet()) {
				resp.setHeader(key, requestHeaders.get(key));
			}
			return resp;
	    }
	}
	
	public class MultiRequestMock implements HttpCalloutMock {
		Map<String, HttpCalloutMock> requests;
		
		public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
			this.requests = requests;
		}
		
		public HTTPResponse respond(HTTPRequest req) {
			HttpCalloutMock mock = requests.get(req.getEndpoint());
			if (mock == null) mock = requests.get('default');
			if (mock != null) {
				return mock.respond(req);
			} else {
     			throw new AttException('HTTP call out doesn\'t supported for test methods.');
			}
		}
		
		public void addRequestMock(String url, HttpCalloutMock mock) {
			requests.put(url, mock);
		}
	}
	
	/**
	 * @description Authorization mock object for services where is no specific subscriber authorization or consent required (SMS, MMS, WAP Push, etc).
	 */
	public virtual class AttCCAuthMock extends AttClientCredentialsAuthorization {
		
		public AttCCAuthMock () {
			super(ServiceConstants.ScopeType.SPEECH);
		} 
		
		public override virtual String getAccessToken() {
			return 'd3e37eb199343addd92bf00d061fb9a3';
		}
	}
	
	/**
	 * @description Authorization mock object for services where subscriber authorization is required (Location, Device Capabilities, etc)
	 */	 
	public virtual class AttCodeAuthMock extends AttCodeAuthorization {
		
		public override virtual String getAccessToken() {
			return 'd3e37eb199343addd92bf00d061fb9a3';
		}
		
		public override virtual boolean codeIsDefined() {
			return true;
		}
	}
	
	public static SingleRequestMock getSuccessfulCreatedHttpMock(String body) {
		return new SingleRequestMock(201,'Created', body);
	}
	
	public static SingleRequestMock getErrorHttpMock() {
		return new SingleRequestMock(400,'Bad Request', 's[a-z]{3} happens :(');
	}	
	
	/**
	 * @description Returns authorization mock object for AT&T Client Credentials Authorization model.
	 * @return authorization mock object for AT&T Client Credentials Authorization model.
	 */
	public static AttCCAuthMock getCCAuthMock() {
		return new AttCCAuthMock();
	} 
	
	/**
	 * @description Returns authorization mock object for AT&T Code Authorization model.
	 * @return authorization mock object for AT&T Code Authorization model.
	 */	
	public static AttCodeAuthMock getCodeAuthMock() {
		return new AttCodeAuthMock();
	}

	public static testmethod void testMultiRequestMock() {
		//Yes, this is test of testing tools 
		
		HttpCalloutMock multimock = new MultiRequestMock(new Map<String,HttpCalloutMock>{
			'default' =>	getErrorHttpMock(),
			'http://example.com/foo?bar=1' => getSuccessfulCreatedHttpMock('FOO BAR'),
			'http://example.com/baz' => new SingleRequestMock(200,'OK', 'BAZZZ') 
		});
		
		
		Test.setMock(HttpCalloutMock.class, multimock);
		
		HttpRequest req = new HttpRequest();        
        req.setEndpoint('http://example.com/foo?bar=1');
        HTTPResponse res = new Http().send(req);
		System.assertEquals('FOO BAR', res.getBody());
		
		req = new HttpRequest();        
        req.setEndpoint('http://example.com/baz');
        res = new Http().send(req);
        System.assertEquals('BAZZZ', res.getBody());
        
        
        req = new HttpRequest();        
        req.setEndpoint('http://example.com/someOtherRequest');
        res = new Http().send(req);
        System.assertEquals(400, res.getStatusCode());
	}
	
	private final Set<System.Type> TEST_CLASSES = new Set<System.Type> {
		TestAttClientCredentialsAuthorization.class,
		TestAttCodeAuthorization.class,
		TestAttConsentExtWorkflow.class,
		TestAttConsentWorkflow.class,
		TestAttDeviceCapabilitiesService.class,
		TestAttDeviceLocation.class,
		TestAttExceptionClass.class,
		TestAttLocation.class,
		TestAttMIM.class,
		TestAttMIMMessageHeaders.class,
		TestAttMMSCallbackProcessor.class,
		TestAttMMSSending.class,
		TestAttMoboClient.class,
		TestAttOAuthResult.class,
		TestAttPayload.class,
		TestAttPaymentNotification.class,
		TestAttSinglePaymentTransaction.class,
		TestAttSpeech.class,
		TestAttSpeechResult.class,
		TestAttSubscriptionPaymentTransaction.class,
		TestAttTerminalLocation.class,
		TestAttWAPPush.class,
		TestClearExpiredAuth.class,
		TestMultipartParser.class,
		TestSecurityTokenProvider.class,
		TestUtilsImpl.class
	};
}