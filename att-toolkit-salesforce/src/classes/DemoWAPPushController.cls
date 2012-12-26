/*
 * @description Demonstrates how to use the AT&T WAP Push API. 
 */
public class DemoWAPPushController {
	
	/**
	 * @description Phone number to add to recipients list.
	 */
	public String phone { get; set; }
	
	/**
	 * @description WAP Push message URL.
	 */	
	public String url {get; set;}
	
	/**
	 * @description WAP Push message body.
	 */
	public String message { get; set; }
	
	/**
	 * @description WAP Push message id.
	 */
	public String id { get; set; }
	
	/**
	 * @description Recipient numbers list.
	 */
	public List<String> phoneNumbers { get; set; }
	
	/**
	 * @description WAP Push service.
	 */	
	public AttWAPPush wapPush { get; set; }
	
	private final System.Type TEST_CLASS = TestDemoWAPPushController.class;
	
	/**
	 * @description Constructs controller, initializes fields and services.
	 */
	public DemoWAPPushController() {
		wapPush = new AttWAPPush(new AttClientCredentialsAuthorization(ServiceConstants.ScopeType.WAPPUSH));	
		phoneNumbers = new List<String> {
			correctPhone('+1-650-8631130'),
			correctPhone('16502965430')
		};
		phone = '';
		id = '';
		url = '';
		message = '';
	}
	
	/**
	 * @description Sends message with parameters entered by user.
	 */
	public void sendWAPPush() {		
		try {
			id = '';
			phone = '';
			checkAndCorrectInputParameters();
			wapPush.phoneNumbers = new Set<String>(phoneNumbers);			
			wapPush.url = url;
			wapPush.message = message;
			AttWAPPushResult result = wapPush.sendWAPPush();
			id = result.id;	
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Message has been sent. Message ID: \'' + id + '\''));
		} catch (Exception ex) {
			System.debug(Logginglevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}
	
	/**
	 * @description Adds number to phone numbers list.
	 */	
	public void addNumber() {
		String correctedNum = correctPhone(phone);
		if (String.isNotBlank(correctedNum)) {
			Set<String> numsSet = new Set<String>(phoneNumbers);
			if (!numsSet.contains(correctedNum)) {
				phoneNumbers.add(correctPhone(correctedNum));
			} else {				
				Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'Number \'' + phone + '\' already in phones list.'));
			}
		}
		phone = '';
	}
	
	/**
	 * @description Removes number from numbers list.
	 */
	public void removeNumber() {
		String correctedNum = correctPhone(phone);
		if (String.isNotBlank(correctedNum)) {
			for (Integer ind = phoneNumbers.size() - 1; ind > -1; ind--) {
				if (phoneNumbers.get(ind).equals(correctedNum)) {
					phoneNumbers.remove(ind);
				}
			}
		}
		phone = '';
	}
	
	/**
	 * @description Removes all elements from numbers list.
	 */
	public void clearNumbers() {
		phoneNumbers.clear();
		phone = '';
	} 
	
	/**
	 * Checks and correct input parameters. Throws corresponding exception for wrong input parameters. 
	 */
	private void checkAndCorrectInputParameters() {
		if (phoneNumbers == null || phoneNumbers.size() == 0) {
            throw new AttException('At least one phone number must be specified.'); 
        }
        phone = correctPhone(phone.trim());
        
        if (String.isBlank(url)) {
            throw new AttException('URL must be specified.'); 
        }
        url = url.trim();
        
        if (String.isBlank(message)) {
            throw new AttException('Message must be specified.'); 
        }	
        message = message.trim();
	}	
	
	/**
	 * Corrects phone in accordance with the MSISDN standard.
	 */	
	private String correctPhone(String phone) {
		// replace non-digit characteds 
		phone = phone.replaceAll('\\D', '');
		
		// correct number format
		Integer length = phone.length(); 
		if (length == 10) {
			phone = 'tel:' + phone;
		} else if (length == 11) {
			phone = 'tel:' + phone.substring(1,11);
		}

		return phone;
	}
}