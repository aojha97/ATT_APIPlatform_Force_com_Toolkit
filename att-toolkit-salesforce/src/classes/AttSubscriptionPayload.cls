/*
 * @description AttSubscriptionPayload describes payload information to be notarized for Subscription Payment Transaction.
 */
public virtual class AttSubscriptionPayload extends AttPayload {
	
	/*
    * @description A subscription ID that this transaction is associated with.
    */
	public String MerchantSubscriptionIdList {set; get;}
    
    /*
    * @description Flag indicating whether the consumer will be charged for a single pay or new subscription if consumer is not subscribed to any of the subscriptions in the merchantSubscriptionIDList.
    */
    public Boolean IsPurchaseOnNoActiveSubscription {set; get;}
    
    /*
    * @description The number of times the subscription is renewed
    */
    public Integer SubscriptionRecurrences {set; get;}
    
    /*
    * @description The interval at which the subscription is charged.
    */
    public String SubscriptionPeriod {set; get;}
    
    /*
    * @description The number of periods that pass between the renewals.
    */
    public Integer SubscriptionPeriodAmount {set; get;}
    
    /*
    * @description Default constructor for AttSubscriptionPayload
    */
    public AttSubscriptionPayload() {        
        super();
        this.SubscriptionPeriod = 'MONTHLY';
        this.IsPurchaseOnNoActiveSubscription = false;
    }
}