/*
 * @description AttSubscriptionPaymentTransaction represents subscription payment transaction for AT&T Payment service.
 */
public virtual class AttSubscriptionPaymentTransaction extends AttPaymentTransaction {

    /*
     * @description The payload of subscription, read only.
     */
	public AttSubscriptionPayload payload { get; private set; }

	protected String subscriptionId;
	
	protected String consumerId;
	
	/*
     * @description Initializes subscription payment transaction for specific subscription payload.
     * @param payload AttSubscriptionPayload The payload for subscription transaction.
	 * @param auth instance for client authentication.
     */
    public AttSubscriptionPaymentTransaction(AttSubscriptionPayload payload, AttClientCredentialsAuthorization auth) {
    	super(auth);
        this.payload = payload;
    }
    
    /*
     * @description Extracts Subscription Authorization Code from redirect URL after payment or throws an error in case of fault during payment.
     * @return subscription Authorization Code of the transaction.
     *
     */
    public static String handleRedirectUrlForSubscriptionAuthorizationCode(){
    	String successPayment = ApexPages.currentPage().getParameters().get('success');    	
        
        if ('false'.equals(successPayment)){
            String faultCode = ApexPages.currentPage().getParameters().get('faultCode');
            String faultDescription = ApexPages.currentPage().getParameters().get('faultDescription');
            String faultMessage = ApexPages.currentPage().getParameters().get('faultMessage');
            throw new AttException('Fault code: ' + faultCode + ' Fault Description: ' + faultDescription + ' Fault Message: ' + faultMessage);
        }
        String subscriptionAuthCode = ApexPages.currentPage().getParameters().get('SubscriptionAuthCode');
        return subscriptionAuthCode;
    }
    
    /*
     * @description Starts subscription payment transaction.
     * @return URL for autorization page redirection.
     */
    public virtual PageReference start() {
        HttpRequest request = createStartTransactionRequest();
        HttpResponse response = execute(request);
		return new PageReference(response.getHeader('Location'));
    }
    
    /*
     * @description Gets status of subscription payment transaction by authorization code.
     * @param authorizationCode Subscription Authorization Code of the transaction returned after successful payment
     * @return the status of the subscription payment transaction.
     */
    public virtual AttSubscriptionStatus getStatusByAuthorizationCode(String authorizationCode) {
    	if (String.isBlank(authorizationCode)) {
            throw new AttException('Authorization Code must be specified.'); 
        }
    	
		HttpRequest request = UtilityFactory.getHttpClient().createRequest(ServiceConstants.ServiceType.GET_SUBSCRIPTION_STATUS_BY_AUTH_CODE, authorizationCode);
		request.setMethod('GET'); 

		HttpResponse response = execute(fillAccessToken(request, auth));

        return handleStatusResponse(response);
    }

    /*
     * @description Gets status of subscription payment transaction by merchant transaction identificator.
     * @return the status of the subscription payment transaction.
     */
    public virtual AttSubscriptionStatus getStatusByMerchantTransactionId() {
    	if (String.isBlank(payload.MerchantTransactionId)) {
            throw new AttException('Merchant Transaction Id must be obtained.'); 
        }
        
		HttpRequest request = UtilityFactory.getHttpClient().createRequest(ServiceConstants.ServiceType.GET_SUBSCRIPTION_STATUS_BY_MERCHANT_TRANSACTION_ID, 
				payload.MerchantTransactionId);
		request.setMethod('GET');

		HttpResponse response = execute(fillAccessToken(request, auth));

        return handleStatusResponse(response);
    }

    /*
     * @description Gets status of subscription payment transaction by subscription id, which returned by a previous call to Get Transaction Status service.
     * @return the status of the subscription payment transaction.
     */
    public virtual AttSubscriptionStatus getStatusBySubscriptionId() {
        return getStatusBySubscriptionId(subscriptionId);
    }
    
    /*
     * @description Gets status of subscription payment transaction by specified subscription id.
     * @param subscriptionId Subscription Id of the transaction returned by a previous call to Get Subscription Status service.
     * @return the status of the subscription payment transaction.
     */
    public virtual AttSubscriptionStatus getStatusBySubscriptionId(String subscriptionId) {
    	if (String.isBlank(subscriptionId)) {
            throw new AttException('Transaction ID must be specified.'); 
        }  
        
        HttpRequest request = UtilityFactory.getHttpClient().createRequest(ServiceConstants.ServiceType.GET_SUBSCRIPTION_STATUS_BY_SUBSCRIPTION_ID, subscriptionId);
		request.setMethod('GET');

		HttpResponse response = execute(fillAccessToken(request, auth));

        return handleStatusResponse(response);
    }
    
    /*
     * @description Gets details of subscription payment transaction by consumer id and Merchant Subscription Id, which returned by a previous call to Get Transaction Status service.
     * @return the status of the subscription payment transaction.
     */
    public virtual AttSubscriptionDetailsStatus getDetails() {    	
        return getDetails(this.consumerId);
    }
    /*
     * @description Gets details of subscription payment transaction by specified consumer id , which returned by a previous call to Get Transaction Status service.
     * @param consumerId Consumer Id of the transaction returned by a previous call to Get Subscription Status service.
     * @return status of the subscription payment transaction.
     */
    public virtual AttSubscriptionDetailsStatus getDetails(String consumerId) {
    	if (String.isBlank(consumerId)) {
            throw new AttException('Consumer ID must be obtained.'); 
        }
        
        if (String.isBlank(payload.MerchantSubscriptionIdList)) {
            throw new AttException('Merchant Subscription Id List must be obtained.'); 
        }
        
        String urlParameters = payload.MerchantSubscriptionIdList + '/Detail/' + consumerId;
        HttpRequest request = UtilityFactory.getHttpClient().createRequest(ServiceConstants.ServiceType.GET_SUBSCRIPTION_DETAILS, urlParameters);
		request.setMethod('GET');
		
		HttpResponse response = execute(fillAccessToken(request, auth));
		String json = String.escapeSingleQuotes(response.getBody());
		return AttSubscriptionDetailsStatus.parse(json);
    }
    
    /*
     * @description Refunds existing subscription transaction with specified reason text.
     * @param reasonText Free text describing the refund reason.
     * @return status of the subscription payment transaction.
     */
    public virtual AttTransactionRefundStatus refund(String reasonText) {
        return refund(this.subscriptionId, reasonText);
    }
    
    /*
     * @description Creates HTTP request for new subscription service call.
     * @return created transaction request.
     */
    protected virtual HttpRequest createStartTransactionRequest() {
        AttSignedPayload signedPayload = payload.sign();

        Att_Application_Security_Key__c applicationKey = UtilityFactory.getSecurityTokenProvider().getApplicationKey();
        String params =  '?SignedPaymentDetail=' + signedPayload.SignedDocument + 
                '&Signature=' + signedPayload.Signature + '&clientid=' + applicationKey.API_Key__c;

        HttpRequest request = UtilityFactory.getHttpClient().createRequest(ServiceConstants.ServiceType.NEW_SUBSCRIPTION, params);
        request.setMethod('GET');     
        return request;
    }  
    
    /*
	 * @description Handles subscription status response in generic way.
	 * @param response The response 
	 * @return parsed status response of the subscription payment transaction.
	 */
	protected virtual AttSubscriptionStatus handleStatusResponse(HttpResponse response) {
        String json = String.escapeSingleQuotes(response.getBody());
		AttSubscriptionStatus status = AttSubscriptionStatus.parse(json);
		this.subscriptionId = status.SubscriptionId;
		this.consumerId = status.ConsumerId;
		return status;
	}
}