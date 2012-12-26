/*
 * @description AttPayload describes payload information to be notarized for Single Payment Transaction.
 */
public virtual class AttPayload {
    
    /*
    * @description Amount of transaction
    */
    public Decimal Amount {set; get;}
    
    /*
    * @description Product Category 
    */
    public Integer Category {set; get;} 
    
    /*
    * @description Merchant channel. Only value supported is MOBILE_WEB
    */
    public String Channel {set; get;}
    
    /*
    * @description Short description of the entire purchase. Maximum 128 characters.
    */
    public String Description {set; get;}
    
    /*
    * @description The transaction ID in merchant's system which must be unique on every purchase request. 
    */
    public String MerchantTransactionId {set; get;}
    
    /*
    * @description URL that will be used when the transaction is completed and AT&T needs to return control the application.
    */
    public String MerchantPaymentRedirectUrl {set; get;}
    
    /*
    * @description Product ID of product to be purchased in the merchant's system. Maximum of 50 characters.
    */
    public String MerchantProductId {set; get;}
    
    /*
    * @description Default constructor for AttPayload
    */
    public AttPayload() {
        this.Channel = 'MOBILE_WEB';
    }

    /*
     * @description Signs payload object.
     * This method operation is used in conjunction with the Payment.New Transaction 
     * or Payment.New Subscription invocations of the AT&T Payment API.
     * @return AttSignedPayload Signed payload.
     */
    public AttSignedPayload sign() {
        HttpRequest request = createRequest();

        HttpResponse response = execute(request);

        return handleResponse(getResponseBody(response));
    }

    /*
     * @description Creates HTTP request object from internal state of AttPayload object.
     * @return HttpRequest Created transaction request.
     */
    protected virtual HttpRequest createRequest() {
        HttpClient client = UtilityFactory.getHttpClient();        
        HttpRequest request = client.createRequest(ServiceConstants.ServiceType.NOTARY);
        request.setMethod('POST'); 
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        
        Att_Application_Security_Key__c applicationKey = UtilityFactory.getSecurityTokenProvider().getApplicationKey();
        request.setHeader('Client_id', applicationKey.API_Key__c);
        request.setHeader('Client_secret', applicationKey.Secret_Key__c);

		String json = System.JSON.serialize(this);
        request.setBody(json);

        request.setHeader('Content-Length', String.valueOf(request.getBody().length()));
        return request;
    }

    /*
     * @description Executes HTTP request and checks status code of response for common errors.
     * The method will be overrided in unit test classes to return mock HttpResponse object.
     * @param request The request.
     * @return HttpResponse The response from server.
     */
    protected virtual HttpResponse execute(HttpRequest request) {
        HttpResponse response = UtilityFactory.getHttpClient().sendRequest(request);
        UtilityFactory.getRestErrorHandler().checkResponseCode(response);
        return response;
    }

    /*
     * @description Gets response body as String.
     * @param response The request.
     * @return String The response body.
     * 
     */
    protected virtual String getResponseBody(HttpResponse response) {
        return String.escapeSingleQuotes(response.getBody());
    }

    /*
     * @description Handles response from Notary service.
     * @param json A JSON string as responce of device Notary service.
     * @return AttSignedPayload Parsed signed payload object.
     */
    protected virtual AttSignedPayload handleResponse(String json) {
        return AttSignedPayload.parse(json);
    }
}