/**
@description Can parse http request body that contain multipart data.
It is recommended to use only parseHttpBody method if you don't sure what do you do.
Support nested attachments, when root documant has attached other multipart document that 
has its own attachments. All attachments will be provided as plain list, without nesting. 

*/
public class MultipartParser {

	/**
	@description Parse httpBody and return ParseResult.
	Require explicit boundary providing, since it sin't contained in httpBody but should be 
	extracted from "Content-Type" header.
	*/
	public static ParseResult parseHttpBody(String httpBody, String boundary) {		
		List<String> pieces = splitByBoundary(httpBody, boundary);
		String mainPiece = pieces.get(0);//First piece is main document, all others are attachments
		
		pieces.remove(0);
		System.debug('parseHttpBody: found ' + pieces.size() + ' attachments');
		List<AttAttachment> atchs = new List<AttAttachment>();
		extractAttachments(pieces, atchs);
		
		//Process main document: find it mimetype and extract content
		ContentType bodyContentType = extractContentType(mainPiece);
		String mainBody = extractBody(mainPiece);
		return new ParseResult(mainBody, bodyContentType, atchs);
	}
	
	/**
	@description Parsing result. Contain contant and mimetype of root document and list of attachments
	*/
	public class ParseResult {
		/**
		 * @description document mime type
		 */
		public ContentType mainDocumentContentType {get;set;}
		
		/**
		 * @description nonparsed document body
		 */ 
		public String mainDocument {get;set;}
		
		/**
		 * @description document's attachments
		 */
		public List<AttAttachment> attachments { get; set; }
		
		/**
		 * @description create parsing result
		 */
		public ParseResult(String mainDocument, ContentType mainDocumentContentType, List<AttAttachment> attachments) {
			this.mainDocument = mainDocument;
			this.mainDocumentContentType = mainDocumentContentType;
			this.attachments = attachments;
		}
	}
	
	/**
	@description Class represent parsed "Content-Type" header.
	For plain documents only mainType field has sence since it comtain mime type of document.
	For multipart thing become more complicated. mainType contain something like 'form/multipart',
	mimetype of root body is contained in subType. And boundary contain string-separator of attached documents.
	*/
	public class ContentType {
		/**
		 * @description Mime type from Content-Type header
		 */
		public String mainType {get;set;}
		
		/**
		 * @description If main type is "multipart/*" then this type contain mime type of document body
		 */
		public String subType {get;set;}
		
		/**
		 * @description boundaty definition extracted from Content-Type header
		 */
		public String boundary {get;set;}
		
		/**
		 * @description true if document consist from several parts
		 */
		public Boolean isComposite() {
			return this.boundary!=null;
		}
	}
	
	/**
     * @description Regexp pattern to extract content mime type 
     */
	public static Pattern CONTENT_MAIN_TYPE_PATTERN = Pattern.compile('^Content-Type:[ ]*([a-zA-Z0-9/]+)');
	
	/**
     * @description Regexp pattern to extract body mime type
     */
	public static Pattern CONTENT_SUB_TYPE_PATTERN = Pattern.compile('[ ;:]+[Tt]ype="([a-zA-Z0-9/]+)"');
	
	/**
     * @description Regexp pattern to extract boundary
     */
	public static Pattern BOUNDARY_PATTERN = Pattern.compile('[ ;:]+[Tb]oundary="([^"]+)"');
	
	/**
     * @description Regexp pattern to file name
     */
	public static Pattern FILENAME_PATTERN = Pattern.compile('[ ;:]+[Nn]ame=([^;]+)');
	
