@isTest
public class TestDemoLocationController {
	
	private static TestHttpMockFactory.MultiRequestMock locationMultiMock;
	private static String DLBaseURL = ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.DEVICE_LOCATION);
	private static HttpCalloutMock DLMock = TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"accuracy": "1630","latitude": "37.56099","longitude": "-122.30176","timestamp": "2012-10-19T07:03:27.000-5:00"}');
	private static String TLBaseURL = ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.TERMINAL_LOCATION) + '?address=acr:authorization';
	private static HttpCalloutMock TLMock = TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"terminalLocationList": {"terminalLocation": {"currentLocation": {"accuracy": "1410","latitude": "37.558826","longitude": "-122.30265","timestamp": "2012-10-19T07:11:02.000-05:00" },"locationRetrievalStatus": "Retrieved"}}}');
	
	static {
		locationMultiMock = new TestHttpMockFactory.MultiRequestMock(new Map<String, HttpCalloutMock> {
			ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.GET_ACCESS_TOKEN) => TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"access_token":"40da93dc50663e4f2cd9ea5c2c36b54b","expires_in":"-1000","refresh_token":"941744be3d2ddec96bc2de1f2b20bd6c7ca8feae"}')
		});
		Test.setMock(HttpCalloutMock.class, locationMultiMock);
	}
	
	static testmethod void testInitialization() {
		DemoLocationController service = new DemoLocationController();		
		
		// check for fields initialization
		List<Selectoption> serviceOptions = new List<SelectOption> {
            new SelectOption(AttLocation.ServiceType.DEVICE_LOCATION.name(), 'Device location of AT&T phone numbers'),
            new SelectOption(AttLocation.ServiceType.TERMINAL_LOCATION.name(), 'Terminal location supporting A-GPS')};
		System.assertEquals(serviceOptions, service.serviceOptions);
 		
        List<Selectoption> toleranceOptions = new List<SelectOption> {
            new SelectOption(AttLocation.Tolerance.NoDelay.name(), 'No delay'),
            new SelectOption(AttLocation.Tolerance.LowDelay.name(), 'Low delay'),
            new SelectOption(AttLocation.Tolerance.DelayTolerant.name(), 'Delay tolerant')};			
			
		System.assertEquals(toleranceOptions, service.toleranceOptions);
		System.assertEquals(false, service.showResult);
		System.assertEquals(1000, service.requestedAccuracy);
		System.assertEquals(3000, service.acceptableAccuracy);
		System.assertEquals(AttLocation.ServiceType.DEVICE_LOCATION.name(), service.serviceType);
		System.assertEquals(AttLocation.Tolerance.LowDelay.name(), service.tolerance);
		System.assertEquals(false, service.showResult);
		System.assertNotEquals(null, service.locationService);
		
		// check for parameters loading after return from from end-user authorization page
		service.serviceType = AttLocation.ServiceType.TERMINAL_LOCATION.name();
		service.requestedAccuracy = 300;
		service.tolerance = AttLocation.Tolerance.DelayTolerant.name();
		service.acceptableAccuracy = 5000;
		
		locationMultiMock.addRequestMock(TLBaseURL + '&tolerance=DelayTolerant&requestedAccuracy=300&acceptableAccuracy=5000', TLMock);
		ApexPages.currentPage().getParameters().put('code', TestHttpMockFactory.AUTH_CODE);
		ApexPages.currentPage().getParameters().put('seviceType', service.serviceType);
		ApexPages.currentPage().getParameters().put('requestedAccuracy', String.valueOf(service.requestedAccuracy));
		ApexPages.currentPage().getParameters().put('acceptableAccuracy', String.valueOf(service.acceptableAccuracy));
		ApexPages.currentPage().getParameters().put('tolerance', service.tolerance);
		service = new DemoLocationController(); 
		System.assertEquals(AttLocation.ServiceType.TERMINAL_LOCATION.name(), service.serviceType);
		System.assertEquals(AttLocation.Tolerance.DelayTolerant.name(), service.tolerance);
		System.assertEquals(300, service.requestedAccuracy);
		System.assertEquals(5000, service.acceptableAccuracy);

		// check for parameters loading after return from from end-user authorization page
		service.serviceType = AttLocation.ServiceType.DEVICE_LOCATION.name();
		service.requestedAccuracy = -300;
		service.tolerance = AttLocation.Tolerance.NoDelay.name();
		service.acceptableAccuracy = null;
		
		locationMultiMock.addRequestMock(DLBaseURL + '?tolerance=NoDelay', DLMock);		
		ApexPages.currentPage().getParameters().put('code', TestHttpMockFactory.AUTH_CODE);
		ApexPages.currentPage().getParameters().put('seviceType', service.serviceType);
		ApexPages.currentPage().getParameters().put('requestedAccuracy', String.valueOf(service.requestedAccuracy));
		ApexPages.currentPage().getParameters().put('acceptableAccuracy', String.valueOf(service.acceptableAccuracy));
		ApexPages.currentPage().getParameters().put('tolerance', service.tolerance);

		service = new DemoLocationController();
		System.assertEquals(AttLocation.ServiceType.DEVICE_LOCATION.name(), service.serviceType);
		System.assertEquals(AttLocation.Tolerance.NoDelay.name(), service.tolerance);
		System.assertEquals(0, service.requestedAccuracy);
		System.assertEquals(0, service.acceptableAccuracy);
	}
	
	static testmethod void testLocationService() {
		ApexPages.currentPage().getParameters().put('code', TestHttpMockFactory.AUTH_CODE);
		DemoLocationController service = new DemoLocationController();
				
		// wrong service type
		service.serviceType = null;
		try {
			service.invokeService();
		} catch (AttException ex) {
			System.assertEquals('Unknown location service type: \'' + service.serviceType + '\'', ex.getMessage());
			System.assertEquals(false, service.showResult);
		}
		
		// execute device location service without parameters
		service.serviceType = AttLocation.ServiceType.DEVICE_LOCATION.name();
		service.requestedAccuracy = -150;
		service.acceptableAccuracy = null;
		service.tolerance = null;		
		
		locationMultiMock.addRequestMock(DLBaseURL, DLMock);		
		service.invokeService();
		System.assertEquals(0, service.requestedAccuracy);
		System.assertEquals('37.56099', service.latitude);
		System.assertEquals('-122.30176', service.longitude);
		System.assertEquals('Accuracy: 1630\nLatitude: 37.56099\nLongitude: -122.30176\nTimestamp: 2012-10-19T07:03:27.000-5:00', service.location);
		System.assertEquals(true, service.showResult);
		
		// execute device location service with parameters
		service.serviceType = AttLocation.ServiceType.DEVICE_LOCATION.name();
		service.requestedAccuracy = 99999;
		service.acceptableAccuracy = 3000;
		service.tolerance = AttLocation.Tolerance.LowDelay.name();
		
		locationMultiMock.addRequestMock(DLBaseURL + '?tolerance=LowDelay&requestedAccuracy=20000&acceptableAccuracy=3000', DLMock);
		service.invokeService();
		System.assertEquals(20000, service.requestedAccuracy);
		System.assertEquals('37.56099', service.latitude);
		System.assertEquals('-122.30176', service.longitude);		
		System.assertEquals('Accuracy: 1630\nLatitude: 37.56099\nLongitude: -122.30176\nTimestamp: 2012-10-19T07:03:27.000-5:00', service.location);
		System.assertEquals(true, service.showResult);
		
		// execute terminal location service with parameters
		service.serviceType = AttLocation.ServiceType.TERMINAL_LOCATION.name();
		service.requestedAccuracy = 150;
		service.acceptableAccuracy = 3000;
		service.tolerance = AttLocation.Tolerance.DelayTolerant.name();		
		
		locationMultiMock.addRequestMock(TLBaseURL + '&tolerance=DelayTolerant&requestedAccuracy=150&acceptableAccuracy=3000', TLMock);
		service.invokeService();
		System.assertEquals('37.558826', service.latitude);
		System.assertEquals('-122.30265', service.longitude);		
		System.assertEquals('Accuracy: 1410\nLatitude: 37.558826\nLongitude: -122.30265\nTimestamp: 2012-10-19T07:11:02.000-05:00\nRetrieval Status: Retrieved', service.location);
		System.assertEquals(true, service.showResult);
	}
}