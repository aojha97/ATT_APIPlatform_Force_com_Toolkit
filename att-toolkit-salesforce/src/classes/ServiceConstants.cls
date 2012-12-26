/**
 * @description AT&T REST services types, scopes, names and URL constants.
 */
public class ServiceConstants {
	
	/**
      * @description AT&T services types enumeration. 
      */
	public enum ServiceType {
		SPEECH, SEND_SMS, GET_SMS_INBOX, SEND_MMS, NOTARY, DEVICE_LOCATION, TERMINAL_LOCATION, GET_ACCESS_TOKEN, 
		MOBO, MIM, WAP_PUSH, GET_TRANSACTION_STATUS_BY_AUTH_CODE, AUTHORIZE,
		GET_TRANSACTION_STATUS_BY_TRANSACTION_ID, GET_TRANSACTION_STATUS_BY_MERCHANT_TRANSACTION_ID, NEW_TRANSACTION, REFUND_TRANSACTION, NEW_SUBSCRIPTION,
		GET_SUBSCRIPTION_STATUS_BY_AUTH_CODE, GET_SUBSCRIPTION_STATUS_BY_SUBSCRIPTION_ID, GET_SUBSCRIPTION_STATUS_BY_MERCHANT_TRANSACTION_ID, GET_SUBSCRIPTION_DETAILS,
		GET_DEVICE_CAPABILITIES, GET_NOTIFICATION, ACKNOLEDGE_NOTIFICATION
	}
	
	/**
	 * AT&T services host.
	 */
	private static final String HOST = 'https://api.att.com';

	/**
	 * Map services types on AT&T REST services URI's. 
	 */
	private static Map<ServiceConstants.ServiceType, String> serviceTypeToUrlMap = new Map<ServiceConstants.ServiceType, String> {
		ServiceConstants.ServiceType.SPEECH => '/rest/2/SpeechToText',
		ServiceConstants.ServiceType.SEND_SMS => '/rest/sms/2/messaging/outbox',
		ServiceConstants.ServiceType.GET_SMS_INBOX => '/rest/sms/2/messaging/inbox',
		ServiceConstants.ServiceType.SEND_MMS => '/rest/mms/2/messaging/outbox',
		ServiceConstants.ServiceType.NOTARY => '/Security/Notary/Rest/1/SignedPayload',
		ServiceConstants.ServiceType.DEVICE_LOCATION => '/2/devices/location',
		ServiceConstants.ServiceType.TERMINAL_LOCATION => '/gsma/2/location/queries/location',
		ServiceConstants.ServiceType.GET_ACCESS_TOKEN => '/oauth/token',
		ServiceConstants.ServiceType.MOBO => '/rest/1/MyMessages',
		ServiceConstants.ServiceType.MIM => '/rest/1/MyMessages',
		ServiceConstants.ServiceType.WAP_PUSH => '/1/messages/outbox/wapPush',
		ServiceConstants.ServiceType.AUTHORIZE => '/oauth/authorize',
		ServiceConstants.ServiceType.NEW_TRANSACTION => '/rest/3/Commerce/Payment/Transactions',
		ServiceConstants.ServiceType.GET_TRANSACTION_STATUS_BY_TRANSACTION_ID => '/rest/3/Commerce/Payment/Transactions/TransactionId/',
		ServiceConstants.ServiceType.GET_TRANSACTION_STATUS_BY_MERCHANT_TRANSACTION_ID => '/rest/3/Commerce/Payment/Transactions/MerchantTransactionId/',
		ServiceConstants.ServiceType.GET_TRANSACTION_STATUS_BY_AUTH_CODE => '/rest/3/Commerce/Payment/Transactions/TransactionAuthCode/',
		ServiceConstants.ServiceType.REFUND_TRANSACTION => '/rest/3/Commerce/Payment/Transactions/',
		ServiceConstants.ServiceType.NEW_SUBSCRIPTION => '/rest/3/Commerce/Payment/Subscriptions',
		ServiceConstants.ServiceType.GET_SUBSCRIPTION_STATUS_BY_SUBSCRIPTION_ID => '/rest/3/Commerce/Payment/Subscriptions/SubscriptionId/',
		ServiceConstants.ServiceType.GET_SUBSCRIPTION_STATUS_BY_MERCHANT_TRANSACTION_ID => '/rest/3/Commerce/Payment/Subscriptions/MerchantTransactionId/',
		ServiceConstants.ServiceType.GET_SUBSCRIPTION_STATUS_BY_AUTH_CODE => '/rest/3/Commerce/Payment/Subscriptions/SubscriptionAuthCode/',
		ServiceConstants.ServiceType.GET_SUBSCRIPTION_DETAILS => '/rest/3/Commerce/Payment/Subscriptions/',
		ServiceConstants.ServiceType.GET_DEVICE_CAPABILITIES => '/rest/2/Devices/Info',
		ServiceConstants.ServiceType.GET_NOTIFICATION => '/rest/3/Commerce/Payment/Notifications/', 
		ServiceConstants.ServiceType.ACKNOLEDGE_NOTIFICATION => '/rest/3/Commerce/Payment/Notifications/'
	};
	