	/**
	@description Take raw piece of multipart file, related to one attached document. 
	It include headers and doby. Then find there row with "Content-Type" header,
	parse it and return ContentType object
	*/
	public static ContentType extractContentType(String piece) {
		String[] lines = piece.split('\n');
		for (String line: lines) {
			line = line.trim();
			if (line.startsWith('Content-Type:')) {
				ContentType rez = new ContentType();
				
				Matcher m = CONTENT_MAIN_TYPE_PATTERN.matcher(line);
				if (!m.find()) throw new AttException('Incorrect Content-Type header: ' + line);
				rez.mainType = m.group(1);
				
				m = CONTENT_SUB_TYPE_PATTERN.matcher(line);
				if (m.find()) {
					rez.subType = m.group(1);
				}
				
				m = BOUNDARY_PATTERN.matcher(line);
				if (m.find()) {
					rez.boundary = m.group(1);
				}
				
				return rez;
			} else if (line.length() == 0){
				throw new AttException('Invalid document. Content type is missing.');
			}
		}
		return null;//never happens, apex compiler is too dummy
	}
	
	/**
	@description Split provide raw part of request body by boundary
	*/
	public static List<String> splitByBoundary(String piece, String boundary) {
		piece = piece.replace('\r', ''); 
		return piece.split('\n--' + boundary + '\n');
	}
	
	/**
	@description Take raw piece of request body related to one document (header and body, separated by \n\n)
	and extract only body 
	*/
	public static String extractBody(String piece) {
		piece = piece.replace('\r', ''); 
		List<String>  tmp = piece.split('\n\n');
		if (tmp.size() < 2) {
			throw new AttException('Invalid document. Attachment body is missed');
		}
		return tmp.get(1);
	}
	
	/**
	@description Take raw piece of request body related to one document (header and body, separated by \n\n).
	Find required header and extract file name from it
	*/
	public static String extractFileName(String piece) {
		String[] lines = piece.split('\n');
		for (String line: lines) {
			line = line.trim();
			if (line.startsWith('Content-Type:')) {
				Matcher m = FILENAME_PATTERN.matcher(line);
				if (m.find()) { 
					return m.group(1).trim();
				} else {
					break;
				}
				
			} else if (line.length() == 0){
				break;
			}
		}
		return '';//file name is missed
	}
	
	/**
	@description Take raw piece of request body related to one document (header and body, separated by \n\n).
	Find required header and extract used encoding from it
	*/
	public static String extractEncoding(String piece) {
		String[] lines = piece.split('\n');
		
		for (String line: lines) {
			line = line.trim();
			if (line.startsWith('Content-Transfer-Encoding:')) {
				String[] splitted = line.split(':');
				if (splitted.size() == 2) {
					return splitted[1].trim();
				} else {
					break; //and throw error
				} 
			} else if (line.length() == 0){
				break;
			}
		}
		throw new AttException('Found invalid file attached. Ecoding type is missed.');
	}
	
	/**
	@description Take list of raw attachments (each include header and body).
	Extract and decoded all attachments and put all into accu
	*/
	public static void extractAttachments(List<String> pieces, List<AttAttachment> accu) {
		for(String piece : pieces) {
			ContentType ctype = extractContentType(piece);
			System.debug('Attachment: ' + ctype);
			if (ctype.isComposite()) {
				System.debug('extractAttachments: found composite attachment, ' + String.valueOf(ctype.mainType) + ' ' + String.valueOf(ctype.subType));
				List<String> pieces1 = splitByBoundary(piece, ctype.boundary);
				pieces1.remove(0);
				extractAttachments(pieces1, accu);
			} else {
				System.debug('extractAttachments: found file, ' + String.valueOf(ctype.mainType));
				
				String encoding = extractEncoding(piece);
				if (encoding.capitalize() == 'BASE64') {
					Blob body = EncodingUtil.base64Decode(extractBody(piece)); //@TODO Support other encoding
					String fileName = extractFileName(piece);
					AttAttachment rez = new AttAttachment(body, fileName, ctype.mainType);
					accu.add(rez);
				} else {
					System.debug('Can\'t decode encoding "' + encoding + '", attachment ' + ctype);
				}
			}
		}
	}
	
}