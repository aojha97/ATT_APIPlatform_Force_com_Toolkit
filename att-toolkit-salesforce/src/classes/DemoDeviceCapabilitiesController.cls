public class DemoDeviceCapabilitiesController extends AttConsentWorkflow {
	
    public String debug {get; set;}
    public AttDeviceCapabilities devCapabilities {get; set;}
    private AttDeviceCapabilitiesService dcSevice;    
    private final System.Type TEST_CLASS = TestDemoDeviceCapabilitiesController.class;

    /*
     * Initiazlize controller fields and services
     */
    protected override void initialize() {
       dcSevice = new AttDeviceCapabilitiesService(auth);
    }
    
	/**
	 * Returns Device Capabilities service scope type.
	 */
	protected override ServiceConstants.ScopeType[] getConsentScope() {
        return new ServiceConstants.ScopeType[] {ServiceConstants.ScopeType.DEVICE_CAPABILITIES};
    }
    
    protected override void loadParams(Map<String, String> params) {
    }
    
    public override void execute() {                
        devCapabilities = dcSevice.getDeviceCapabilities();
    }
    
    protected override Map<String, String> getParams() {               
        return new Map<String, String>();  
    }    
}