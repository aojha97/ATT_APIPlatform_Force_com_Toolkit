/**
 * @description Represents one document that can be attached to http based messages.
 * It includes content as Blob, name and mimetype.
 * You also can specify one of '8bit' and 'base64' encoding, default is base64.
 */
public virtual class AttAttachment {
	
	private static final Map<String,String> extToMimeMap = new Map<String,String> {
		'txt' => 'text/plain',
		'jpg' => 'image/jpeg',
		'jpeg'=> 'image/jpeg',
		'gif' => 'image/gif',
		'3gp' => 'video/3gpp',// isn't tested
		'mp4' => 'video/mp4',// isn't tested
		'amr' => 'audio/amr',
		'mid' => 'audio/midi',
		'midi'=> 'audio/midi',
		'mp3' => 'audio/mpeg',
		'aac' => 'audio/x-aac',// isn't tested
		'wav' => 'audio/x-wav',
		'pdf' => 'application/pdf',
		'png' => 'image/png'};

	/**
	 * @description Specifies the 'base64' content transfer encoding for attachment.
	 */
	public static final String ENCODING_BASE64 = 'base64';
	
	/**
	 * @description Specifies the '8bit' content transfer encoding for attachment.
	 */
	public static final String ENCODING_8BIT = '8bit';

	/**
	 * @description Contains binary data of attachment.
	 */
	public Blob content { get; set; }
	
	/**
	 * @description Contains file name of attachment.
	 */
	public String fileName { get; set; }
	
	/**
	 * @description Contains MIME type of attachment.
	 */
	public String mimeType { get; set; }
	
	/**
	 * @description Contains content transfer encoding of attachment.
	 */
	public String contentTransferEncoding { get; set; }

	/**
	 * @description Provides conversion from file extention to mime type. It can be used but 
	 * don't rely on it, since there are some limitations, include:
	 *  - mime type really should be determined base on file content, not extention
	 *  - a lot of mime type exists (several hundreds), but this method support about 10 most used.
	 * @param fileName Name of file is used for attachment construction.
	 * @return The MIME type.
	 * @throws AttException if the MIME type cannot be determined or is not supported.
	 */
	public static String getMimeTypeByFileName(String fileName) {
		String fileExt = fileName.substringAfterLast('.').toLowerCase();
		String mimeType = extToMimeMap.get(fileExt);
		if (mimeType != null) return mimeType;
		throw new AttException('Unrecognized file extension "' + String.valueOf(fileExt) + '"'); //String.valueOf to avoid NullPointerException
	}

	/**
	 * @description Constructs new AttAttachment instance with 'base64' encoding.
	 * @param content Binary data for attachment.
	 * @param fileName Name of file is used for attachment construction.
	 * @param contentType MIME type for attachment which is creating.
	 */
	public AttAttachment(Blob content, String fileName, String contentType) {
    	this(content,fileName,contentType,ENCODING_BASE64);
    }
    
    /**
	 * @description Constructs new AttAttachment instance with specific encoding.
	 * @param content Binary data for attachment.
	 * @param fileName Name of file is used for attachment construction.
	 * @param contentType MIME type for attachment which is creating.
	 * @param contentTransferEncoding Specifies content transfer encoding for attachment.
	 */
    public AttAttachment(Blob content, String fileName, String contentType, String contentTransferEncoding) {
    	this.content = content;
    	this.fileName = fileName;
    	this.mimeType = contentType;
    	this.contentTransferEncoding = contentTransferEncoding;
    }

	/**
	 * @description Convert current document into string that can be added to http request.
	 * @param contentID Unique identifier which will be used for 'Content-ID' field of MIME part.
	 * @return A textual representation of attachment.
	 * @throws AttException if the content transfer encoding is not supported.
	 */
    public virtual String toHttpRequestPart(String contentID) {
    	String mimePart =
    		'Content-Type: ' + mimeType + '; name="' + fileName + '"\n' +
			'Content-Disposition: form-data; name="' + fileName + '"; filename="' + fileName + '"\n' +
			'Content-ID: ' + contentID + '\n' +
			'Content-Location: ' + fileName + '\n' +
			'Content-Transfer-Encoding: ' + contentTransferEncoding + '\n\n';

		if (contentTransferEncoding == ENCODING_BASE64) {
			return mimePart + EncodingUtil.base64Encode(content) +'\n';
		} else if (contentTransferEncoding == ENCODING_8BIT) {
			return mimePart + content.toString() +'\n';
		}
		throw new AttException('Unsupported transfer encoding...');
    }
}