@isTest
public class TestAttDeviceLocation {

	public static testmethod void testParse() {
		String json = '{"accuracy": "1630","latitude": "37.56099","longitude": "-122.30176","timestamp": "2012-10-19T07:03:27.000-05:00"}';
		AttDeviceLocationResult deviceLocation = AttDeviceLocationResult.parse(json);
		
		System.assertNotEquals(null, deviceLocation);
		AttCurrentLocation currentLocation = deviceLocation.getCurrentLocation();
		System.assertNotEquals(null, currentLocation);
		System.assertEquals('1630', currentLocation.accuracy);
		System.assertEquals('37.56099', currentLocation.latitude);
		System.assertEquals('-122.30176', currentLocation.longitude);
		System.assertEquals('2012-10-19T07:03:27.000-05:00', currentLocation.timestamp);
		System.assertEquals('Accuracy: 1630\nLatitude: 37.56099\nLongitude: -122.30176\nTimestamp: 2012-10-19T07:03:27.000-05:00', deviceLocation.getCurrentLocationAsString());
	}
}