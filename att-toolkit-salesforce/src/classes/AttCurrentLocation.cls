/**
 * @description Stores common information about location. Every type of location result contains current location data.
 */
public virtual class AttCurrentLocation {
	
	/**
	 * @description Specifies the accuracy of target MSISDN that is used in the Location request. 
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
	 * @description Constructs current location with accuracy, latitude, longitude, time stamp.
	 * @param accuracy location accuracy.
	 * @param latitude location latitude.
	 * @param longitude location longitude.
	 * @param timestamp location timestamp.
	 */
	public AttCurrentLocation(String accuracy, String latitude, String longitude, String timestamp) {
		this.accuracy = accuracy;
		this.latitude = latitude;
		this.longitude = longitude;
		this.timestamp = timestamp;
	}
}