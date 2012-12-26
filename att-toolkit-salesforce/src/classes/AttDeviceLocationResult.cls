/**
 * @description Device location method result.
 */
public class AttDeviceLocationResult implements AttLocationResult {

	/**
	 * @description Specifies the accuracy of target MSISDN that is used in the Device Location request.
	 */
 	public String accuracy { get; set; }

	/**
	 * @description Specifies the current latitude of the geographical position for the mobile device.
	 */
	public String latitude { get; set; }
	
	/**
	 * @description Specifies the current longitude of the geographical position for the mobile device.
	 */
	public String longitude { get; set; }
	
	/**
	 * @description Specifies the time stamp for the location data.
	 */
	public String timestamp { get; set; }
	
	/**
	 * @description Parses JSON string into class fields.
	 * @param json string with AT&T Location service JSON response data.
	 * @return instance of AttDeviceLocationResult class with data from JSON string.
	 */
	public static AttDeviceLocationResult parse(String json) {		
		return (AttDeviceLocationResult) System.Json.deserialize(json, AttDeviceLocationResult.class);
	}
	
	/**
	 * @description Returns current location data of device location result.
	 * @returns current location data.
	 */
	public AttCurrentLocation getCurrentLocation() {
		return new AttCurrentLocation(accuracy, latitude, longitude, timestamp);
	}
	
	/**
	 * @description Returns current location data of device location result as string.
	 * @return returns current location data.   
	 */
	public String getCurrentLocationAsString() {
		return 'Accuracy: ' + accuracy + '\n' +
			   'Latitude: ' + latitude + '\n' +
			   'Longitude: ' + longitude + '\n' +
			   'Timestamp: ' + timestamp;
	}
}