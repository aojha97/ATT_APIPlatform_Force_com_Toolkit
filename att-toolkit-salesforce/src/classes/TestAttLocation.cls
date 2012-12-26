@isTest
public class TestAttLocation {
	
	static {
		TestHttpMockFactory.MultiRequestMock locationMultiMock = new TestHttpMockFactory.MultiRequestMock(new Map<String, HttpCalloutMock> {
			ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.GET_ACCESS_TOKEN) => TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"access_token":"40da93dc50663e4f2cd9ea5c2c36b54b","expires_in":"-1000","refresh_token":"941744be3d2ddec96bc2de1f2b20bd6c7ca8feae"}'),
			ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.DEVICE_LOCATION) => TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"accuracy": "1630","latitude": "37.56099","longitude": "-122.30176","timestamp": "2012-10-19T07:03:27.000-5:00"}'),
			ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.TERMINAL_LOCATION) + '?address=acr:authorization' => TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"terminalLocationList": {"terminalLocation": {"currentLocation": {"accuracy": "1410","latitude": "37.558826","longitude": "-122.30265","timestamp": "2012-10-19T07:11:02.000-05:00" },"locationRetrievalStatus": "Retrieved"}}}')  
		});
		Test.setMock(HttpCalloutMock.class, locationMultiMock);
	}
	
	static testmethod void testDeviceLocationService() {
		
		// create location service
		AttLocation locationService = new AttLocation(TestHttpMockFactory.getCodeAuthMock());
		AttLocation.ServiceType serviceType = AttLocation.ServiceType.DEVICE_LOCATION;
		Integer requestedAccuracy = 0;
		AttLocation.Tolerance tolerance = null;
		Integer acceptableAccuracy = 0;
		
		// wrong service type
		try {
			locationService.getLocation(null, 0, null, 0);
		} catch (AttException ex) {
			System.assertEquals('Service type must be specified.', ex.getMessage());
		}
		
		// invoke device location service		
		AttLocationResult locationResult = locationService.getLocation(serviceType, requestedAccuracy, tolerance, acceptableAccuracy);
		System.assert(locationResult instanceof AttDeviceLocationResult);

		AttDeviceLocationResult deviceLocation = (AttDeviceLocationResult) locationResult;
		System.assertNotEquals(null, deviceLocation);
		AttCurrentLocation currentLocation = deviceLocation.getCurrentLocation();
		System.assertNotEquals(null, currentLocation);
		System.assertEquals('1630', currentLocation.accuracy);
		System.assertEquals('37.56099', currentLocation.latitude);
		System.assertEquals('-122.30176', currentLocation.longitude);
		System.assertEquals('2012-10-19T07:03:27.000-5:00', currentLocation.timestamp);
		System.assertEquals('Accuracy: 1630\nLatitude: 37.56099\nLongitude: -122.30176\nTimestamp: 2012-10-19T07:03:27.000-5:00', deviceLocation.getCurrentLocationAsString());
	}
	
	static testmethod void testTerminalLocationService() {
		// create location service
		AttLocation locationService = new AttLocation(TestHttpMockFactory.getCodeAuthMock());
		AttLocation.ServiceType serviceType = AttLocation.ServiceType.TERMINAL_LOCATION;
		Integer requestedAccuracy = 0;
		AttLocation.Tolerance tolerance = null;
		Integer acceptableAccuracy = 0;
		
		// invoke terminal location service
		AttLocationResult locationResult = locationService.getLocation(serviceType, requestedAccuracy, tolerance, acceptableAccuracy);
		System.assert(locationResult instanceof AttTerminalLocationResult);
		
		AttTerminalLocationResult terminalLocation = (AttTerminalLocationResult) locationResult;
		System.assertNotEquals(null, terminalLocation);
		System.assertNotEquals(null, terminalLocation.terminalLocationList);
		System.assertNotEquals(null, terminalLocation.terminalLocationList.terminalLocation);
		System.assertNotEquals(null, terminalLocation.terminalLocationList.terminalLocation.currentLocation);
		System.assertEquals('Retrieved', terminalLocation.terminalLocationList.terminalLocation.locationRetrievalStatus);
		AttCurrentLocation currentLocation = terminalLocation.getCurrentLocation();
		System.assertEquals('1410', currentLocation.accuracy);
		System.assertEquals('37.558826', currentLocation.latitude);
		System.assertEquals('-122.30265', currentLocation.longitude);
		System.assertEquals('2012-10-19T07:11:02.000-05:00', currentLocation.timestamp);
		System.assertEquals('Accuracy: 1410\nLatitude: 37.558826\nLongitude: -122.30265\nTimestamp: 2012-10-19T07:11:02.000-05:00\nRetrieval Status: Retrieved', terminalLocation.getCurrentLocationAsString());
	}
}