/**
 * @description Represents object returned from server in case of serrvice error.
 */
public class AttServiceErrorResponce {

    /**
      * @description Success of given request to server.
      */
    public Boolean IsSuccess;
    
    /**
      * @description Version.
      */
    public String Version;
    
    /**
      * @description Service error object.
      */
    public ServiceError serviceError;

    /**
      * @description Service error.
      */
    public class ServiceError {
    	/**
         * @description Error fault code.
         */
        public String FaultCode;
        
        /**
         * @description Error description.
         */
        public String FaultDescription;
        
        /**
         * @description Error message.
         */
        public String FaultMessage;
    }

    /*
     * @description Parses JSON string into class fields.
     * @param json A JSON string as responce of service error.
     * @return AttServiceErrorResponce Parsed service error object.
     */
    public static AttServiceErrorResponce parse(String json) {
        Map<String, Object> fieldMap = (Map<String, Object>)System.JSON.deserializeUntyped(json);
        AttServiceErrorResponce sError = new AttServiceErrorResponce();
        
        sError.Version = (String)fieldMap.get('Version');
        
        if (fieldMap.get('IsSuccess') != null) {
            sError.IsSuccess = Boolean.valueOf(fieldMap.get('IsSuccess'));
        }
        
        if (fieldMap.get('ServiceError') != null) {
            Map<String, Object> sMap = (Map<String, Object>)fieldMap.get('ServiceError');
            sError.serviceError = new ServiceError();
            
            sError.serviceError.FaultCode = (String)sMap.get('FaultCode');
            sError.serviceError.FaultDescription = (String)sMap.get('FaultDescription');
            sError.serviceError.FaultMessage = (String)sMap.get('FaultMessage');           
        }       
        
        return sError;
    }
    
    static testMethod void testParse() {
        String json = '{'+
        '   \"IsSuccess\": \"false\",'+
        '   \"Version\": \"1\",'+
        '   \"ServiceError\":'+
        '   {'+
        '       \"FaultCode\":\"PMT-0098\",'+
        '       \"FaultDescription\":\"Internal error\",'+
        '       \"FaultMessage\":\"Internal error\"'+
        '   }'+
        '}';
        AttServiceErrorResponce obj = parse(json);
        System.assert(obj != null);
    }
}