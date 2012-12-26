@isTest
public class TestAttTerminalLocation {

	public static testmethod void testParse() {
		String json = '{"terminalLocationList": {"terminalLocation": {"currentLocation": {"accuracy": "1410","latitude": "37.558826","longitude": "-122.30265","timestamp": "2012-10-19T07:11:02.000-05:00" },"locationRetrievalStatus": "Retrieved"}}}';
		AttTerminalLocationResult terminalLocation = AttTerminalLocationResult.parse(json);
		
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