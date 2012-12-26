/**
 * @description Provides common implementation of RestErrorHandler interface.
 */
public virtual class RestErrorHandlerImpl implements RestErrorHandler {
	
	/**
	 * @description Error data.
	 */
	public class Error {
		
		/**
		 * @description Error message identifier.
		 */
		public String messageId { get; set; }
		
		/**
		 * @description Error text.
		 */	
		public String text { get; set; }
		
		/**
		 * @description Error text variables.
		 */
		public String variables { get; set; }
	}
	
	/**
	 * @description REST service error data.
	 */
	public class RestError {
		
		/**
		 * @description Service exception.
		 */
		public Error serviceException { get; set; }
		
		/**
		 * @description Policy exception.
		 */
		public Error policyException { get; set; }
	}
	
	/**
	 * @description Responce error data.
	 */
	public class ResponseError {
		
		/**
		 * @description REST service request error.
		 */
		public RestError requestError { get; set; }
		
		/**
		 * @description Common error text.
		 */
		public String error { get; set; }
		
		/**
		 * @description Common error description.
		 */
		public String error_description { get; set; }
		
		/**
		 * @description Returns Error class instance from responce error data. 
		 */
		public Error getError() {
			Error rv = null;
			if (RequestError != null) {
				rv = RequestError.serviceException != null ? RequestError.serviceException 
											: RequestError.policyException;
			} else {
				rv = new Error();
				rv.MessageId = error;
				rv.Text = error_description;
			}
			return rv;
		} 
	}
	
	/**
     * @description Checks for responce service errors if success is false and throw AttException with errors description.
     * @param response HTTP responce object.
     */
    public void checkServiceErrorResponce(HttpResponse response) {
    	String json = response.getBody();
    	AttServiceErrorResponce sError;
    	try {
            sError = AttServiceErrorResponce.parse(json);
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, e.getMessage() + '\n' + e.getStackTraceString());
        }    	
    	if (sError != null && sError.IsSuccess == false && sError.serviceError != null) {
    	   throw new AttException('Service error: Response status code: ' + response.getStatusCode() + ' FaultCode: ' + sError.serviceError.FaultCode + ' FaultDescription: ' + sError.serviceError.FaultDescription + ' FaultMessage: ' + sError.serviceError.FaultMessage);
    	}
    }
	
	/**
	 * @description Checks for responce errors and throw AttException with errors description.
	 * @param response HTTP responce object.
	 */	
	public virtual void checkResponseCode(HttpResponse response) {
		if (response == null) {
			throw new AttException('RestErrorHandlerImpl.checkResponseCode response is null');
		}

		String warn = response.getHeader('Warning');
		if (String.isNotBlank(warn)) {
	        throw new AttException(warn);
	    }
        
        checkResponseCode(response.getStatusCode(), String.escapeSingleQuotes(response.getBody()));
	}
	
	/**
	 * @description Checks for responce body and status code errors and throw AttException with errors description.
	 * @param statusCode responce status code.
	 * @param responseBody responce body.
	 */		
	public virtual void checkResponseCode(Integer statusCode, String responseBody) {
        // check response code
        if (statusCode != 200 && statusCode != 201 && statusCode != 302) {
			responseBody = responseBody.replace('\r', '');
			responseBody = responseBody.replace('\n', '');
        	
        	Error error = parseError(responseBody);System.debug('##@@ ' + error);
        	if (error != null) {
        		throw new AttException(statusCode, error.MessageId, error.Text, error.Variables);
        	} else {
        		throw new AttException(statusCode, 'Unknown status code error. Response Body:', responseBody);
        	}
        }
	}
	
	/**
	 * @description Parses JSON string into Error class fields.
	 * @param json string with AT&T service JSON response data.
	 * @return instance of Error class with data from JSON string.
	 */
	public virtual Error parseError(String json) {
    	ResponseError responseError = null;
    	try {
    		responseError = (ResponseError) System.JSON.deserialize(json, RestErrorHandlerImpl.ResponseError.class);
    	} catch (Exception e) {
    		System.debug(Logginglevel.ERROR, e.getMessage() + '\n' + e.getStackTraceString());
    	}
        return responseError != null ? responseError.getError() : null; 
	}
    
	public static testmethod void testHandler() {
		RestErrorHandlerImpl handler = new RestErrorHandlerImpl();
		try {
			handler.checkResponseCode(null);
		} catch (AttException ex) {
			System.assertEquals('RestErrorHandlerImpl.checkResponseCode response is null', ex.getMessage());
		}
		try {
			handler.checkResponseCode(400, 'SVC0001 error: audio coding not specified');
		} catch (AttException ex) {
			System.assertEquals('Unknown status code error. Response Body: SVC0001 error: audio coding not specified', ex.getMessage());
		}
		try {
			handler.checkResponseCode(401, '{"RequestError": { "policyException": { "MessageId": "POL0001", "Text": "UnAuthorized Request" }}}');
		} catch (AttException ex) {
			System.assertEquals('POL0001: UnAuthorized Request', ex.getMessage());
		}
		try {
			handler.checkResponseCode(403, '{"RequestError": { "policyException": { "MessageId": "POL0001", "Text": "Rate Limit Exceeded" }}}');
		} catch (AttException ex) {
			System.assertEquals('POL0001: Rate Limit Exceeded', ex.getMessage());
		}
		try {
			handler.checkResponseCode(500, 'SVC0001 error: audio coding not specified');
		} catch (AttException ex) {
			System.assertEquals('Unknown status code error. Response Body: SVC0001 error: audio coding not specified', ex.getMessage());
		}
		try {
			handler.checkResponseCode(400, '{"error":"invalid_scope","error_description":"One or more Service(s) in the requested scope are not permitted for the client credentials flow"}');
		} catch (AttException ex) {
			System.assertEquals('invalid_scope: One or more Service(s) in the requested scope are not permitted for the client credentials flow', ex.getMessage());
		}
		try {
			handler.checkResponseCode(200, '');
			handler.checkResponseCode(201, '');
			System.assert(true);
		} catch (AttException ex) {
			System.assertEquals('', ex.getMessage());
		}
	}
}