	/**
	 * @description Maximum request timeout to AT&T services.
	 */
	public static final Integer REQUEST_TIME_OUT = 60000;
	
	/**
	 * @description AT&T services scope types enumeration.
	 */	
	public enum ScopeType {
	    SMS, MMS, SPEECH, PAYMENT, WAPPUSH, TL, MOBO, MIM, DEVICE_CAPABILITIES
	}

	/**
   	 * Map scope types on AT&T services scope names.
	 */
	private static Map<ServiceConstants.ScopeType, String> typeToScopeMap = new Map<ServiceConstants.ScopeType, String> {
	    ServiceConstants.ScopeType.SMS => 'SMS',
	    ServiceConstants.ScopeType.MMS => 'MMS',
	    ServiceConstants.ScopeType.SPEECH => 'SPEECH',
	    ServiceConstants.ScopeType.PAYMENT => 'PAYMENT',
	    ServiceConstants.ScopeType.WAPPUSH => 'WAP',
	    ServiceConstants.ScopeType.TL => 'TL',
	    ServiceConstants.ScopeType.MOBO => 'IMMN',
	    ServiceConstants.ScopeType.MIM => 'MIM',
	    ServiceConstants.ScopeType.DEVICE_CAPABILITIES => 'DC'
	};
    
	/**
	 * @description Returns AT&T REST service URL by service type.
	 * @param serviceType service type.
	 * @return AT&T REST service URL.
	 */	
	public static String getUrlByServiceType(ServiceConstants.ServiceType serviceType) {
		if (serviceType == null) {
			throw new AttException('ServiceConstants.getUrlByServiceType: serviceType is null');
		}
		
		String url = serviceTypeToUrlMap.get(serviceType);
		if (String.isBlank(url)) {
			throw new AttException('ServiceConstants.getUrlByServiceType: serviceType <' + serviceType.name() + '> is not recognized');
		}

		return ServiceConstants.HOST + url; 
	}
	
	/**
	 * @description Returns AT&T service scope string by scope type.
	 * @param scopeType scope type.
	 * @return AT&T service scope string.
	 */	
	public static String getScopeByType(ServiceConstants.ScopeType scopeType) {
		if (scopeType == null) {
			throw new AttException('ServiceConstants.getScopeByType: scopeType is null');
		}
		return getScopeByType(new ServiceConstants.ScopeType[] {scopeType});
	}
	
	/**
	 * @description Returns AT&T services scope string by scope types list.
	 * @param scopeTypeList list of scope types.
	 * @return AT&T services scope string.
	 */		
	public static String getScopeByType(ServiceConstants.ScopeType[] scopeTypeList) {
		if (scopeTypeList == null) {
			throw new AttException('ServiceConstants.getScopeByType: scopeTypeList is null');
		}

		String rv = ''; 
		for (ServiceConstants.ScopeType scopeType : scopeTypeList) {
			if (scopeType == null) {
				throw new AttException('ServiceConstants.getScopeByType: scopeType is null');
			}
			
			String scope = typeToScopeMap.get(scopeType);
			if (String.isBlank(scope)) {
				throw new AttException('ServiceConstants.getScopeByType: scopeType <' + scopeType.name() + '> is not recognized');
			}
			
			if (String.isNotBlank(rv)) {
				rv += ',';
			}
			
			rv += scope;
		}

		if (String.isBlank(rv)) {
			throw new AttException('ServiceConstants.getScopeByType: scope type list not recognized or empty');
		}

		return rv; 
	}
}