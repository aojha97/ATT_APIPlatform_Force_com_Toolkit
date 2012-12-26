/*
 * @description Demonstrates how to use the AT&T Location API. 
 */
public class DemoLocationController extends AttConsentWorkflow {
	
	/**
	 * @description Location service type options list.
	 */
	public List<SelectOption> serviceOptions { get; set; }
	
	/**
	 * @description Location tolerance options list.
	 */
	public List<SelectOption> toleranceOptions { get; set; }
	
	/**
	 * @description Specifies the accuracy of the request, in meters.
	 */
	public Integer requestedAccuracy { get; set; }
	
	/**
	 * @description Specifies the acceptable accuracy, in meters.
	 */	
	public Integer acceptableAccuracy { get; set; }
	
	/**
	 * @description Service type value.
	 */
	public String serviceType { get; set; }
	
	/**
	 * @description Tolerance value.
	 */
	public String tolerance { get; set; }
	
	/**
	 * @description Location result data.
	 */
	public String location { get; set;}
	
	/**
	 * @description Specifies the current latitude of the geographical position for the mobile device.
	 */	
	public String latitude { get; set; }
	
	/**
	 * @description Specifies the current longitude of the geographical position for the mobile device.
	 */
	public String longitude { get; set; }
	
	/**
	 * @description Show result location result flag.
	 */
	public Boolean showResult { get; set; }
	
	/**
	 * @description Location service.
	 */
	public AttLocation locationService { get; set; }
	
	private final System.Type TEST_CLASS = TestDemoLocationController.class;
	
	/**
	 * Initializes controller fields and services.
	 */
	protected override void initialize() {
 		serviceOptions = new List<SelectOption> {
            new SelectOption(AttLocation.ServiceType.DEVICE_LOCATION.name(), 'Device location of AT&T phone numbers'),
            new SelectOption(AttLocation.ServiceType.TERMINAL_LOCATION.name(), 'Terminal location supporting A-GPS')};
        toleranceOptions = new List<SelectOption> {
            new SelectOption(AttLocation.Tolerance.NoDelay.name(), 'No delay'),
            new SelectOption(AttLocation.Tolerance.LowDelay.name(), 'Low delay'),
            new SelectOption(AttLocation.Tolerance.DelayTolerant.name(), 'Delay tolerant')};
            
		locationService = new AttLocation(auth);
		showResult = false;
		requestedAccuracy = 1000;
		acceptableAccuracy = 3000;
		serviceType = AttLocation.ServiceType.DEVICE_LOCATION.name();		
		tolerance = AttLocation.Tolerance.LowDelay.name();
	}	
	
	/**
	 * Returns Location service scope type.
	 */
	protected override ServiceConstants.ScopeType[] getConsentScope() {
		return new ServiceConstants.ScopeType[] { ServiceConstants.ScopeType.TL };
	}
	
	/**
	 * Loads parameters passed through redirect to AT&T OAuth server.
	 */
	protected override void loadParams(Map<String, String> params) {
		serviceType = params.get('seviceType');		
		String requestedAccuracyStr = params.get('requestedAccuracy');
		requestedAccuracy = (String.isBlank(requestedAccuracyStr) ? 0 : Integer.valueOf(requestedAccuracyStr));
		String acceptableAccuracyStr = params.get('acceptableAccuracy');
		acceptableAccuracy = (String.isBlank(acceptableAccuracyStr) ? 0 : Integer.valueOf(acceptableAccuracyStr));		
		tolerance = params.get('tolerance');
	}
	
	/*
	 * @description Invokes AT&T Get Location service and display result.
	 */	
	public override void execute() {											
		try {
			correctParameters();
			AttLocationResult locationResult = locationService.getLocation(getServiceType(), requestedAccuracy, getTolerance(), acceptableAccuracy);
			AttCurrentLocation currentLocation = locationResult.getCurrentLocation();
			latitude = currentLocation.latitude;
			longitude = currentLocation.longitude;
			location = locationResult.getCurrentLocationAsString();
			showResult = true;
		} catch (Exception ex) {
			showResult = false;
            throw ex;
		}
	}
	
	/*
	 * Corrects input parameters.
	 */
	private void correctParameters() {
		if (requestedAccuracy == null || requestedAccuracy < 0) {
			requestedAccuracy = 0;
		} else if (requestedAccuracy > 20000) {
			requestedAccuracy = 20000;
		}
		
		if (acceptableAccuracy == null || acceptableAccuracy < 0) {
			acceptableAccuracy = 0;
		}
	}
	
	/*
	 * Returns tolerance parameter value, or null when tolerance value is absent.
	 */
	private AttLocation.Tolerance getTolerance() {
		AttLocation.Tolerance toleranceValue = null;
		if (AttLocation.Tolerance.NoDelay.name().equals(tolerance)) {
			toleranceValue = AttLocation.Tolerance.NoDelay;
		} else if (AttLocation.Tolerance.LowDelay.name().equals(tolerance)) {
			toleranceValue = AttLocation.Tolerance.LowDelay;
		} else if (AttLocation.Tolerance.DelayTolerant.name().equals(tolerance)) {
			toleranceValue = AttLocation.Tolerance.DelayTolerant;
		}
		return toleranceValue;
	}
	
	/*
	 * Returns service type parameter value. 
	 * Throws AttException for unknown service type value.
	 */ 
	private AttLocation.ServiceType getServiceType() {
		if (AttLocation.ServiceType.DEVICE_LOCATION.name().equals(serviceType)) {
			return AttLocation.ServiceType.DEVICE_LOCATION;
		} else if (AttLocation.ServiceType.TERMINAL_LOCATION.name().equals(serviceType)) {
			return AttLocation.ServiceType.TERMINAL_LOCATION;
		} else {
			throw new AttException('Unknown location service type: \'' + serviceType + '\'');
		}
	}

	/*
	 * Returns map with parameters and user input data which should be passed through redirect to AT&T OAuth server.
	 */	
	protected override Map<String, String> getParams() {	
		return new Map<String, String> {
			'seviceType' => serviceType,
			'requestedAccuracy' => String.valueOf(requestedAccuracy),
			'tolerance' => tolerance,
			'acceptableAccuracy' => String.valueOf(acceptableAccuracy)
		};
	}	
}