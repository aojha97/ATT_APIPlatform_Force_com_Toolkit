/**
 * @description Demonstrates how to use AT&T Message Inbox Management API. 
 */
public class DemoMIMController extends AttConsentWorkflow {
	
	/**
	 * @description Action names.
	 */
	public enum Action { GET_HEADERS, GET_CONTENT }
	
	/**
	 * @description End of the headers block indicator.
	 */
	public static final String END_OF_THE_PARTS_BLOCK = '0';
	
	/**
	 * @description Specifies the number of headers being returned.
	 */
	public Integer headerCount { get; set; }
	
	/**
	 * @description Specifies the index value for which the HeaderCount parameter begins the count.
	 */	
	public String indexCursor { get; set; }
	
	/**
	 * @description Headers description string.
	 */
	public String headersDescription { get; set; }
	
	/**
	 * @description Headers list. 
	 */	
	public List<AttMIMMessageHeaders.Headers> headers { get; set; }

	/**
	 * @description Specifies the message identifier.
	 */
	public String messageId { get; set; }
	
	/**
	 * @description Specifies the content identifier.
	 */	
	public Integer partNumber { get; set; }
	
	/**
	 * @description Message content file name.
	 */		
	public String contentFileName { get; set; }
	
	/**
	 * @description Message content.
	 */	
	public transient String content { get; set; }
	
	/**
	 * @description Show message headers flag.
	 */	
	public Boolean showHeadersMessages { get; set; }
	
	/**
	 * @description Show message headers flag.
	 */	
	public Boolean showContentMessages { get; set; }
	
	/**
	 * @description Text content flag.
	 */	
	public Boolean isTextContent { get; set; }
	
	/**
	 * @description Application content flag.
	 */	
	public Boolean isApplicationContent { get; set; }
	
	/**
	 * @description Image content flag.
	 */	
	public Boolean isImageContent { get; set; }
	
	/**
	 * @description Current action. 
	 */
	public Action action { get; set; }
	
	 /**
	 * @description MIM service. 
	 */
	public AttMIM mimService { get; set; }
	
	private final System.Type TEST_CLASS = TestDemoMIMController.class;
	
	/**
	 * Initializes controller fields and services.
	 */
	protected override void initialize() {
		mimService = new AttMIM(auth);		
		headerCount = 50;
		indexCursor = '';
		messageId = 'I3';
		partNumber = 1;
		headersDescription = '';
		showHeadersMessages = true;
		showContentMessages = false;		
		isTextContent = false;
		isApplicationContent = false;
		isImageContent = false;
	}
	
	/**
	 * Returns Messages Inbox Management service scope type.
	 */	
	protected override ServiceConstants.ScopeType[] getConsentScope() {
		return new ServiceConstants.ScopeType[] {ServiceConstants.ScopeType.MIM};
	}

	/**
	 * Loads parameters passed through redirect to AT&T OAuth server.
	 */
	protected override void loadParams(Map<String, String> params) {
		String actionValue = params.get('action');
		if (DemoMIMController.Action.GET_HEADERS.name().equals(actionValue)) {
			action = DemoMIMController.Action.GET_HEADERS;
			String headerCountStr = params.get('HeaderCount');
			headerCount = (String.isBlank(headerCountStr) ? null : Integer.valueOf(headerCountStr));						
			indexCursor = params.get('IndexCursor');			
		} else if (DemoMIMController.Action.GET_CONTENT.name().equals(actionValue)) {
			action = DemoMIMController.Action.GET_CONTENT;
			messageId = params.get('MessageId');
			String partNumberStr = params.get('PartNumber');
			partNumber = (String.isBlank(partNumberStr) ? null : Integer.valueOf(partNumberStr));
		}
	}
	
	/**
	 * @description Invokes AT&T Get Message Headers service.
	 * @return page reference to AT&T OAuth server when authorization is missing.
 	 */
	public Pagereference getMessageHeaders() {
		action = DemoMIMController.Action.GET_HEADERS;
		return invokeService();
	}

	/**
	 * @description Invokes AT&T Get Message Content service.
	 * @return page reference to AT&T OAuth server when authorization is missing. 
 	 */
	public Pagereference getMessageContent() {
		action = DemoMIMController.Action.GET_CONTENT;
		return invokeService();
	}
	
	/**
	 * @description Invokes AT&T MIM Get Headers and Get content services depends on 'action' value.
	 */
	public override void execute() {
		if (DemoMIMController.Action.GET_HEADERS == action) {
			getHeaders();
		} else if (DemoMIMController.Action.GET_CONTENT == action) {
			getContent();
		} else {
			throw new AttException('Wrong action specified: \'' + action + '\'');
		}
	}	

