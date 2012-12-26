/*
 * @description AttNotificationAcknowledgeResponse holds information about acknowledge notification response.
 */
public virtual class AttNotificationAcknowledgeResponse {
    
    /*
    * @description Version.
    */
    public String Version  {get; set;}
    
    /*
    * @description A flag indicating the status of the request.
    */
    public Boolean IsSuccess  {get; set;}

    /*
     * @description Parses JSON string into class fields.
     * @param json JSON string as responce of get notification details service.
     * @return parsed notification details object.
     */
    public static AttNotificationAcknowledgeResponse parse(String json) {
    	Map<String, Object> fieldMap = (Map<String, Object>)System.JSON.deserializeUntyped(json);
    	AttNotificationAcknowledgeResponse ackResponse = new AttNotificationAcknowledgeResponse();
    	
    	ackResponse.Version = (String)fieldMap.get('Version');
        
        if (fieldMap.get('IsSuccess') != null) {
            ackResponse.IsSuccess = Boolean.valueOf(fieldMap.get('IsSuccess'));
        }
    	
        return ackResponse;
    }
    
    static testMethod void testParse() {
        String json = '{ '+
        '    "Version":"1", '+
        '    "IsSuccess":"true"'+
        '}';
        AttNotificationAcknowledgeResponse obj = parse(json);
        System.assert(obj != null);
        System.assertEquals(obj.Version, '1');
        System.assertEquals(obj.IsSuccess, true);
    }
}