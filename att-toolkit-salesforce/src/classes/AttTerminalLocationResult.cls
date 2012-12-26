/**
 * @description Terminal location method result.
 */
public virtual class AttTerminalLocationResult implements AttLocationResult {
	
	/**
	 * @description Terminal location list.
	 */ 
	public TerminalLocationList terminalLocationList {get; set; }
	
	/**
	 * @description Stores information about terminal location list.
	 */
	public class TerminalLocationList {
		
		/**
	 	 * @description Terminal location.
	     */
		public TerminalLocation terminalLocation { get; set; }
	}
	
	/**
	 * @description Stores information about terminal location.
	 */
	public class TerminalLocation {
		
		/**
	 	 * @description Stores information about current location.
	     */
		public AttCurrentLocation currentLocation { get; set; }
		
		/**
	 	 * @description Retrieval status for location request.
	     */
		public String locationRetrievalStatus { get; set; }
	}
	
	/**
	 * @description Parses JSON string into class fields.
	 * @param json string with AT&T Location service JSON response data.
	 * @return instance of AttTerminalLocationResult class with data from JSON string.
	 */
	public static AttTerminalLocationResult parse(String json) {		
		return (AttTerminalLocationResult) System.Json.deserialize(json, AttTerminalLocationResult.class); 
	}
	
	/**
	 * @description Returns current location data of device location result.
	 * @returns current location data.
	 */
	public virtual AttCurrentLocation getCurrentLocation() {
		return terminalLocationList.terminalLocation.currentLocation;
	}
	
	/**
	 * @description Returns current location data of device location result as string.
	 * @return returns current location data.   
	 */
	public virtual String getCurrentLocationAsString() {
		AttCurrentLocation currentLocation = terminalLocationList.terminalLocation.currentLocation;
		return 'Accuracy: ' + currentLocation.accuracy + '\n' +
			   'Latitude: ' + currentLocation.latitude + '\n' +
			   'Longitude: ' + currentLocation.longitude + '\n' +
			   'Timestamp: ' + currentLocation.timestamp + '\n' +
			   'Retrieval Status: ' + terminalLocationList.terminalLocation.locationRetrievalStatus;
	}
}