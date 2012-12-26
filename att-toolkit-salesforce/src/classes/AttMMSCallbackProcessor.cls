/*
 * @description Class allow defining of MMS callback for processing incomming MMS
 * 
 * For implement incomming MMS processing user should 
 * 1) inherit this class and override method processMessage(AttMMS mms). Method
 *    implememntation can contain any custom logic, like storing MMS as objects or resending as email
 * 2) Create REST callback, define doPost() method where instantiate class defined in previous step.
 * 
 * See DemoMMSInboxCallback for example.
 */
public abstract class AttMMSCallbackProcessor {

	/**
	 * @description create new MMS processor, parse http request and run processMessage method
	 */
	public AttMMSCallbackProcessor() {
		
		RestRequest req = RestContext.request;
		String httpBody = req.requestBody.toString();
		String ctypeHeader = req.headers.get('Content-Type');
		MultipartParser.ContentType ctype = MultipartParser.extractContentType('Content-Type: ' + ctypeHeader);
	
		if (ctype.boundary == null) throw new AttException('Wrong MMS, no one attachment.');
		
		AttMMS mms = parseRequest(httpBody, ctype.boundary);
		processMessage(mms);
	}
	
	/**
	 * @description Parse incoming request.
	 * You dont need to use it directly.
	 */
	public static AttMMS parseRequest(String httpBody, String boundary) {
		MultipartParser.ParseResult rez = MultipartParser.parseHttpBody(httpBody, boundary);
		
		if (rez.mainDocumentContentType.mainType != 'text/xml') 
			throw new AttException('Invalid MMS description. Content type is '+ rez.mainDocumentContentType +', should be text/xml');
			
		AttMMS mms = extractMMSInfo(rez.mainDocument);
		mms.attachments = rez.attachments;
		return mms;
	}
	
	/**
	 * @description Extract MMS info from provided xml documents.
	 * You dont need to use it directly.
	 */
	public static AttMMS extractMMSInfo(String xml) {
		DOM.Document doc = new DOM.Document();     
		try {
			doc.load(xml);   
			DOM.XMLNode root = doc.getRootElement();
			String subject = root.getChildElement('Subject', null).getText();
			String priority = root.getChildElement('Priority', null).getText();
			String phone = root.getChildElement('SenderAddress', null).getText();
			
			AttMMS rez = new AttMMS();
			rez.phoneNumber = phone.replace('tel:', '');
			rez.priority = priority;
			rez.subject = subject;
			return rez;
		} catch (System.XMLException e) {  // invalid XML
			throw new AttException('Wrong mms xml: ' + xml, e);
		}
	}
	
	/**
	 * @description You need to override this method and implement there you custom logic
	 */
	public abstract void processMessage(AttMMS mms);
}