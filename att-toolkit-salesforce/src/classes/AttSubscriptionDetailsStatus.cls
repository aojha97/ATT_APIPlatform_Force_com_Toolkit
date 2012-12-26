/*
 * @description AttSubscriptionDetailsStatus holds information about details of subscription transaction.
 */
public virtual class AttSubscriptionDetailsStatus {
    
    /*
    * @description Subscription currency
    */
	public String SubscriptionCurrency { get; set; }
	
    /*
    * @description The status used for subscription consumption
    */
    public String Status { get; set; }
	
    /*
    * @description Date on which the subscription is created, according to UTC
    */
    public Datetime CreationDate { get; set; }
	
    /*
    * @description Subscription renewal charge
    */
    public Decimal GrossAmount { get; set; }
	
    /*
    * @description Number of renewals requested when the subscription is created
    */
    public Integer SubscriptionRecurrences { get; set; }
	
    /*
    * @description Flag to indicate whether subscription is active and can be consumed
    */
    public Boolean IsActiveSubscription { get; set; }
	
    /*
    * @description Date on which the current subscription period started, according to UTC.
    */
    public Datetime CurrentStartDate { get; set; }
	
    /*
    * @description Date on which the current subscription period ends, according to UTC.
    */
    public Datetime CurrentEndDate { get; set; }
	
    /*
    * @description The remaining number of renewals
    */
    public Integer SubscriptionRemaining { get; set; }
	
    /*
    * @description Version of service
    */
    public String Version { get; set; }
	
    /*
    * @description A flag indicating the status of the request
    */
    public Boolean IsSuccess { get; set; }
	
	/*
    * @description Default constructor
    */
	public AttSubscriptionDetailsStatus(){
	}

	/*
     * @description Parses input json string to AttSubscriptionDetailsStatus object.
     * @param json A JSON string as responce of get subscription details service.
     * @return parsed subscription details object.
     */
	public static AttSubscriptionDetailsStatus parse(String json) {
		Map<String, Object> fieldMap = (Map<String, Object>)System.JSON.deserializeUntyped(json);
		
        AttSubscriptionDetailsStatus status = new AttSubscriptionDetailsStatus();
        
		status.SubscriptionCurrency = (String)fieldMap.get('Currency');
		
		status.Status = (String)fieldMap.get('Status');
		
		if (fieldMap.get('CreationDate') != null && !String.isBlank((String)fieldMap.get('CreationDate'))) {
			status.CreationDate = Datetime.valueOf(prepareDate((String)fieldMap.get('CreationDate')));
		}
		
		if (fieldMap.get('GrossAmount') != null && !String.isBlank((String)fieldMap.get('GrossAmount'))) {
			status.GrossAmount = Decimal.valueOf((String)fieldMap.get('GrossAmount'));
		}	
		
		if (fieldMap.get('SubscriptionRecurrences') != null && !String.isBlank((String)fieldMap.get('SubscriptionRecurrences'))) {
		  status.SubscriptionRecurrences = Integer.valueOf(fieldMap.get('SubscriptionRecurrences'));
		}	
		
		if (fieldMap.get('IsActiveSubscription') != null && !String.isBlank((String)fieldMap.get('IsActiveSubscription'))) {
			status.IsActiveSubscription = Boolean.valueOf(fieldMap.get('IsActiveSubscription'));
		}
		
		if (fieldMap.get('CurrentStartDate') != null && !String.isBlank((String)fieldMap.get('CurrentStartDate'))) {
			status.CurrentStartDate = Datetime.valueOf(prepareDate((String)fieldMap.get('CurrentStartDate')));
		}
			
		if (fieldMap.get('CurrentEndDate') != null && !String.isBlank((String)fieldMap.get('CurrentEndDate'))) {
			status.CurrentEndDate = Datetime.valueOf(prepareDate((String)fieldMap.get('CurrentEndDate')));
		}
		if (fieldMap.get('SubscriptionRemaining') != null && !String.isBlank((String)fieldMap.get('SubscriptionRemaining'))) {
          status.SubscriptionRemaining = Integer.valueOf(fieldMap.get('SubscriptionRemaining'));
        }
		
		status.Version = (String)fieldMap.get('Version');
		
		if (fieldMap.get('IsSuccess') != null && !String.isBlank((String)fieldMap.get('IsSuccess'))) {
			status.IsSuccess = Boolean.valueOf(fieldMap.get('IsSuccess'));
		}
		
		return status;
	}
	
	private static String prepareDate(String dTime){
		return dTime.replace('T', ' ').replace('Z', '');
	}
	
	static testMethod void testParse() {
		String json = '{'+
		'"Currency":"USD",'+
		'"Status":"ACTIVE",'+
		'"CreationDate":"2012-11-12 15:27:09",'+
		'"GrossAmount":"0.99",'+
		'"SubscriptionRecurrences":"99999",'+
		'"IsActiveSubscription":"true",'+
		'"CurrentStartDate":"2012-11-12 15:27:09",'+
		'"CurrentEndDate":"2012-12-12 15:27:09",'+
		'"SubscriptionRemaining":"214748",'+
		'"Version":"1",'+
		'"IsSuccess":"true"'+
		'}';
		AttSubscriptionDetailsStatus status = parse(json);
		System.assert(status != null);
		System.assertEquals('USD', status.SubscriptionCurrency);
		System.assertEquals('ACTIVE', status.Status);
		System.assertEquals(Datetime.valueOf('2012-11-12 15:27:09'), status.CreationDate);
		System.assertEquals(0.99, status.GrossAmount);
		System.assertEquals(99999, status.SubscriptionRecurrences);
		System.assertEquals(true, status.IsActiveSubscription);
		System.assertEquals(Datetime.valueOf('2012-11-12 15:27:09'), status.CurrentStartDate);
		System.assertEquals(Datetime.valueOf('2012-12-12 15:27:09'), status.CurrentEndDate);
		System.assertEquals(214748, status.SubscriptionRemaining);
		System.assertEquals('1', status.Version);
		System.assertEquals(true, status.IsSuccess);
		
		json = '{"TestAMissingObject": { "TestAMissingArray": [ { "TestAMissingProperty": "Some Value" } ] } }';
		AttSubscriptionDetailsStatus objRoot = parse(json);
		System.assert(objRoot != null);
		System.assert(objRoot.SubscriptionCurrency == null);
		System.assert(objRoot.Status == null);
		System.assert(objRoot.CreationDate == null);
		System.assert(objRoot.GrossAmount == null);
		System.assert(objRoot.SubscriptionRecurrences == null);
		System.assert(objRoot.IsActiveSubscription == null);
		System.assert(objRoot.CurrentStartDate == null);
		System.assert(objRoot.CurrentEndDate == null);
		System.assert(objRoot.SubscriptionRemaining == null);
		System.assert(objRoot.Version == null);
		System.assert(objRoot.IsSuccess == null);
	}
}