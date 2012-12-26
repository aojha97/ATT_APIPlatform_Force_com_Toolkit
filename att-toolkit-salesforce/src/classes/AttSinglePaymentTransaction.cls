/*
 * @description AttSinglePaymentTransaction represents single payment transaction for AT&T Payment service.
 */
public virtual class AttSinglePaymentTransaction extends AttPaymentTransaction {

    /*
     * @description The payload of transaction, read only.
     */
    public AttPayload payload { get; private set; }
    
    protected String transactionId;

    /*
     * @description Initializes single payment transaction for specific payload.
     * @param payload AttPayload The payload for single transaction.
	 * @param auth instance for client authentication.
     */
    public AttSinglePaymentTransaction(AttPayload payload, AttClientCredentialsAuthorization auth) {
    	super(auth);
        this.payload = payload;
    }
    
    /*
     * @description Extracts Authorization Code from redirect URL after payment or throws an error in case of fault during payment.
     * @return authorization code of the transaction.
     */
    public static String handleRedirectUrlForAuthorizationCode(){
        String successBuying = ApexPages.currentPage().getParameters().get('success');
        if ('false'.equals(successBuying)){
            String faultCode = ApexPages.currentPage().getParameters().get('faultCode');
            String faultDescription = ApexPages.currentPage().getParameters().get('faultDescription');
            String faultMessage = ApexPages.currentPage().getParameters().get('faultMessage');
            throw new AttException('Fault code: ' + faultCode + ' Fault Description: ' + faultDescription + ' Fault Message: ' + faultMessage);
        }
        String transactionAuthCode = ApexPages.currentPage().getParameters().get('TransactionAuthCode');
        return transactionAuthCode;
    }

    /*
     * @description Starts single payment transaction.
     * @return URL for autorization page redirection.
     */
    public virtual PageReference start() {
        HttpRequest request = createStartTransactionRequest();
        HttpResponse response = execute(request);
		return new PageReference(response.getHeader('Location'));
    }

    /*
     * @description Gets status of single payment transaction by authorization code.
     * @param authorizationCode Authorization Code of the transaction returned after successful payment
     * @return the status of the single payment transaction.
     */
    public virtual AttTransactionStatus getStatusByAuthorizationCode(String authorizationCode) {
    	if (String.isBlank(authorizationCode)) {
            throw new AttException('Authorization Code must be specified.'); 
        }
        
		HttpRequest request = client.createRequest(ServiceConstants.ServiceType.GET_TRANSACTION_STATUS_BY_AUTH_CODE, authorizationCode);
		request.setMethod('GET');

		HttpResponse response = execute(fillAccessToken(request, auth));

        return handleStatusResponse(response);
    }

    /*
     * @description Gets status of single payment transaction by merchant transaction identificator.
     * @return the status of the single payment transaction.
     */
    public virtual AttTransactionStatus getStatusByMerchantTransactionId() {
    	if (String.isBlank(payload.MerchantTransactionId)) {
            throw new AttException('Merchant Transaction Id must be obtained.'); 
        }
        
		HttpRequest request = client.createRequest(ServiceConstants.ServiceType.GET_TRANSACTION_STATUS_BY_MERCHANT_TRANSACTION_ID, 
				payload.MerchantTransactionId);
		request.setMethod('GET');

		HttpResponse response = execute(fillAccessToken(request, auth));

        return handleStatusResponse(response);
    }

    /*
     * @description Gets status of single payment transaction by transaction id, which returned by a previous call to Get Transaction Status service.
     * @return the status of the single payment transaction.
     */
    public virtual AttTransactionStatus getStatusByTransactionId() {
        return getStatusByTransactionId(transactionId);
    }
    
    /*
     * @description Gets status of single payment transaction by specified transaction id.
     * @param transactionId Transaction Id of the transaction returned by a previous call to Get Subscription Status service.
     * @return the status of the single payment transaction.
     */
    public virtual AttTransactionStatus getStatusByTransactionId(String transactionId) {
    	if (String.isBlank(transactionId)) {
            throw new AttException('Transaction ID must be specified.'); 
        }  
        
        HttpRequest request = client.createRequest(ServiceConstants.ServiceType.GET_TRANSACTION_STATUS_BY_TRANSACTION_ID, transactionId);
		request.setMethod('GET');

		HttpResponse response = execute(fillAccessToken(request, auth));

        return handleStatusResponse(response);
    }

    /*
     * @description Refunds existing single payment transaction with specified reason text.
     * @return the refund status of the single payment transaction.
     */
    public virtual AttTransactionRefundStatus refund(String reasonText) {
        return refund(transactionId, reasonText);
    }

    /*
     * @description Creates HTTP request for new transaction service call.
     * @return created transaction request.
     */
    protected virtual HttpRequest createStartTransactionRequest() {
        AttSignedPayload signedPayload = payload.sign();

        Att_Application_Security_Key__c applicationKey = tokenProvider.getApplicationKey();
        String params =  '?SignedPaymentDetail=' + signedPayload.SignedDocument + 
                '&Signature=' + signedPayload.Signature + '&clientid=' + applicationKey.API_Key__c;

        HttpRequest request = client.createRequest(ServiceConstants.ServiceType.NEW_TRANSACTION, params);
        request.setMethod('GET');     
        return request;
    }

	/*
	 * @description Handles transaction status response in generic way.
	 * @return parsed status responce of the single payment transaction.
	 */
	protected virtual AttTransactionStatus handleStatusResponse(HttpResponse response) {
        String json = String.escapeSingleQuotes(response.getBody());
		AttTransactionStatus status = AttTransactionStatus.parse(json);
		this.transactionId = status.TransactionId;
		return status;
	}
}