	/**
	 * Invokes AT&T Get Message Headers action and display result.
	 */
	private void getHeaders() {
		try {			
			showHeadersMessages = true;
			showContentMessages = false;				
			checkGetMessageHeadersParams();
			
			correctGetHeadersInputParameters();
			AttMIMMessageHeaders result = mimService.getHeaders(headerCount, indexCursor);
			headerCount = result.messageHeadersList.headerCount;
			headersDescription = 'Listed Headers Count: ' + headerCount + ' from the ' + (String.isBlank(indexCursor) ? 'first element.' : '"' + indexCursor + '" index cursor.');
			indexCursor = result.messageHeadersList.indexCursor;
			if (END_OF_THE_PARTS_BLOCK.equals(indexCursor)) {
				headersDescription += ' Reached the end of the headers list.';
			}
			headers = result.messageHeadersList.headers;
		} catch (Exception ex) {			
			headers = null;
			headersDescription = '';
			throw ex;
		}
	}	
	
	/**
	 * Corrects input parameters for get headers service.
	 */
	 private void correctGetHeadersInputParameters() {
		if (END_OF_THE_PARTS_BLOCK.equals(indexCursor)) {
			indexCursor = '';
		}
		if (!String.isBlank(indexCursor)) {
			indexCursor = indexCursor.trim();
		}
	 }
	 
	/**
	 * Checks for message headers parameters and throws corresponding error.
	 */	
	private void checkGetMessageHeadersParams() {
		if (headerCount == null) {
			throw new AttException('Headers count must be specified');
		} else if (headerCount < 1 || headerCount > 500) { 
			throw new AttException('Headers count must be in range 1..500');
		}
	}
	
	/**
	 * Invokes AT&T Get Message Content action and display result.
	 */
	private void getContent() {		
		try {		
			showHeadersMessages = false;
			showContentMessages = true;
			checkGetMessageContentParams();
							
			AttAttachment mmsAttacment = mimService.getContent(messageId, partNumber);
			identifyAttachment(mmsAttacment);
		} catch (Exception ex) {
			contentFileName = null;
			content = null;
			isTextContent = false;
			isApplicationContent = false;
			isImageContent = false;
			throw ex;
		}
	}
	
	/**
	 * Checks for message content parameters and throws corresponding error.
	 */
	private void checkGetMessageContentParams() {
		if (String.isBlank(messageId)) {
			throw new AttException('Message id must be specified.'); 
		}
		if (partNumber == null) {
			throw new AttException('Part number must be specified');
		} else if (partNumber < 0) {
			throw new AttException('Part number value can\'t be negative');
		}
	}
	
	/**
	 * Identify MMS attachment content type and store data in class fields.
	 */
	private void identifyAttachment(AttAttachment mmsAttacment) {
		contentFileName = mmsAttacment.fileName;
	 	List<String> contentType = mmsAttacment.mimeType.split('/');
		if ('TEXT'.equals(contentType.get(0))) {
			isTextContent = true;
			isApplicationContent = false;
			isImageContent = false;
			content = mmsAttacment.content.toString();
		} else if ('IMAGE'.equals(contentType.get(0))) {
			isTextContent = false;
			isApplicationContent = false;
			isImageContent = true;
			content = 'data:' + mmsAttacment.mimeType + ';base64,' + EncodingUtil.base64Encode(mmsAttacment.content);
		} else {
			isTextContent = false;
			isApplicationContent = true;
			isImageContent = false;
			if ('APPLICATION/SMIL'.equals(mmsAttacment.mimeType)) {
				content = mmsAttacment.content.toString();
			} else {
				content = Encodingutil.base64Encode(mmsAttacment.content);
			}
		}
	}
	
	/**
	 * Returns map with parameters and user input data which should be passed through redirect to AT&T OAuth server.
	 */	
	protected override Map<String, String> getParams() {
		Map<String, String> parameters = new Map<String, String>();
		if (action == DemoMIMController.Action.GET_HEADERS) {
			parameters.put('action', DemoMIMController.Action.GET_HEADERS.name());
			parameters.put('HeaderCount', String.valueOf(headerCount));
			parameters.put('IndexCursor', indexCursor);
		} else if (action == DemoMIMController.Action.GET_CONTENT) {
			parameters.put('action', DemoMIMController.Action.GET_CONTENT.name());
			parameters.put('MessageId', messageId);
			parameters.put('PartNumber', String.valueOf(partNumber));		
		}
		return parameters;	
	}
}