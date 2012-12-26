/**
 * @description Contains status information about sent message.
 */
public class AttMoboSendStatus {
	
	/**
	 * @description Contains identifies that confirm successfull message processing by AT&T gateway
	 */
	public String Id {get;set;}
	
	/**
	 * @description Parses json string of http response and create AttMoboSendStatus object.
	 * @param json String representation of server http response body in JSON format.
	 * @return New instance of AttMoboSendStatus object with Id from response
	 */
	public static AttMoboSendStatus parse(String json) {
		AttMoboSendStatus inboxStatus;
		try {
			inboxStatus = (AttMoboSendStatus) System.JSON.deserialize(json, AttMoboSendStatus.class);
		} catch (Exception e) {
			throw new AttException('Cant parse response: ' + json, e);
		}
		return inboxStatus;
	}
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'"Id": "SMSc04091ed284f5684"'+
		'}';
		AttMoboSendStatus result = parse(json);
		System.assert(result.Id == 'SMSc04091ed284f5684');

		json = 'Incorrect response string';
		try {
			result = parse(json);
		} catch (Exception e) {}
	}
}