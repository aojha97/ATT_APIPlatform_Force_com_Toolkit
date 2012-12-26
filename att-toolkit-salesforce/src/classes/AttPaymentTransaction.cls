/*
 * @description Base class for Payment transactions.
 */
public virtual class AttPaymentTransaction {
	
	/**
     * @description Authorization object.
     */
	public AttClientCredentialsAuthorization auth { get; set; }
	protected HttpClient client { get; set; }	
	protected SecurityTokenProvider tokenProvider { get; set; }
	
	/*
     * @description Constructs AttPaymentTransaction object with authorization instance..
	 * @param auth instance for client authentication.
     */
	public AttPaymentTransaction(AttClientCredentialsAuthorization auth) {		
       this.auth = auth;
	   this.client = UtilityFactory.getHttpClient();
       this.tokenProvider = UtilityFactory.getSecurityTokenProvider();
	}
	
    /*
     * @description Refund single payment and subscription payment transaction by transactionId with specified reason text.
     * @param transactionId Transaction Id or Subscription Id depends on transaction type returned by a previous call to Get Transaction(or Subscription) Status service.
     * @return the refund status of the single payment transaction.
     */
    public virtual AttTransactionRefundStatus refund(String id, String reasonText) {
        if (String.isBlank(id)) {
        	if (this instanceof AttSinglePaymentTransaction) {
        	   throw new AttException('Transaction Id must be specified.'); 
        	} else {
        	   throw new AttException('Subscription Id must be specified.'); 
        	}
        }
        
        if (String.isBlank(reasonText)) {
            throw new AttException('Refund Reason must be specified.'); 
        }       
        
        HttpRequest request = client.createRequest(ServiceConstants.ServiceType.REFUND_TRANSACTION, id);    
        request.setMethod('PUT');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        fillAccessToken(request, auth);
        
        JSONGenerator jsonObj = JSON.createGenerator(true);
        jsonObj.writeStartObject();
        jsonObj.writeStringField('TransactionOperationStatus', 'Refunded');
        jsonObj.writeNumberField('RefundReasonCode', 1);
        jsonObj.writeStringField('RefundReasonText', reasonText);
        jsonObj.writeEndObject();
        request.setBody(jsonObj.getAsString());
        request.setHeader('Content-Length', '' + request.getBody().length());
        
        HttpResponse response = execute(request);
                
        return AttTransactionRefundStatus.parse(response.getBody()); 
    }
    
    /*
     * @description Fills Authorization header parameter by access token value.
     */
    protected virtual HttpRequest fillAccessToken(HttpRequest request, AttClientCredentialsAuthorization auth) {
        request.setHeader('Authorization', 'Bearer ' + auth.getAccessToken()); 
        return request;
    }
    
    /*
     * @description Executes HTTP request and checks status code of response for common errors.
     * The method will be overrided in unit test classes to return mock HttpResponse object.
     */
    protected virtual HttpResponse execute(HttpRequest request) {
        HttpResponse response = client.sendRequest(request);
        UtilityFactory.getRestErrorHandler().checkServiceErrorResponce(response);
        UtilityFactory.getRestErrorHandler().checkResponseCode(response);
        return response;
    }
}