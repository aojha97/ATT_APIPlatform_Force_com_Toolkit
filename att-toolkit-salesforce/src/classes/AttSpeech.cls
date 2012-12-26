/**
* @description Facade class used to invoke AT&T Speech To Text API.
*/
public virtual class AttSpeech {

		/**
		 * @description Authorization object.
		 */
		public AttClientCredentialsAuthorization auth { get; set; }
			
		/**
		* @description Ennumeration of supported audio file types.
		*/
		public enum FileType {WAV, AMR, AMRWB, XWAV, XSPEEX}

		/**
		* @description Ennumeration of supported speech contexts.
		*/
		public enum SpeechContext {GENERIC, TV, BUSINESSSEARCH, WEBSEARCH, SMS, VOICEMAIL, QNA}

		// Content types map
        protected Map<AttSpeech.FileType, String> audioTypeMap = new Map<AttSpeech.FileType, String> {
        	AttSpeech.FileType.WAV => 'audio/wav',
        	AttSpeech.FileType.AMR => 'audio/amr',
        	AttSpeech.FileType.AMRWB => 'audio/amr-wb',
			AttSpeech.FileType.XWAV => 'audio/x-wav',
			AttSpeech.FileType.XSPEEX => 'audio/x-speex'
        };
        
        // Speech context
        protected Map<AttSpeech.SpeechContext, String> contextMap = new Map<AttSpeech.SpeechContext, String> {
        	AttSpeech.SpeechContext.GENERIC => 'Generic',
        	AttSpeech.SpeechContext.TV => 'TV',
        	AttSpeech.SpeechContext.BUSINESSSEARCH => 'BusinessSearch',
        	AttSpeech.SpeechContext.WEBSEARCH => 'Websearch',
        	AttSpeech.SpeechContext.SMS => 'SMS',
        	AttSpeech.SpeechContext.VOICEMAIL => 'Voicemail',
        	AttSpeech.SpeechContext.QNA => 'QuestionAndAnswer'
        };

		/**
		* @description Property for setting/getting speech context. The default value is GENERIC.
		*/
        public AttSpeech.SpeechContext speechContext { get; set; }

		/**
		* @description Property for setting/getting file type.
		*/
        public AttSpeech.FileType fileType { get; set; }

		/**
		* @description Property for setting/getting binary audio data.
		*/
        public Blob fileBlob { get; set; }
        
		/**
		* @description Constructs Speech service with authorization instance.
		* @param auth instance for client authentication.
		*/
		public AttSpeech(AttClientCredentialsAuthorization auth) {
			this.auth = auth;
			speechContext = AttSpeech.SpeechContext.GENERIC;
		}
		
		private virtual void validateParameters() {
			if (fileType == null) {
				throw new AttException('File type is required parameter.'); 
			}        	
			
			if (fileBlob == null) {
				throw new AttException('File BLOB is required parameter.'); 
			}        	
		}
		
		protected virtual String getSpeechContextAsString() {
        	String context = contextMap.get(speechContext); 
        	
        	if (String.isBlank(context)) {
	        	context = contextMap.get(AttSpeech.SpeechContext.GENERIC);
        	}
        	
			return context;
		}
		
		protected virtual String getFileTypeAsString() {
    		return audioTypeMap.get(fileType);
		}
		
		/**
		* @description Send audio file data to AT&T speech service to convert it to text.
		* @return AttSpeechResult instance.
		*/
        public virtual AttSpeechResult convert() {
        	AttSpeechResult result = null;

			validateParameters();
				    		
			String accessToken = auth.getAccessToken();        	

        	String context = getSpeechContextAsString();

    		String audioType = getFileTypeAsString();
    		
    		HttpClient client = UtilityFactory.getHttpClient();
    	
            HttpRequest request = client.createRequest(ServiceConstants.ServiceType.SPEECH);
            request.setMethod('POST');
            request.setHeader('X-SpeechContext', context);
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setHeader('Accept', 'application/json');
            
            // set content type for current file 
            request.setHeader('Content-Type', audioType);
            
            // set Blob type only with this method, dont use setBody() !
            request.setBodyAsBlob(fileBlob);            
			HttpResponse response = client.sendRequest(request);
	            
            // check response code
            UtilityFactory.getRestErrorHandler().checkResponseCode(response);
            String responseBody = String.escapeSingleQuotes(response.getBody());

			// all is good - so parse right result
			result = AttSpeechResult.parse(responseBody); 

            return result;
        }
}