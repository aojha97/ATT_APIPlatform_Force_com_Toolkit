/*
 * @description Base interface for location data. Provides common methods to retrieve location data.
 */
public interface AttLocationResult {
	
	/*
	 * @description Returns current location data.
	 * @return current location data.
	 */
	AttCurrentLocation getCurrentLocation();
	
	/*
	 * @description Returns current location data as string.
	 * @return current location data as string.
	 */
	String getCurrentLocationAsString();
}