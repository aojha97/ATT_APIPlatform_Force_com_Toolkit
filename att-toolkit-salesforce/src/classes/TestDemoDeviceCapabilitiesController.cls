@isTest
public class TestDemoDeviceCapabilitiesController {
    public static testmethod void testController() {
    	
        DemoDeviceCapabilitiesController controller = new DemoDeviceCapabilitiesController();          
        
        ApexPages.currentPage().getParameters().put('code', TestHttpMockFactory.AUTH_CODE);
        DemoDeviceCapabilitiesController testController = new DemoDeviceCapabilitiesController();
         Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"DeviceInfo":{ "DeviceId":{ "TypeAllocationCode" : "01196499"}, "Capabilities":{ "Name" : "LGE CU920","Vendor":  "LGE", ' + 
        '"Model":  "CU920", "FirmwareVersion":  "CU920-MSM4090201D-V10h-FEB-05", "UaProf":"http://gsm.lge.com/html/gsm/LG-CU920.xml", "MmsCapable":  "Y", "AssistedGps":  "Y", "LocationTechnology":  "SUPL2", "DeviceBrowser" : "safari", "WapPushCapable" : "Y" }}}'));
        testController.invokeService();
        
        AttDeviceCapabilities dcResuld = testController.devCapabilities;
        System.assertNotEquals(null, dcResuld);        
        System.assertEquals('01196499', dcResuld.deviceInfo.deviceId.TypeAllocationCode);
        System.assertEquals('LGE CU920', dcResuld.deviceInfo.capabilities.Name);
        System.assertEquals('LGE', dcResuld.deviceInfo.capabilities.Vendor);
        System.assertEquals('CU920', dcResuld.deviceInfo.capabilities.Model);
        System.assertEquals('CU920-MSM4090201D-V10h-FEB-05', dcResuld.deviceInfo.capabilities.FirmwareVersion);
        System.assertEquals('http://gsm.lge.com/html/gsm/LG-CU920.xml', dcResuld.deviceInfo.capabilities.UaProf);
        System.assertEquals('Y', dcResuld.deviceInfo.capabilities.MmsCapable);
        System.assertEquals('Y', dcResuld.deviceInfo.capabilities.AssistedGps);
        System.assertEquals('SUPL2', dcResuld.deviceInfo.capabilities.LocationTechnology);
        System.assertEquals('safari', dcResuld.deviceInfo.capabilities.DeviceBrowser);
        System.assertEquals('Y', dcResuld.deviceInfo.capabilities.WapPushCapable);
    }
    
    
}