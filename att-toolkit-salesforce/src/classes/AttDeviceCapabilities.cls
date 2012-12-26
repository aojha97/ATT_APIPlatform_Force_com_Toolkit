/**
 * @description Represents a storage of AT&T Device Capabilities REST service result.
 */
public class AttDeviceCapabilities {

    /*
    * @description DeviceId holds information about device id.
    */
	public class DeviceId {
		
        /**
         * @description The first 8 digits of the International Mobile Equipment Identity of the mobile device.
         */
		public String TypeAllocationCode { get; set; }
	}

    /*
    * @description Holds information about device id and capabilities.
    */
	public DeviceInfo deviceInfo { get; set; }

    /*
    * @description DeviceInfo holds information about device.
    */
	public class DeviceInfo {
		/**
         * @description Object, which contains device identification 
         */
		public DeviceId deviceId { get; set; }
		
		/**
         * @description Object, which contains capabilities 
         */
		public Capabilities capabilities { get; set; }
	}
    /*
    * @description DeviceId holds information about device capabilities.
    */
	public class Capabilities {
		
		/**
         * @description The abbreviated code used by AT&T for the mobile device manufacturer and model number
         */
		public String Name { get; set; }
		
		/**
         * @description The abbreviated code used by AT&T for the manufacturer of the mobile device
         */
        public String Vendor { get; set; }
		
        /**
         * @description The model number used by AT&T for the mobile device
         */
        public String Model { get; set; }
		
        /**
         * @description The firmware release number used by AT&T for the mobile device
         */
        public String FirmwareVersion { get; set; }
		
        /**
         * @description The URL to the website of the device manufacturer where the capability details for the mobile device are found
         */
        public String UaProf { get; set; }
		
        /**
         * @description Specifies that the device is MMS capable
         */
        public String MmsCapable { get; set; }
		
        /**
         * @description Specifies that the device is assisted-GPS capable
         */
        public String AssistedGps { get; set; }
		
        /**
         * @description The location technology network that is supported by the device
         */
        public String LocationTechnology { get; set; }
		
        /**
         * @description The name of the browser that is resident on the device
         */
        public String DeviceBrowser { get; set; }
		
        /**
         * @description Specifies that the device is WAP Push capable
         */
        public String WapPushCapable { get; set; }
	}

	/*
     * @description Parses JSON string into class fields.
     * @param json A JSON string as responce of device capabilities service.
     * @return parsed device capabilities object.
     */
	public static AttDeviceCapabilities parse(String json) {
	System.debug(json);
		return (AttDeviceCapabilities) System.JSON.deserialize(json, AttDeviceCapabilities.class);
	}
	
	static testMethod void testParse() {
		String json = '{"DeviceInfo":{ "DeviceId":{ "TypeAllocationCode" : "01196499"}, "Capabilities":{ "Name" : "LGE CU920",'+
		' "Vendor":  "LGE", "Model":  "CU920", "FirmwareVersion":  "CU920-MSM4090201D-V10h-FEB-05", "UaProf":"http://gsm.lge.com/html/gsm/LG-CU920.xml",'+
		' "MmsCapable":  "Y", "AssistedGps":  "Y", "LocationTechnology":  "SUPL2", "DeviceBrowser" : "safari",'+
		' "WapPushCapable" : "Y" }}}';
		AttDeviceCapabilities obj = parse(json);
		System.assert(obj != null);
		System.assertEquals(obj.DeviceInfo.DeviceId.TypeAllocationCode, '01196499');
		System.assertEquals(obj.DeviceInfo.Capabilities.Name, 'LGE CU920');
		System.assertEquals(obj.DeviceInfo.Capabilities.Vendor, 'LGE');
		System.assertEquals(obj.DeviceInfo.Capabilities.Model, 'CU920');
		System.assertEquals(obj.DeviceInfo.Capabilities.FirmwareVersion, 'CU920-MSM4090201D-V10h-FEB-05');
		System.assertEquals(obj.DeviceInfo.Capabilities.UaProf, 'http://gsm.lge.com/html/gsm/LG-CU920.xml');
		System.assertEquals(obj.DeviceInfo.Capabilities.MmsCapable, 'Y');
		System.assertEquals(obj.DeviceInfo.Capabilities.AssistedGps, 'Y');
		System.assertEquals(obj.DeviceInfo.Capabilities.LocationTechnology, 'SUPL2');
		System.assertEquals(obj.DeviceInfo.Capabilities.DeviceBrowser, 'safari');
		System.assertEquals(obj.DeviceInfo.Capabilities.WapPushCapable, 'Y');
	}
}